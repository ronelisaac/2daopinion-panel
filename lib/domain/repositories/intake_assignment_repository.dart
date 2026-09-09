import '../intake_assignment.dart';

abstract interface class IntakeAssignmentRepository {
  Future<IntakeAssignment> get(String country, String id);
  Future<AssignmentCandidates> candidates(
    String country,
    IntakeAssignment previous, {
    String? cursor,
  });
  Future<void> assign(
    String country,
    IntakeAssignment previous,
    String doctorId,
    String requestId,
  );
  Future<void> release(
    String country,
    IntakeAssignment previous,
    AssignmentReason reason,
    String requestId,
  );
}
