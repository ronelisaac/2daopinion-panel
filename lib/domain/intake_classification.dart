enum ClassificationSource { unconfirmed, patientConfirmed, medicalReferral }

enum ClassificationIssue { invalid, denied, conflict, limit, unavailable }

class ClassificationFailure implements Exception {
  const ClassificationFailure(this.issue);
  final ClassificationIssue issue;
}

class IntakeClassification {
  const IntakeClassification({
    required this.id,
    required this.revision,
    required this.source,
    required this.editable,
    required this.specialtyActive,
    this.specialtyId,
    this.specialtyName,
    this.updatedAt,
  });
  final String id;
  final int revision;
  final ClassificationSource source;
  final bool editable;
  final bool specialtyActive;
  final String? specialtyId;
  final String? specialtyName;
  final DateTime? updatedAt;
}

class ClassificationInput {
  const ClassificationInput(this.source, this.specialtyId, this.confirmed);
  final ClassificationSource source;
  final String? specialtyId;
  final bool confirmed;
  bool get valid =>
      confirmed &&
      (source == ClassificationSource.unconfirmed
          ? specialtyId == null
          : specialtyId != null &&
                RegExp(r'^CL_[a-z][a-z0-9_]{1,31}$').hasMatch(specialtyId!));
}
