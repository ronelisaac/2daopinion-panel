import 'package:flutter/foundation.dart';
import '../domain/doctor_record.dart';
import '../domain/doctor_administration.dart';
import '../domain/repositories/doctor_administration_repository.dart';
import '../domain/panel_access.dart';
import '../domain/specialty.dart';
import '../domain/repositories/specialty_repository.dart';
import '../domain/repositories/doctor_repository.dart';

class DoctorController extends ChangeNotifier {
  DoctorController(
    this.repository,
    this.principal,
    this.country, {
    this.specialtyRepository,
    this.administrationRepository,
  });
  final SpecialtyRepository? specialtyRepository;
  final DoctorAdministrationRepository? administrationRepository;
  Map<String, DoctorAdministration> administration = {};
  List<Specialty> specialties = [];
  String? specialtyCursor;
  bool catalogBusy = false;
  bool catalogFailed = false;

  Future<void> loadSpecialties({bool more = false}) async {
    if (_disposed || catalogBusy || (more && specialtyCursor == null)) return;
    catalogBusy = true;
    catalogFailed = false;
    if (!more) {
      specialties = [];
      specialtyCursor = null;
    }
    notifyListeners();
    try {
      if (!canRegister || specialtyRepository == null) {
        throw const DoctorFailure(DoctorIssue.denied);
      }
      final page = await specialtyRepository!.list(
        country,
        cursor: more ? specialtyCursor : null,
      );
      if (!_disposed) {
        specialties = [
          ...specialties,
          ...page.items.where((item) => item.active && item.country == country),
        ];
        specialtyCursor = page.nextCursor;
      }
    } catch (_) {
      if (!_disposed) {
        specialties = [];
        specialtyCursor = null;
        catalogFailed = true;
      }
    } finally {
      if (!_disposed) {
        catalogBusy = false;
        notifyListeners();
      }
    }
  }

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
      allowed && PanelAccess.hasRole(principal, country, PanelRole.operations);
  bool canReview(DoctorRecord record) =>
      allowed &&
      record.country == country &&
      (principal.rolesFor(country).contains(PanelRole.superadmin) ||
          (record.createdBy != principal.id &&
              principal.rolesFor(country).contains(PanelRole.medicalDirector)));

  Future<void> load({bool more = false}) async {
    if (busy || _disposed || (more && nextCursor == null)) return;
    await _perform(() async {
      if (!allowed) throw const DoctorFailure(DoctorIssue.denied);
      final page = await repository.list(
        country,
        cursor: more ? nextCursor : null,
      );
      final states = administrationRepository == null
          ? <DoctorAdministration>[]
          : await administrationRepository!.list(
              country,
              page.items.map((record) => record.id).toList(),
            );
      if (!_disposed) {
        administration = {
          ...(more ? administration : <String, DoctorAdministration>{}),
          for (final state in states) state.id: state,
        };
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
            !input.linked ||
            (previous != null && input.registry != previous.input.registry)) {
          throw const DoctorFailure(DoctorIssue.invalid);
        }
        await repository.save(country, input, previous: previous);
      });

  Future<bool> review(DoctorRecord previous, DoctorReview review) =>
      _perform(() async {
        if (!canReview(previous)) throw const DoctorFailure(DoctorIssue.denied);
        if (review.status == DoctorStatus.verified && !previous.input.linked) {
          throw const DoctorFailure(DoctorIssue.specialtyUnavailable);
        }
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
        issue = error is DoctorFailure
            ? error.issue
            : error is DoctorAdministrationFailure &&
                  error.issue == DoctorAdministrationIssue.denied
            ? DoctorIssue.denied
            : DoctorIssue.unavailable;
        if (clearOnError) {
          records = [];
          administration = {};
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
    administration = {};
    specialties = [];
    super.dispose();
  }
}
