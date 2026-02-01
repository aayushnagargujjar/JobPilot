enum JobStatus { NEW, QUEUED, PROCESSING, APPLIED, FAILED, SKIPPED }

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final bool remote;
  final List<String> requirements;
  final String postedDate;
  int matchScore;
  JobStatus status;
  String? statusMessage;
  Map<String, String>? evidenceUsed;
  String? confirmationId;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.remote,
    required this.requirements,
    required this.postedDate,
    this.matchScore = 0,
    this.status = JobStatus.NEW,
    this.statusMessage,
    this.evidenceUsed,
    this.confirmationId,
  });

  Job copyWith({
    int? matchScore,
    JobStatus? status,
    String? statusMessage,
    Map<String, String>? evidenceUsed,
    String? confirmationId,
  }) {
    return Job(
      id: id,
      title: title,
      company: company,
      location: location,
      type: type,
      remote: remote,
      requirements: requirements,
      postedDate: postedDate,
      matchScore: matchScore ?? this.matchScore,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      evidenceUsed: evidenceUsed ?? this.evidenceUsed,
      confirmationId: confirmationId ?? this.confirmationId,
    );
  }
}