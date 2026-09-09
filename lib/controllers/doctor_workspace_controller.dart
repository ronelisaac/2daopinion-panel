import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/panel_access.dart';
import '../domain/doctor_workspace.dart';
import '../domain/repositories/doctor_workspace_repository.dart';

class DoctorWorkspaceController extends ChangeNotifier {
  DoctorWorkspaceController(this.repository, this.principal, this.country);
  final DoctorWorkspaceRepository repository;
  final PanelPrincipal principal;
  final String country;
  DoctorWorkspace? workspace;
  WorkspaceIssue? issue;
  bool busy = false;
  bool accepting = false;
  bool _disposed = false;
  String? _requestId;
  bool? _retryAccepting;
  bool get allowed =>
      country == 'CL' &&
      PanelAccess.allows(principal, country, PanelModule.doctorWorkspace);
  void select(bool value) {
    if (busy || _disposed || workspace?.state != WorkspaceState.ready) return;
    accepting = value;
    notifyListeners();
  }

  Future<void> load() async {
    if (busy || _disposed) return;
    busy = true;
    issue = null;
    workspace = null;
    _requestId = null;
    notifyListeners();
    try {
      if (!allowed) throw const WorkspaceFailure(WorkspaceIssue.denied);
      final value = await repository.read(country);
      if (!_disposed) {
        workspace = value;
        accepting = value.accepting;
      }
    } catch (error) {
      if (!_disposed) {
        issue = error is WorkspaceFailure
            ? error.issue
            : WorkspaceIssue.unavailable;
      }
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<bool> save() async {
    final previous = workspace;
    if (busy ||
        _disposed ||
        !allowed ||
        previous?.state != WorkspaceState.ready ||
        previous?.token == null ||
        accepting == previous!.accepting) {
      return false;
    }
    if (_requestId == null || _retryAccepting != accepting) {
      final random = Random.secure();
      _requestId = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      _retryAccepting = accepting;
    }
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await repository.save(country, previous, accepting, _requestId!);
      final value = await repository.read(country);
      if (_disposed) return false;
      workspace = value;
      accepting = value.accepting;
      _requestId = null;
      return true;
    } catch (error) {
      if (!_disposed) {
        issue = error is WorkspaceFailure
            ? error.issue
            : WorkspaceIssue.unavailable;
        if (issue != WorkspaceIssue.unavailable) {
          workspace = null;
          _requestId = null;
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
    workspace = null;
    _requestId = null;
    super.dispose();
  }
}
