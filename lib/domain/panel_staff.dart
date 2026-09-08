import 'panel_access.dart';

class PanelStaff {
  PanelStaff({
    required this.uid,
    required this.name,
    required this.email,
    required this.memberships,
    required this.active,
    required this.verified,
    required this.editable,
    required this.revision,
    required this.pending,
    required this.invitationSent,
  });
  final String uid;
  final String name;
  final String email;
  final Map<String, Set<PanelRole>> memberships;
  final bool active;
  final bool verified;
  final bool editable;
  final bool pending;
  final bool invitationSent;
  final int revision;
}

class StaffPage {
  StaffPage(this.users, this.nextCursor);
  final List<PanelStaff> users;
  final String? nextCursor;
}

enum StaffIssue {
  denied,
  invalid,
  duplicate,
  conflict,
  protectedAccount,
  limit,
  unavailable,
}

class StaffFailure implements Exception {
  const StaffFailure(this.issue);
  final StaffIssue issue;
}
