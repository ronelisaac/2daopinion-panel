import 'package:flutter/foundation.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/panel_identity_repository.dart';

class PanelLoginController extends ChangeNotifier {
  PanelLoginController(this._repository);
  final PanelIdentityRepository _repository;
  bool busy = false;
  bool _disposed = false;
  PanelAccessIssue? issue;
  bool resetSent = false;
  Future<void> resetPassword(String email) async {
    if (busy || _disposed) return;
    resetSent = false;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim()) ||
        email.length > 254) {
      issue = PanelAccessIssue.invalid;
      notifyListeners();
      return;
    }
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await _repository.resetPassword(email.trim());
      if (!_disposed) resetSent = true;
    } catch (error) {
      if (!_disposed) {
        issue = error is PanelAccessFailure
            ? error.issue
            : PanelAccessIssue.unavailable;
      }
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<PanelPrincipal?> signIn(String email, String password) async {
    if (busy || _disposed) return null;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim()) ||
        email.length > 254 ||
        password.isEmpty ||
        password.length > 128) {
      issue = PanelAccessIssue.invalid;
      notifyListeners();
      return null;
    }
    busy = true;
    resetSent = false;
    issue = null;
    notifyListeners();
    try {
      final principal = await _repository.signIn(email.trim(), password);
      if (!_disposed && principal.active) return principal;
      if (!_disposed) issue = PanelAccessIssue.denied;
    } catch (error) {
      if (!_disposed) {
        issue = error is PanelAccessFailure
            ? error.issue
            : PanelAccessIssue.unavailable;
      }
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
