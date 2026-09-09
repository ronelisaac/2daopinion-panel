import 'package:flutter/foundation.dart';
import '../domain/clinic.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/clinic_repository.dart';

class ClinicController extends ChangeNotifier {
  ClinicController(this.repository, this.principal, this.country);
  final ClinicRepository repository;
  final PanelPrincipal principal;
  final String country;
  List<Clinic> records = [];
  String? nextCursor;
  ClinicIssue? issue;
  bool busy = false;
  bool _disposed = false;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.clinics);
  bool get canManage =>
      allowed && principal.rolesFor(country).contains(PanelRole.superadmin);

  Future<void> load({bool more = false}) async {
    if (busy || _disposed || (more && nextCursor == null)) return;
    await _perform(() async {
      if (!allowed) throw const ClinicFailure(ClinicIssue.denied);
      final page = await repository.list(
        country,
        cursor: more ? nextCursor : null,
      );
      if (!_disposed) {
        records = more ? [...records, ...page.items] : page.items;
        nextCursor = page.nextCursor;
      }
    }, clearOnError: true);
  }

  Future<bool> save(ClinicInput input, {Clinic? previous}) =>
      _perform(() async {
        if (!canManage || (previous != null && previous.country != country)) {
          throw const ClinicFailure(ClinicIssue.denied);
        }
        if (!input.valid ||
            (previous != null && input.code != previous.input.code)) {
          throw const ClinicFailure(ClinicIssue.invalid);
        }
        await repository.save(country, input, previous: previous);
      });

  Future<bool> setActive(Clinic previous, bool active) => _perform(() async {
    if (!canManage || previous.country != country) {
      throw const ClinicFailure(ClinicIssue.denied);
    }
    if (previous.active == active) {
      throw const ClinicFailure(ClinicIssue.invalid);
    }
    await repository.setActive(previous, active);
  });

  Future<bool> _perform(
    Future<void> Function() action, {
    bool clearOnError = false,
  }) async {
    if (busy || _disposed) return false;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await action();
      return !_disposed;
    } catch (error) {
      if (!_disposed) {
        issue = error is ClinicFailure ? error.issue : ClinicIssue.unavailable;
        if (clearOnError) {
          records = [];
          nextCursor = null;
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
    records = [];
    super.dispose();
  }
}
