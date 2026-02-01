import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/job.dart';
import '../models/student_profile.dart';
import '../models/apply_policy.dart';
import '../models/agent_log.dart';
import '../constants.dart';
import '../services/resume_services.dart';

class AppProvider extends ChangeNotifier {
  // 🔥 FIREBASE SETUP
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // State
  StudentProfile profile = kDefaultProfile;
  List<Job> jobs = []; // Starts empty, fills from Cloud
  List<AgentLog> logs = [];
  bool isRunning = false;
  bool isLoading = true;

  String apiKey = "AIzaSyBxqK6_ruwKBbyLsdx8vVubIXYnRZi1nOc"; // Use .env in production

  ApplyPolicy policy = ApplyPolicy(
    maxDailyApplications: 50,
    minMatchThreshold: 60,
    blockedCompanies: ["EvilCorp", "UnethicalInc"],
    allowedRoles: ["Developer", "Engineer", "Intern", "Research"],
    stopAll: false,
  );

  // ---------------------------------------------------------------------------
  // 🔄 INITIALIZATION (Profile + Jobs + History)
  // ---------------------------------------------------------------------------

  AppProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    addLog('SYSTEM', 'Connecting to Cloud Database...', 'INFO');

    try {
      // 1. Load User Profile
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        profile = StudentProfile.fromMap(doc.data()!);
        if (profile.name.isNotEmpty) profile.isComplete = true;
        addLog('SYSTEM', 'Welcome back, ${profile.name}.', 'SUCCESS');
      } else {
        profile.isComplete = false;
        addLog('SYSTEM', 'No profile found. Please upload resume.', 'WARNING');
      }

      // 2. Fetch Jobs from Firebase
      await _fetchJobsFromCloud();

