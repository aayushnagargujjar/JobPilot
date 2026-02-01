class ApplyPolicy {
  int maxDailyApplications;
  int minMatchThreshold;
  List<String> blockedCompanies;
  List<String> allowedRoles;
  bool stopAll;

  ApplyPolicy({
    required this.maxDailyApplications,
    required this.minMatchThreshold,
    required this.blockedCompanies,
    required this.allowedRoles,
    required this.stopAll,
  });
}