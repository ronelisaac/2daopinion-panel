import 'package:cloud_functions/cloud_functions.dart';
import '../domain/doctor_workspace.dart';
import '../domain/repositories/doctor_workspace_repository.dart';

class FirebaseDoctorWorkspaceRepository implements DoctorWorkspaceRepository {
  FirebaseDoctorWorkspaceRepository({
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
      throw WorkspaceFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => WorkspaceIssue.denied,
        'aborted' || 'already-exists' => WorkspaceIssue.conflict,
        'failed-precondition' => WorkspaceIssue.blocked,
        'resource-exhausted' => WorkspaceIssue.limit,
        'invalid-argument' => WorkspaceIssue.invalid,
        _ => WorkspaceIssue.unavailable,
      });
    } catch (_) {
      throw const WorkspaceFailure(WorkspaceIssue.unavailable);
    }
  }

  @override
  Future<DoctorWorkspace> read(String country) async {
    final data = await _call({'action': 'myWorkspace', 'country': country});
    final doctor = data['doctor'] as Map?;
    return DoctorWorkspace(
      state: WorkspaceState.values.byName(data['state'] as String),
      accepting: data['accepting'] == true,
      revision: data['revision'] as int,
      token: data['workspaceToken'] as String?,
      name: doctor?['name'] as String?,
      registry: doctor?['registry'] as String?,
      specialty: doctor?['specialty'] as String?,
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.parse(data['updatedAt'] as String).toUtc(),
    );
  }

  @override
  Future<void> save(
    String country,
    DoctorWorkspace previous,
    bool accepting,
    String requestId,
  ) async {
    await _call({
      'action': 'setAvailability',
      'country': country,
      'accepting': accepting,
      'revision': previous.revision,
      'workspaceToken': previous.token,
      'requestId': requestId,
    });
  }
}
