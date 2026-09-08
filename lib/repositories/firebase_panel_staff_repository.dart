import 'package:cloud_functions/cloud_functions.dart';
import '../domain/panel_staff.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/panel_staff_repository.dart';

class FirebasePanelStaffRepository implements PanelStaffRepository {
  FirebasePanelStaffRepository({
    required FirebaseFunctions Function() functions,
    required this.initialize,
  }) : _functions = functions;
  final FirebaseFunctions Function() _functions;
  final Future<void> Function() initialize;
  Future<Map<String, dynamic>> _call(Map<String, Object?> command) async {
    try {
      await initialize();
      final result = await _functions()
          .httpsCallable(
            'managePanelUsers',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 70)),
          )
          .call<Map<String, dynamic>>(command);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      throw StaffFailure(switch (error.code) {
        'unauthenticated' || 'permission-denied' => StaffIssue.denied,
        'invalid-argument' => StaffIssue.invalid,
        'already-exists' => StaffIssue.duplicate,
        'aborted' => StaffIssue.conflict,
        'failed-precondition' => StaffIssue.protectedAccount,
        'resource-exhausted' => StaffIssue.limit,
        _ => StaffIssue.unavailable,
      });
    } catch (_) {
      throw const StaffFailure(StaffIssue.unavailable);
    }
  }

  @override
  Future<StaffPage> list(String country, {String? cursor}) async {
    final data = await _call({
      'action': 'list',
      'country': country,
      'cursor': ?cursor,
    });
    return StaffPage(
      List<PanelStaff>.unmodifiable(
        (data['users'] as List).map((raw) {
          final user = Map<String, dynamic>.from(raw as Map);
          final scopes = Map<String, dynamic>.from(user['memberships'] as Map);
          return PanelStaff(
            uid: user['uid'] as String,
            name: user['name'] as String,
            email: user['email'] as String,
            memberships: Map.unmodifiable(
              scopes.map(
                (country, values) => MapEntry(
                  country,
                  Set<PanelRole>.unmodifiable(
                    (values as List).map(
                      (name) => PanelRole.values.byName(name as String),
                    ),
                  ),
                ),
              ),
            ),
            active: user['active'] == true,
            verified: user['verified'] == true,
            editable: user['editable'] == true,
            pending: user['provisioning'] != 'ready',
            invitationSent: user['invitationSent'] == true,
            revision: user['revision'] as int,
          );
        }),
      ),
      data['nextCursor'] as String?,
    );
  }

  @override
  Future<bool> mutate(Map<String, Object?> command) async =>
      (await _call(command))['invitationSent'] == true;
}
