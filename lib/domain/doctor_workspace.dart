enum WorkspaceState { unlinked, blocked, ready }

enum WorkspaceIssue { denied, conflict, blocked, limit, invalid, unavailable }

class WorkspaceFailure implements Exception {
  const WorkspaceFailure(this.issue);
  final WorkspaceIssue issue;
}

class DoctorWorkspace {
  const DoctorWorkspace({
    required this.state,
    required this.accepting,
    required this.revision,
    this.token,
    this.name,
    this.registry,
    this.specialty,
    this.updatedAt,
  });
  final WorkspaceState state;
  final bool accepting;
  final int revision;
  final String? token;
  final String? name;
  final String? registry;
  final String? specialty;
  final DateTime? updatedAt;
}
