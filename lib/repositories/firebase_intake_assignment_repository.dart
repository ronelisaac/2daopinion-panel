import 'package:cloud_functions/cloud_functions.dart';
import '../domain/intake_assignment.dart';
import '../domain/repositories/intake_assignment_repository.dart';

class FirebaseIntakeAssignmentRepository implements IntakeAssignmentRepository {
  FirebaseIntakeAssignmentRepository({
    required this.functions,
    required this.initialize,
  });
  final FirebaseFunctions Function() functions;
  final Future<void> Function() initialize;
  Future<Map<String, dynamic>> _call(Map<String, Object?> input) async {
    try {
      await initialize();
      return (await functions()
              .httpsCallable(
                'managePanelUsers',
                options: HttpsCallableOptions(
                  timeout: const Duration(seconds: 70),
                ),
              )
              .call<Map<String, dynamic>>(input))
          .data;
    } on FirebaseFunctionsException catch (error) {
      throw AssignmentFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => AssignmentIssue.denied,
        'aborted' ||
        'already-exists' ||
        'failed-precondition' => AssignmentIssue.conflict,
        'invalid-argument' => AssignmentIssue.invalid,
        'resource-exhausted' => AssignmentIssue.limit,
        _ => AssignmentIssue.unavailable,
      });
    } catch (_) {
      throw const AssignmentFailure(AssignmentIssue.unavailable);
    }
  }

  @override
  Future<IntakeAssignment> get(String country, String id) async {
    final data = await _call({
      'action': 'intakeAssignmentGet',
      'country': country,
      'id': id,
    });
    return IntakeAssignment(
      id: data['id'] as String,
      revision: data['revision'] as int,
      status: AssignmentStatus.values.byName(data['status'] as String),
      classificationRevision: data['classificationRevision'] as int,
      canAssign: data['canAssign'] == true,
      canRelease: data['canRelease'] == true,
      doctorId: data['doctorId'] as String?,
      doctorName: data['doctorName'] as String?,
      specialtyName: data['specialtyName'] as String?,
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.parse(data['updatedAt'] as String).toUtc(),
    );
  }

  @override
  Future<AssignmentCandidates> candidates(
    String country,
    IntakeAssignment previous, {
    String? cursor,
  }) async {
    final data = await _call({
      'action': 'intakeAssignmentCandidates',
      'country': country,
      'id': previous.id,
      'classificationRevision': previous.classificationRevision,
      'cursor': cursor,
    });
    return AssignmentCandidates(
      (data['items'] as List)
          .map(
            (item) => AssignmentCandidate(
              item['id'] as String,
              item['name'] as String,
              item['registry'] as String,
            ),
          )
          .toList(),
      data['nextCursor'] as String?,
    );
  }

  @override
  Future<void> assign(
    String country,
    IntakeAssignment previous,
    String doctorId,
    String requestId,
  ) async {
    await _call({
      'action': 'intakeAssignmentSet',
      'country': country,
      'id': previous.id,
      'revision': previous.revision,
      'classificationRevision': previous.classificationRevision,
      'doctorId': doctorId,
      'confirmed': true,
      'requestId': requestId,
    });
  }

  @override
  Future<void> release(
    String country,
    IntakeAssignment previous,
    AssignmentReason reason,
    String requestId,
  ) async {
    await _call({
      'action': 'intakeAssignmentRelease',
      'country': country,
      'id': previous.id,
      'revision': previous.revision,
      'reason': reason.name,
      'confirmed': true,
      'requestId': requestId,
    });
  }
}
