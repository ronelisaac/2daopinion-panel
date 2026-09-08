import 'package:flutter/foundation.dart';
import '../domain/intake_request.dart';
import '../domain/repositories/intake_repository.dart';

class IntakeDetailController extends ChangeNotifier {
  IntakeDetailController(this._repository, this.id);
  final IntakeRepository _repository;
  final String id;
  IntakeRequest? request;
  IntakeIssue? issue;
  bool busy = false;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed || busy) return;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      final loaded = await _repository.get(id);
      if (!_disposed) request = loaded;
    } catch (error) {
      if (!_disposed) {
        request = null;
        issue = error is IntakeFailure ? error.issue : IntakeIssue.unavailable;
      }
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
    request = null;
    super.dispose();
  }
}
