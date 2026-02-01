import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/job.dart';
import '../models/student_profile.dart';
import '../models/apply_policy.dart';
import '../models/agent_log.dart';
import '../constants.dart';
import '../services/resume_services.dart';

class AppProvider extends ChangeNotifier {
  StudentProfile profile = kDefaultProfile;
  ApplyPolicy policy = ApplyPolicy(
    maxDailyApplications: 50,
    minMatchThreshold: 60,
    blockedCompanies: ["EvilCorp", "UnethicalInc"],
    allowedRoles: ["Developer", "Engineer", "Intern", "Research"],
    stopAll: false,
  );

  List<Job> jobs = List.from(kMockJobs);
  List<AgentLog> logs = [];
  bool isRunning = false;
  String apiKey = "AIzaSyBxqK6_ruwKBbyLsdx8vVubIXYnRZi1nOc";

  void addLog(String agent, String message, String type) {
    logs.add(AgentLog(agent, message, type));
    notifyListeners();
  }


  int _calculateMatchScore(Job job) {
    double score = 0;

    final jobSkills = job.requirements.map((e) => e.toLowerCase()).toList();
    final studentSkills = profile.skills.map((e) => e.toLowerCase()).toList();
    final matched = jobSkills.where((s) => studentSkills.any((ss) => ss.contains(s) || s.contains(ss))).length;

    if (jobSkills.isNotEmpty) {
      score += (matched / jobSkills.length) * 50;
    }


    if (policy.allowedRoles.any((r) => job.title.toLowerCase().contains(r.toLowerCase()))) {
      score += 20;
    }

    if (job.remote && profile.constraints.remoteOnly) score += 30;
    else if (!profile.constraints.remoteOnly) score += 10;
    if (profile.constraints.location.any((l) => job.location.contains(l))) score += 20;

    return min(100, score.floor());
  }

  Future<void> runResumeParser(String text) async {
    addLog('ARTIFACT', 'Analyzing resume text...', 'INFO');

    final basicInfo = ResumeService.extractBasicInfo(text);
    if (basicInfo['email'] != "" || basicInfo['name'] != "") {
      if (basicInfo['name'] != "") profile.name = basicInfo['name'];
      if (basicInfo['email'] != "") profile.email = basicInfo['email'];
      notifyListeners();
    }

    try {
      if (apiKey.isNotEmpty) {
        addLog('AI_AGENT', 'Asking Gemini to structure data...', 'Processing');

        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

        final prompt = '''
          Extract data from this resume. Return ONLY raw JSON (no markdown).
          Schema:
          {
            "name": "String",
            "skills": ["String"],
            "education": [{"school": "String", "degree": "String", "year": "String"}],
            "projects": [{"name": "String", "description": "String", "skills": ["String"]}]
          }
          Resume Text: $text
        ''';

        final response = await model.generateContent([Content.text(prompt)]);
        final cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '');
        final data = jsonDecode(cleanJson);

        profile.name = data['name'] ?? profile.name;
        profile.skills = List<String>.from(data['skills'] ?? []);

        if (data['education'] != null) {
          profile.education = (data['education'] as List).map((e) => Education.fromJson(e)).toList();
        }

        if (data['projects'] != null) {

          profile.projects = (data['projects'] as List).asMap().entries.map((e) {
            return Project(
                "p${e.key}",
                e.value['name'] ?? "Project",
                e.value['description'] ?? "",
                List<String>.from(e.value['skills'] ?? []),
                ""
            );
          }).toList();
        }

        addLog('ARTIFACT', 'Profile updated successfully via Gemini.', 'SUCCESS');
        notifyListeners();

      } else {

        await Future.delayed(Duration(seconds: 1));
        addLog('ARTIFACT', 'Simulation: Profile updated.', 'SUCCESS');
      }
    } catch (e) {
      addLog('ARTIFACT', 'Failed to parse resume: $e', 'ERROR');
    }
  }

  Future<void> runSearchAndRank() async {
    addLog('SEARCH', 'Scanning sandbox job portal...', 'INFO');
    await Future.delayed(Duration(seconds: 1));

    final newJobs = jobs.map((job) {
      if (job.status != JobStatus.NEW) return job;
      final score = _calculateMatchScore(job);
      return job.copyWith(matchScore: score);
    }).toList();

    newJobs.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    jobs = newJobs;

    final qualifying = newJobs.where((j) => j.matchScore >= policy.minMatchThreshold).length;
    addLog('RANK', 'Ranked ${newJobs.length} jobs. $qualifying qualify.', 'SUCCESS');
    notifyListeners();
  }

  Future<void> runAutoApplyLoop() async {
    if (isRunning) return;
    isRunning = true;
    notifyListeners();

    addLog('SYSTEM', 'Starting Auto-Apply Loop...', 'INFO');

    try {

      final candidates = jobs.where((j) => j.status == JobStatus.NEW && j.matchScore >= policy.minMatchThreshold).toList();

      if (candidates.isEmpty) {
        addLog('SYSTEM', 'No qualifying jobs found.', 'WARNING');
        isRunning = false;
        notifyListeners();
        return;
      }

      for (var job in candidates) {
        if (!isRunning) break;
        if (policy.stopAll) {
          addLog('GUARDRAIL', 'Kill switch active. Stopping.', 'ERROR');
          break;
        }

        addLog('GUARDRAIL', 'Checking policy for: ${job.company}', 'INFO');
        if (policy.blockedCompanies.contains(job.company)) {
          _updateJobStatus(job.id, JobStatus.SKIPPED, 'Blocked Company');
          addLog('GUARDRAIL', 'Blocked ${job.company} by policy.', 'WARNING');
          continue;
        }


        _updateJobStatus(job.id, JobStatus.PROCESSING, null);
        addLog('PERSONALIZER', 'Generating evidence map for ${job.title}...', 'INFO');

        Map<String, String> evidence = {"Flutter": "Project: Expense Tracker"};
        if (apiKey.isNotEmpty) {

        }
        await Future.delayed(Duration(milliseconds: 800));

        addLog('SUBMITTER', 'Submitting to ${job.company}...', 'INFO');
        await Future.delayed(Duration(milliseconds: 1200));

        final success = Random().nextDouble() > 0.1;

        if (success) {
          _updateJobStatus(
              job.id,
              JobStatus.APPLIED,
              null,
              evidenceUsed: evidence,
              confirmationId: 'APP-${Random().nextInt(10000)}'
          );
          addLog('SUBMITTER', 'Success! Receipt generated.', 'SUCCESS');
        } else {
          _updateJobStatus(job.id, JobStatus.FAILED, 'Network Timeout');
          addLog('SUBMITTER', 'Submission failed. Retrying later.', 'ERROR');
        }

        await Future.delayed(Duration(milliseconds: 500));
      }
    } finally {
      isRunning = false;
      addLog('SYSTEM', 'Batch complete.', 'INFO');
      notifyListeners();
    }
  }

  void _updateJobStatus(String id, JobStatus status, String? msg, {Map<String, String>? evidenceUsed, String? confirmationId}) {
    final idx = jobs.indexWhere((j) => j.id == id);
    if (idx != -1) {
      jobs[idx] = jobs[idx].copyWith(
          status: status,
          statusMessage: msg,
          evidenceUsed: evidenceUsed,
          confirmationId: confirmationId
      );
      notifyListeners();
    }
  }

  void stop() {
    isRunning = false;
    notifyListeners();
  }
}