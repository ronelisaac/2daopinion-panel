import 'package:cloud_functions/cloud_functions.dart';
import '../domain/doctor_administration.dart';
import '../domain/repositories/doctor_administration_repository.dart';

class FirebaseDoctorAdministrationRepository
    implements DoctorAdministrationRepository {
  FirebaseDoctorAdministrationRepository({
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
      throw DoctorAdministrationFailure(switch (error.code) {
        'permission-denied' ||
        'unauthenticated' => DoctorAdministrationIssue.denied,
        'aborted' ||
        'already-exists' ||
        'failed-precondition' => DoctorAdministrationIssue.conflict,
        'resource-exhausted' => DoctorAdministrationIssue.limit,
        'invalid-argument' => DoctorAdministrationIssue.invalid,
        _ => DoctorAdministrationIssue.unavailable,
      });
    } catch (_) {
      throw const DoctorAdministrationFailure(
        DoctorAdministrationIssue.unavailable,
      );
    }
  }

  @override
  Future<List<DoctorAdministration>> list(
    String country,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];
    final data = await _call({
      'action': 'doctorAdminList',
      'country': country,
      'ids': ids,
    });
    return (data['items'] as List)
        .map(
          (item) => DoctorAdministration(
            id: item['id'] as String,
            active: item['active'] == true,
            revision: item['revision'] as int,
            reason: item['reason'] as String?,
            updatedAt: item['updatedAt'] == null
                ? null
                : DateTime.parse(item['updatedAt'] as String).toUtc(),
          ),
        )
        .toList();
  }

  @override
  Future<void> setActive(
    String country,
    DoctorAdministration previous,
    bool active,
    String reason,
    String requestId,
  ) async {
    await _call({
      'action': 'doctorAdminSetActive',
      'country': country,
      'id': previous.id,
      'active': active,
      'revision': previous.revision,
      'reason': reason,
      'requestId': requestId,
    });
  }
}
