enum AssignmentStatus { unassigned, pendingAcceptance, released }

enum AssignmentReason { wrongSelection, availabilityChanged, routingChanged }

enum AssignmentIssue { invalid, denied, conflict, limit, unavailable }

class AssignmentFailure implements Exception {
  const AssignmentFailure(this.issue);
  final AssignmentIssue issue;
}

class IntakeAssignment {
  const IntakeAssignment({
    required this.id,
    required this.revision,
    required this.status,
    required this.classificationRevision,
    required this.canAssign,
    required this.canRelease,
    this.doctorId,
    this.doctorName,
    this.specialtyName,
    this.updatedAt,
  });
  final String id;
  final int revision;
  final AssignmentStatus status;
  final int classificationRevision;
  final bool canAssign, canRelease;
  final String? doctorId, doctorName, specialtyName;
  final DateTime? updatedAt;
}

class AssignmentCandidate {
  const AssignmentCandidate(this.id, this.name, this.registry);
  final String id, name, registry;
}

class AssignmentCandidates {
  const AssignmentCandidates(this.items, this.nextCursor);
  final List<AssignmentCandidate> items;
  final String? nextCursor;
}
