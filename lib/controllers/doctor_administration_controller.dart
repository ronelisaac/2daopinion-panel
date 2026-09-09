import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/doctor_administration.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/doctor_administration_repository.dart';

class DoctorAdministrationController extends ChangeNotifier {
  DoctorAdministrationController(
    this.repository,
    this.principal,
    this.country,
    this.previous,
  );
  final DoctorAdministrationRepository repository;
  final PanelPrincipal principal;
  final String country;
  final DoctorAdministration previous;
  DoctorAdministrationIssue? issue;
  bool busy = false;
  bool _disposed = false;
  String? _requestId;
  String? _retryReason;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.doctors) &&
      PanelAccess.hasRole(principal, country, PanelRole.operations);
  bool get canSave =>
      !_disposed &&
      !busy &&
      allowed &&
      ![
        DoctorAdministrationIssue.denied,
        DoctorAdministrationIssue.conflict,
        DoctorAdministrationIssue.limit,
      ].contains(issue);
  Future<bool> save(String reason) async {
    if (!canSave) return false;
    reason = reason.trim();
    if (!DoctorAdministration.validReason(reason)) {
      issue = DoctorAdministrationIssue.invalid;
      notifyListeners();
      return false;
    }
    if (_requestId == null || reason != _retryReason) {
      final random = Random.secure();
      _requestId = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      _retryReason = reason;
    }
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await repository.setActive(
        country,
        previous,
        !previous.active,
        reason,
        _requestId!,
      );
      return !_disposed;
    } catch (error) {
      if (!_disposed) {
        issue = error is DoctorAdministrationFailure
            ? error.issue
            : DoctorAdministrationIssue.unavailable;
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
    _requestId = null;
    _retryReason = null;
    super.dispose();
  }
}
