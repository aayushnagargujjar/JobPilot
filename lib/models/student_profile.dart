class StudentProfile {
  String name;
  String email;
  List<Education> education;
  List<Project> projects;
  List<String> skills;
  Constraints constraints;
  List<String> bulletBank;

  StudentProfile({
    required this.name,
    required this.email,
    required this.education,
    required this.projects,
    required this.skills,
    required this.constraints,
    required this.bulletBank,
  });
}

class Education {
  final String school;
  final String degree;
  final String year;

  Education(this.school, this.degree, this.year);

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(json['school'] ?? '', json['degree'] ?? '', json['year'] ?? '');
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> skills;
  final String? link;

  Project(this.id, this.name, this.description, this.skills, this.link);

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      json['id'] ?? '',
      json['name'] ?? '',
      json['description'] ?? '',
      List<String>.from(json['skills'] ?? []),
      json['link'],
    );
  }
}

class Constraints {
  List<String> location;
  bool remoteOnly;
  bool requireVisa;

  Constraints({required this.location, required this.remoteOnly, required this.requireVisa});
}