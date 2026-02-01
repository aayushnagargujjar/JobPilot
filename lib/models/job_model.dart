import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String jobId, company, role, location, jobType, startDate, experienceLevel, description, applyEndpoint;
  final bool visaRequired;
  final List<String> skillsRequired;

  JobModel({
    required this.jobId, required this.company, required this.role, required this.location,
    required this.jobType, required this.visaRequired, required this.startDate,
    required this.experienceLevel, required this.skillsRequired, required this.description,
    required this.applyEndpoint,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['jobId'],
      company: json['company'],
      role: json['role'],
      location: json['location'],
      jobType: json['jobType'],
      visaRequired: json['visaRequired'],
      startDate: json['startDate'],
      experienceLevel: json['experienceLevel'],
      skillsRequired: List<String>.from(json['skillsRequired']),
      description: json['description'],
      applyEndpoint: json['applyEndpoint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'company': company,
      'role': role,
      'location': location,
      'jobType': jobType,
      'visaRequired': visaRequired,
      'startDate': startDate,
      'experienceLevel': experienceLevel,
      'skillsRequired': skillsRequired,
      'description': description,
      'applyEndpoint': applyEndpoint,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}