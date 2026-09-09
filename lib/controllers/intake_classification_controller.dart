import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/intake_classification.dart';
import '../domain/panel_access.dart';
import '../domain/specialty.dart';
import '../domain/repositories/intake_classification_repository.dart';
import '../domain/repositories/specialty_repository.dart';

class IntakeClassificationController extends ChangeNotifier {
  IntakeClassificationController(
    this.repository,
    this.catalog,
    this.principal,
    this.country,
    this.id,
  );
  final IntakeClassificationRepository repository;
  final SpecialtyRepository catalog;
  final PanelPrincipal principal;
  final String country;
  final String id;
  IntakeClassification? record;
  ClassificationIssue? issue;
  bool busy = false, catalogBusy = false, catalogFailed = false;
  bool _disposed = false;
  List<Specialty> specialties = [];
  String? cursor;
  String? _requestId, _retryKey;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.requests);
  bool get canSave =>
      !_disposed &&
      !busy &&
      !catalogBusy &&
      allowed &&
      record?.editable == true &&
      ![
        ClassificationIssue.denied,
        ClassificationIssue.conflict,
        ClassificationIssue.limit,
      ].contains(issue);
  Future<void> load() async {
    if (_disposed || busy) return;
    busy = true;
    issue = null;
    record = null;
    _requestId = null;
    _retryKey = null;
    notifyListeners();
    try {
      if (!allowed) {
        throw const ClassificationFailure(ClassificationIssue.denied);
      }
      final result = await repository.get(country, id);
      if (!_disposed) record = result;
    } catch (error) {
      if (!_disposed) {
        issue = error is ClassificationFailure
            ? error.issue
            : ClassificationIssue.unavailable;
      }
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadSpecialties({bool more = false}) async {
    if (_disposed || catalogBusy || busy || (more && cursor == null)) return;
    catalogBusy = true;
    catalogFailed = false;
    if (!more) {
      specialties = [];
      cursor = null;
    }
    notifyListeners();
    try {
      if (!allowed) throw const SpecialtyFailure(SpecialtyIssue.denied);
      final page = await catalog.list(country, cursor: more ? cursor : null);
      if (!_disposed) {
        specialties = {
          ...{for (final item in specialties) item.id: item},
          ...{
            for (final item in page.items.where(
              (item) => item.active && item.country == country,
            ))
              item.id: item,
          },
        }.values.toList();
        cursor = page.nextCursor;
      }
    } catch (_) {
      if (!_disposed) {
        specialties = [];
        cursor = null;
        catalogFailed = true;
      }
    } finally {
      if (!_disposed) {
        catalogBusy = false;
        notifyListeners();
      }
    }
  }

  Future<bool> save(ClassificationInput input) async {
    if (!canSave) return false;
    if (!input.valid ||
        (input.source != ClassificationSource.unconfirmed &&
            (catalogFailed ||
                !specialties.any((item) => item.id == input.specialtyId)))) {
      issue = ClassificationIssue.invalid;
      notifyListeners();
      return false;
    }
    final key = '${record!.revision}|${input.source.name}|${input.specialtyId}';
    if (_requestId == null || _retryKey != key) {
      final random = Random.secure();
      _requestId = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      _retryKey = key;
    }
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await repository.save(country, record!, input, _requestId!);
      return !_disposed;
    } catch (error) {
      if (!_disposed) {
        issue = error is ClassificationFailure
            ? error.issue
            : ClassificationIssue.unavailable;
        if (issue == ClassificationIssue.denied) {
          record = null;
          specialties = [];
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
    record = null;
    specialties = [];
    super.dispose();
  }
}
