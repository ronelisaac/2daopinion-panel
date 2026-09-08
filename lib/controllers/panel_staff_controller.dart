import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/panel_access.dart';
import '../domain/panel_staff.dart';
import '../domain/repositories/panel_staff_repository.dart';

class PanelStaffController extends ChangeNotifier {
  PanelStaffController(this.repository, this.principal, this.country);
  final PanelStaffRepository repository;
  final PanelPrincipal principal;
  final String country;
  List<PanelStaff> users = [];
  String? nextCursor;
  bool busy = false;
  bool _disposed = false;
  StaffIssue? issue;
  bool? invitationSent;
  Map<String, Object?>? _retry;
  String? _retryFingerprint;
  List<String> get allowedCountries => principal.countries
      .where(
        (country) => principal.rolesFor(country).contains(PanelRole.superadmin),
      )
      .toList();
  String _requestId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<void> load({bool more = false}) async {
    if (_disposed || busy || (more && nextCursor == null)) return;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      final result = await repository.list(
        country,
        cursor: more ? nextCursor : null,
      );
      if (_disposed) return;
      users = more ? [...users, ...result.users] : result.users;
      nextCursor = result.nextCursor;
    } catch (error) {
      if (!_disposed) {
        users = [];
        nextCursor = null;
        issue = error is StaffFailure ? error.issue : StaffIssue.unavailable;
      }
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<bool> save({
    PanelStaff? user,
    required String name,
    required String email,
    required Map<String, Set<PanelRole>> memberships,
  }) => _mutate({
    'action': user == null ? 'create' : 'update',
    'country': country,
    'name': name.trim(),
    if (user == null) 'email': email.trim().toLowerCase(),
    if (user != null) ...{'uid': user.uid, 'revision': user.revision},
    'memberships': memberships.map(
      (country, roles) =>
          MapEntry(country, roles.map((role) => role.name).toList()..sort()),
    ),
  });
  Future<bool> setActive(PanelStaff user) => _mutate({
    'action': 'setActive',
    'country': country,
    'uid': user.uid,
    'revision': user.revision,
    'active': !user.active,
  });
  Future<bool> invite(PanelStaff user) => _mutate({
    'action': 'invite',
    'country': country,
    'uid': user.uid,
    'revision': user.revision,
  });
  Future<bool> resume(PanelStaff user) =>
      _mutate({'action': 'resume', 'country': country, 'uid': user.uid});
  Future<bool> _mutate(Map<String, Object?> values) async {
    if (busy || _disposed) return false;
    final fingerprint = jsonEncode(values);
    if (_retry == null || _retryFingerprint != fingerprint) {
      _retry = {
        ...values,
        if (values['action'] != 'resume') 'requestId': _requestId(),
      };
      _retryFingerprint = fingerprint;
    }
    busy = true;
    issue = null;
    invitationSent = null;
    notifyListeners();
    try {
      final sent = await repository.mutate(_retry!);
      if (_disposed) return false;
      invitationSent = ['create', 'invite', 'resume'].contains(values['action'])
          ? sent
          : null;
      _retry = null;
      return true;
    } catch (error) {
      if (!_disposed) {
        issue = error is StaffFailure ? error.issue : StaffIssue.unavailable;
        if (issue != StaffIssue.unavailable && issue != StaffIssue.conflict) {
          _retry = null;
        }
      }
      return false;
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    users = [];
    _retry = null;
    super.dispose();
  }
}
