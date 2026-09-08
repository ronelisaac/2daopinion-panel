import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/panel_identity_repository.dart';

class PanelSessionController extends ChangeNotifier {
  PanelSessionController(this.repository) {
    _listen();
  }
  void _listen() {
    _subscription = repository.watch().listen(
      _changed,
      onError: (Object error) {
        loading = false;
        issue = PanelAccessIssue.unavailable;
        _changed(null);
      },
    );
  }

  void acceptAuthenticated(PanelPrincipal value) {
    if (_disposed) return;
    _changed(value);
    _subscription?.cancel();
    _listen();
  }

  final PanelIdentityRepository repository;
  StreamSubscription<PanelPrincipal?>? _subscription;
  PanelPrincipal? principal;
  String country = 'CL';
  int epoch = 0;
  bool loading = true;
  PanelAccessIssue? issue;
  bool _disposed = false;
  void _changed(PanelPrincipal? value) {
    if (_disposed) return;
    loading = false;
    final changed =
        principal?.id != value?.id ||
        !setEquals(principal?.countries, value?.countries) ||
        (value != null &&
            value.countries.any(
              (country) => !setEquals(
                principal?.rolesFor(country),
                value.rolesFor(country),
              ),
            ));
    principal = value;
    if (value != null) {
      issue = null;
      if (!value.countries.contains(country)) country = value.countries.first;
    } else {
      country = 'CL';
    }
    if (changed) epoch++;
    notifyListeners();
  }

  void selectCountry(String selected) {
    if (selected == country ||
        principal?.countries.contains(selected) != true) {
      return;
    }
    country = selected;
    epoch++;
    notifyListeners();
  }

  Future<void> signOut() async {
    _changed(null);
    try {
      await repository.signOut();
    } catch (_) {
      if (!_disposed) {
        issue = PanelAccessIssue.signOutFailed;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
