import 'package:flutter/foundation.dart';
import '../domain/doctor_record.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/doctor_repository.dart';

class DoctorController extends ChangeNotifier {
  DoctorController(this.repository, this.principal, this.country);
  final DoctorRepository repository;
  final PanelPrincipal principal;
  final String country;
  List<DoctorRecord> records = [];
  String? nextCursor;
  DoctorIssue? issue;
  bool busy = false;
  bool _disposed = false;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.doctors);
  bool get canRegister =>
      allowed && principal.rolesFor(country).contains(PanelRole.operations);
  bool canReview(DoctorRecord record) =>
      allowed &&
      record.country == country &&
      record.createdBy != principal.id &&
      principal.rolesFor(country).contains(PanelRole.medicalDirector);

  Future<void> load({bool more = false}) async {
    if (busy || _disposed || (more && nextCursor == null)) return;
    await _perform(() async {
      if (!allowed) throw const DoctorFailure(DoctorIssue.denied);
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

  Future<bool> save(DoctorInput input, {DoctorRecord? previous}) =>
      _perform(() async {
        if (!canRegister ||
            (previous != null &&
                (previous.country != country || !previous.editable))) {
          throw const DoctorFailure(DoctorIssue.denied);
        }
        if (!input.valid ||
            (previous != null && input.registry != previous.input.registry)) {
          throw const DoctorFailure(DoctorIssue.invalid);
        }
        await repository.save(country, input, previous: previous);
      });

  Future<bool> review(DoctorRecord previous, DoctorReview review) =>
      _perform(() async {
        if (!canReview(previous)) throw const DoctorFailure(DoctorIssue.denied);
        if (!review.valid || !previous.permits(review.status)) {
          throw const DoctorFailure(DoctorIssue.invalid);
        }
        await repository.review(previous, review);
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
        issue = error is DoctorFailure ? error.issue : DoctorIssue.unavailable;
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
