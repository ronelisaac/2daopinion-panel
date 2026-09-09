enum DoctorStatus { pending, verified, rejected, suspended }

enum DoctorIssue { invalid, denied, duplicate, conflict, unavailable }

class DoctorFailure implements Exception {
  const DoctorFailure(this.issue);
  final DoctorIssue issue;
}

class DoctorInput {
  DoctorInput(String name, String registry, String specialty)
    : name = name.trim(),
      registry = registry.trim(),
      specialty = specialty.trim();
  final String name;
  final String registry;
  final String specialty;
  static bool validName(String value) =>
      value.trim().length >= 3 && value.trim().length <= 120;
  static bool validRegistry(String value) =>
      RegExp(r'^[1-9][0-9]{0,9}$').hasMatch(value.trim());
  static bool validSpecialty(String value) =>
      value.trim().length >= 2 && value.trim().length <= 120;
  bool get valid =>
      validName(name) && validRegistry(registry) && validSpecialty(specialty);
}

class DoctorReview {
  DoctorReview({
    required this.status,
    required String evidence,
    required String note,
    required this.identityChecked,
    required this.titleChecked,
    required this.specialtyChecked,
  }) : evidence = evidence.trim(),
       note = note.trim();
  final DoctorStatus status;
  final String evidence;
  final String note;
  final bool identityChecked;
  final bool titleChecked;
  final bool specialtyChecked;
  bool get valid =>
      status != DoctorStatus.pending &&
      evidence.length >= 3 &&
      evidence.length <= 200 &&
      note.length >= 10 &&
      note.length <= 2000 &&
      (status != DoctorStatus.verified ||
          (identityChecked && titleChecked && specialtyChecked));
}

class DoctorRecord {
  const DoctorRecord({
    required this.id,
    required this.country,
    required this.input,
    required this.status,
    required this.revision,
    required this.createdBy,
    required this.updatedAt,
    this.review,
    this.reviewedBy,
    this.reviewedAt,
  });
  final String id;
  final String country;
  final DoctorInput input;
  final DoctorStatus status;
  final int revision;
  final String createdBy;
  final DateTime updatedAt;
  final DoctorReview? review;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  bool get editable =>
      status == DoctorStatus.pending || status == DoctorStatus.rejected;
  bool permits(DoctorStatus next) => switch (status) {
    DoctorStatus.pending =>
      next == DoctorStatus.verified || next == DoctorStatus.rejected,
    DoctorStatus.verified => next == DoctorStatus.suspended,
    DoctorStatus.suspended =>
      next == DoctorStatus.verified || next == DoctorStatus.rejected,
    DoctorStatus.rejected => false,
  };
}

class DoctorPage {
  const DoctorPage(this.items, this.nextCursor);
  final List<DoctorRecord> items;
  final String? nextCursor;
}