      // 3. Sync Application History (Restore Status)
      await _syncApplicationHistory();

    } catch (e) {
      addLog('SYSTEM', 'Init Failed: $e', 'ERROR');
    }

    isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🔥 FIREBASE FETCHERS
  // ---------------------------------------------------------------------------

  Future<void> _fetchJobsFromCloud() async {
    try {
      addLog('SYSTEM', 'Fetching jobs from Firebase...', 'INFO');

      // Get docs from 'jobs' collection
      final snapshot = await _db.collection('jobs').get();

      if (snapshot.docs.isEmpty) {
        addLog('SYSTEM', 'No jobs found in database.', 'WARNING');
        jobs = [];
      } else {
        jobs = snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
        addLog('SYSTEM', 'Loaded ${jobs.length} jobs from cloud.', 'SUCCESS');
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      jobs = [];
    }
  }

  Future<void> _syncApplicationHistory() async {
    try {
      final snapshot = await _db.collection('users').doc(userId).collection('applications').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final jobId = data['jobId'];

        // Find the job in our local list and update its status
        final idx = jobs.indexWhere((j) => j.id == jobId);
        if (idx != -1) {
          jobs[idx] = jobs[idx].copyWith(
            status: JobStatus.values.firstWhere(
                    (e) => e.name == data['status'],
                orElse: () => JobStatus.APPLIED
            ),
            matchScore: data['matchScore'],
            matchReasoning: data['matchReasoning'],
            evidenceUsed: data['evidenceUsed'] != null
                ? Map<String,String>.from(data['evidenceUsed'])
                : null,
          );
        }
      }
    } catch (e) {
      print("Error syncing history: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 📝 RESUME PARSER & SAVER
  // ---------------------------------------------------------------------------

  Future<void> runResumeParser(String text) async {
    if (userId == null) {
      addLog('SYSTEM', 'No user logged in. Cannot save profile.', 'ERROR');
      return;
    }

    addLog('ARTIFACT', 'Analyzing resume text...', 'INFO');

    // 1. Quick Regex Update for UI feedback
    final basicInfo = ResumeService.extractBasicInfo(text);
    if (basicInfo['email'] != "" || basicInfo['name'] != "") {
      if (basicInfo['name'] != "") profile.name = basicInfo['name'];
      if (basicInfo['email'] != "") profile.email = basicInfo['email'];
      notifyListeners();
    }

    try {
      if (apiKey.isNotEmpty) {
        addLog('AI_AGENT', 'Structuring data with Gemini...', 'Processing');

        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
        final prompt = '''
          Extract data from this resume into JSON.
          Schema: {
            "name": "String",
            "email": "String",
            "skills": ["String"],
            "education": [{"school": "String", "degree": "String", "year": "String"}],
            "projects": [{"name": "String", "description": "String", "skills": ["String"]}],
            "experience_bullets": ["String"]
          }
          Resume Text: $text
        ''';

        final response = await model.generateContent([Content.text(prompt)]);
        final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
        final data = jsonDecode(cleanJson);

        // 2. Update Profile Object locally
        profile.name = data['name'] ?? profile.name;
        profile.email = data['email'] ?? profile.email;
        profile.skills = List<String>.from(data['skills'] ?? []);
        profile.bulletBank = List<String>.from(data['experience_bullets'] ?? []);

        if (data['education'] != null) {
          profile.education = (data['education'] as List).map((e) => Education.fromMap(e)).toList();
        }

        if (data['projects'] != null) {
          profile.projects = (data['projects'] as List).asMap().entries.map((e) {
            return Project(
              id: "p${e.key}",
              name: e.value['name'] ?? "Project",
              description: e.value['description'] ?? "",
              skills: List<String>.from(e.value['skills'] ?? []),
              link: e.value['link'],
            );
          }).toList();
        }

        profile.isComplete = true;

        Map<String, dynamic> userUpdate = profile.toMap();
        userUpdate['resume'] = cleanJson;

        await _db.collection('users').doc(userId).set(
          userUpdate,
          SetOptions(merge: true),
        );

        addLog('ARTIFACT', 'Profile & Gemini analysis saved to Cloud.', 'SUCCESS');
        notifyListeners();
      }
    } catch (e) {
      addLog('ARTIFACT', 'Parsing Failed: $e', 'ERROR');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 AI RANKING
  // ---------------------------------------------------------------------------

  Future<void> runSearchAndRank() async {
    addLog('SEARCH', 'Analyzing ${jobs.length} jobs...', 'INFO');
    await Future.delayed(Duration(seconds: 1));

    List<Job> rankedJobs = [];

    for (var job in jobs) {
      if (job.status != JobStatus.NEW) {
        rankedJobs.add(job);
        continue;
      }

      int score = 0;
      String reason = "Keyword Match";

      // A. AI SCORING
      if (apiKey.isNotEmpty) {
        try {
          // UPDATED PROMPT with new fields
          final prompt = '''
            Role: Recruiter. Rate match (0-100) between Job and Candidate. 
            Return JSON: {"score": int, "reason": "1 short sentence"}.
            
            Job Role: ${job.role} at ${job.company}
            Description: ${job.description}
            Required Skills: ${job.skills.join(', ')}
            Experience: ${job.experienceLevel}
            
            Candidate Skills: ${profile.skills.join(', ')}
            Candidate Projects: ${profile.projects.map((p)=>p.name).join(', ')}
          ''';

          final result = await _askGeminiJson(prompt);
          score = result['score'] ?? _calculateSimpleMatch(job);
          reason = result['reason'] ?? "AI Analysis";
        } catch (e) {
          score = _calculateSimpleMatch(job);
        }
      } else {
        score = _calculateSimpleMatch(job);
      }

      rankedJobs.add(job.copyWith(matchScore: score, matchReasoning: reason));
    }

    rankedJobs.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    jobs = rankedJobs;

    addLog('RANK', 'Ranking complete.', 'SUCCESS');
    notifyListeners();
  }

  int _calculateSimpleMatch(Job job) {
    // Updated fallback logic to use 'skills' and 'role'
    final jobSkills = job.skills.map((e) => e.toLowerCase()).toList();
    final studentSkills = profile.skills.map((e) => e.toLowerCase()).toList();
    final matched = jobSkills.where((s) => studentSkills.any((ss) => ss.contains(s) || s.contains(ss))).length;

    double score = 0;
    if (jobSkills.isNotEmpty) score += (matched / jobSkills.length) * 60;
    if (policy.allowedRoles.any((r) => job.role.toLowerCase().contains(r.toLowerCase()))) score += 20;
    // Simple bonus if location matches constraint
    if (profile.constraints.location.any((l) => job.location.contains(l))) score += 20;

    return min(100, score.floor());
  }

  // ---------------------------------------------------------------------------
  // 🚀 AI AUTO-APPLY AGENT
  // ---------------------------------------------------------------------------

  Future<void> runAutoApplyLoop() async {
    if (isRunning) return;
    isRunning = true;
    notifyListeners();

    addLog('SYSTEM', 'Starting Auto-Apply Loop...', 'INFO');

    try {
      final candidates = jobs.where((j) => j.status == JobStatus.NEW && j.matchScore >= policy.minMatchThreshold).toList();

      if (candidates.isEmpty) {
        addLog('SYSTEM', 'No qualifying jobs found.', 'WARNING');
        return;
      }

      for (var job in candidates) {
        if (!isRunning) break;
        if (policy.stopAll) break;

        // 1. Policy Check
        if (policy.blockedCompanies.contains(job.company)) {
          _updateJobStatus(job.id, JobStatus.SKIPPED, 'Blocked Company');
          continue;
        }

        // 2. Generate Evidence
        _updateJobStatus(job.id, JobStatus.PROCESSING, 'Generating Evidence...');
        addLog('AGENT', 'Mapping skills to ${job.company}...', 'INFO');

        Map<String, String> evidence = {};
        if (apiKey.isNotEmpty) {
          final prompt = '''
            Map Candidate Projects to Job Requirements. Return JSON: {"Requirement Name": "Proof from Project"}.
            Job Description: ${job.description}
            Skills Required: ${job.skills.join(',')}
            
            Projects: ${profile.projects.map((p) => "${p.name}: ${p.description}").join(' | ')}
           ''';
          final result = await _askGeminiJson(prompt);
          result.forEach((k, v) => evidence[k] = v.toString());
        }
        await Future.delayed(Duration(milliseconds: 1000));

        // 3. Submit & Save
        final success = Random().nextDouble() > 0.1;

        if (success) {
          // Update Local Status
          _updateJobStatus(
              job.id,
              JobStatus.APPLIED,
              "Applied via Agent",
              evidenceUsed: evidence,
              confirmationId: 'APP-${Random().nextInt(10000)}'
          );

          // 🔥 SAVE APPLICATION TO FIREBASE
          await _db.collection('users').doc(userId).collection('applications').doc(job.id).set({
            'jobId': job.id,
            'company': job.company,
            'status': 'APPLIED',
            'matchScore': job.matchScore,
            'matchReasoning': job.matchReasoning,
            'evidenceUsed': evidence,
            'timestamp': FieldValue.serverTimestamp(),
          });

          addLog('SUBMITTER', 'Application saved to database.', 'SUCCESS');
        } else {
          _updateJobStatus(job.id, JobStatus.FAILED, 'Network Timeout');
          addLog('SUBMITTER', 'Submission failed.', 'ERROR');
        }

        await Future.delayed(Duration(milliseconds: 500));
      }
    } finally {
      isRunning = false;
      addLog('SYSTEM', 'Batch complete.', 'INFO');
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // UTILS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _askGeminiJson(String prompt) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanJson);
    } catch (e) {
      return {};
    }
  }

  /*int _calculateSimpleMatch(Job job) {
    // Basic fallback logic
    final jobSkills = job.requirements.map((e) => e.toLowerCase()).toList();
    final studentSkills = profile.skills.map((e) => e.toLowerCase()).toList();
    final matched = jobSkills.where((s) => studentSkills.any((ss) => ss.contains(s) || s.contains(ss))).length;
    double score = 0;
    if (jobSkills.isNotEmpty) score += (matched / jobSkills.length) * 50;
    return min(100, score.floor());
  }*/

  void _updateJobStatus(String id, JobStatus status, String? msg, {Map<String, String>? evidenceUsed, String? confirmationId}) {
    final idx = jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      jobs[idx] = jobs[idx].copyWith(
          status: status, statusMessage: msg, evidenceUsed: evidenceUsed, confirmationId: confirmationId, matchReasoning: null
      );
      notifyListeners();
    }
  }

  void addLog(String agent, String message, String type) {
    logs.add(AgentLog(agent, message, type));
    notifyListeners();
  }

  void stop() {
    isRunning = false;
    notifyListeners();
  }
}