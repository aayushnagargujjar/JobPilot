import 'package:cloud_firestore/cloud_firestore.dart';

enum JobStatus { NEW, QUEUED, PROCESSING, APPLIED, FAILED, SKIPPED }

class Job {
  // New Fields from your JSON
  final String id;              // Maps to 'jobId'
  final String role;            // Maps to 'role'
  final String company;
  final String location;
  final String type;            // Maps to 'jobType'
  final bool visaRequired;
  final String startDate;
  final String experienceLevel;
  final List<String> skills;    // Maps to 'skillsRequired'
  final String description;
  final String applyEndpoint;

  // Local State Fields (For the Agent)
  int matchScore;
  String? matchReasoning;
  JobStatus status;
  String? statusMessage;
  Map<String, String>? evidenceUsed;
  String? confirmationId;

  Job({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.type,
    required this.visaRequired,
    required this.startDate,
    required this.experienceLevel,
    required this.skills,
    required this.description,
    required this.applyEndpoint,
    // Defaults
    this.matchScore = 0,
    this.matchReasoning,
    this.status = JobStatus.NEW,
    this.statusMessage,
    this.evidenceUsed,
    this.confirmationId,
  });

  // Factory to read your specific JSON format from Firestore
  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Job(
      id: data['jobId'] ?? doc.id,
      role: data['role'] ?? 'Unknown Role',
      company: data['company'] ?? 'Unknown Company',
      location: data['location'] ?? 'Remote',
      type: data['jobType'] ?? 'Full-time',
      visaRequired: data['visaRequired'] ?? false,
      startDate: data['startDate'] ?? '',
      experienceLevel: data['experienceLevel'] ?? 'Fresher',
      skills: List<String>.from(data['skillsRequired'] ?? []),
      description: data['description'] ?? '',
      applyEndpoint: data['applyEndpoint'] ?? '',
      status: JobStatus.NEW,
    );
  }

  Job copyWith({
    int? matchScore,
    String? matchReasoning,
    JobStatus? status,
    String? statusMessage,
    Map<String, String>? evidenceUsed,
    String? confirmationId,
  }) {
    return Job(
      id: id,
      role: role,
      company: company,
      location: location,
      type: type,
      visaRequired: visaRequired,
      startDate: startDate,
      experienceLevel: experienceLevel,
      skills: skills,
      description: description,
      applyEndpoint: applyEndpoint,
      matchScore: matchScore ?? this.matchScore,
      matchReasoning: matchReasoning ?? this.matchReasoning,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      evidenceUsed: evidenceUsed ?? this.evidenceUsed,
      confirmationId: confirmationId ?? this.confirmationId,
    );
  }
}