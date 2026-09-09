enum DoctorAdministrationIssue { invalid, denied, conflict, limit, unavailable }

class DoctorAdministrationFailure implements Exception {
  const DoctorAdministrationFailure(this.issue);
  final DoctorAdministrationIssue issue;
}

class DoctorAdministration {
  const DoctorAdministration({
    required this.id,
    required this.active,
    required this.revision,
    this.reason,
    this.updatedAt,
  });
  final String id;
  final bool active;
  final int revision;
  final String? reason;
  final DateTime? updatedAt;
  static bool validReason(String value) =>
      value.trim().runes.length >= 10 && value.trim().runes.length <= 500;
}
