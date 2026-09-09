import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/intake_assignment.dart';
import '../domain/panel_access.dart';
import '../domain/repositories/intake_assignment_repository.dart';

class IntakeAssignmentController extends ChangeNotifier {
  IntakeAssignmentController(
    this.repository,
    this.principal,
    this.country,
    this.id,
  );
  final IntakeAssignmentRepository repository;
  final PanelPrincipal principal;
  final String country, id;
  IntakeAssignment? record;
  AssignmentIssue? issue;
  List<AssignmentCandidate> candidates = [];
  String? cursor;
  bool busy = false, _disposed = false;
  String? _requestId, _retryKey;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.requests);
  bool get canOperate =>
      allowed && PanelAccess.hasRole(principal, country, PanelRole.operations);
  bool get canEdit =>
      !_disposed &&
      !busy &&
      canOperate &&
      record != null &&
      ![
        AssignmentIssue.denied,
        AssignmentIssue.conflict,
        AssignmentIssue.limit,
      ].contains(issue);
  Future<void> load() async {
    if (_disposed || busy) return;
    record = null;
    candidates = [];
    cursor = null;
    _requestId = null;
    _retryKey = null;
    await _perform(() async {
      record = await repository.get(country, id);
    });
  }

  Future<void> loadCandidates({bool more = false}) async {
    if (!canEdit || record?.canAssign != true || (more && cursor == null)) {
      return;
    }
    if (!more) {
      candidates = [];
      cursor = null;
    }
    await _perform(() async {
      final page = await repository.candidates(
        country,
        record!,
        cursor: more ? cursor : null,
      );
      candidates = {
        ...{for (final item in candidates) item.id: item},
        ...{for (final item in page.items) item.id: item},
      }.values.toList();
      cursor = page.nextCursor;
    }, clearCandidates: true);
  }

  Future<bool> save({
    String? doctorId,
    AssignmentReason? reason,
    required bool confirmed,
  }) async {
    if (!canEdit) return false;
    if (!confirmed ||
        (reason == null
            ? record?.canAssign != true ||
                  !candidates.any((item) => item.id == doctorId)
            : record?.canRelease != true || doctorId != null)) {
      issue = AssignmentIssue.invalid;
      notifyListeners();
      return false;
    }
    final key =
        '${record!.revision}|${record!.classificationRevision}|$doctorId|$reason';
    if (_requestId == null || _retryKey != key) {
      final random = Random.secure();
      _requestId = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      _retryKey = key;
    }
    return _perform(() async {
      if (reason == null) {
        await repository.assign(country, record!, doctorId!, _requestId!);
      } else {
        await repository.release(country, record!, reason, _requestId!);
      }
    });
  }

  Future<bool> _perform(
    Future<void> Function() action, {
    bool clearCandidates = false,
  }) async {
    if (_disposed || busy) return false;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      if (!allowed) throw const AssignmentFailure(AssignmentIssue.denied);
      await action();
      return !_disposed;
    } catch (error) {
      if (!_disposed) {
        issue = error is AssignmentFailure
            ? error.issue
            : AssignmentIssue.unavailable;
        if (clearCandidates ||
            issue == AssignmentIssue.denied ||
            issue == AssignmentIssue.conflict) {
          candidates = [];
          cursor = null;
        }
        if (issue == AssignmentIssue.denied) record = null;
      }
      return false;
    } finally {
      if (_disposed) {
        record = null;
        candidates = [];
        cursor = null;
      } else {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    record = null;
    candidates = [];
    super.dispose();
  }
}
