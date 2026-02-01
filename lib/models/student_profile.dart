import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  String name;
  String email;
  bool isComplete;
  List<Education> education;
  List<Project> projects;
  List<String> skills;
  Constraints constraints;
  List<String> bulletBank;

  StudentProfile({
    required this.name,
    required this.email,
    this.isComplete = false,
    required this.education,
    required this.projects,
    required this.skills,
    required this.constraints,
    required this.bulletBank,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isComplete': isComplete,
      'skills': skills,
      'bulletBank': bulletBank,
      'education': education.map((e) => e.toMap()).toList(),
      'projects': projects.map((p) => p.toMap()).toList(),
      'constraints': constraints.toMap(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isComplete: map['isComplete'] ?? false,
      skills: List<String>.from(map['skills'] ?? []),
      bulletBank: List<String>.from(map['bulletBank'] ?? []),
      education: (map['education'] as List? ?? [])
          .map((e) => Education.fromMap(e))
          .toList(),
      projects: (map['projects'] as List? ?? [])
          .map((p) => Project.fromMap(p))
          .toList(),
      constraints: Constraints.fromMap(map['constraints'] ?? {}),
    );
  }
}

class Education {
  final String school;
  final String degree;
  final String year;

  Education({
    required this.school,
    required this.degree,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'year': year,
    };
  }

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      year: map['year'] ?? '',
    );
  }
}


class Project {
  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final String? link;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.skills,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'skills': skills,
      'link': link,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      link: map['link'],
    );
  }
}

class Constraints {
  List<String> location;
  bool remoteOnly;


  Constraints({
    required this.location,
    required this.remoteOnly,

  });

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'remoteOnly': remoteOnly,

    };
  }

  factory Constraints.fromMap(Map<String, dynamic> map) {
    return Constraints(
      location: List<String>.from(map['location'] ?? []),
      remoteOnly: map['remoteOnly'] ?? false,

    );
  }
}
