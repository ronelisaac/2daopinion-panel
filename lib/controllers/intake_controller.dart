import 'package:flutter/foundation.dart';
import '../domain/intake_request.dart';
import '../domain/repositories/intake_repository.dart';

class IntakeController extends ChangeNotifier {
  IntakeController(this._repository);
  final IntakeRepository _repository;
  IntakeQuery query = const IntakeQuery();
  IntakePage? result;
  IntakeIssue? issue;
  bool busy = false;
  bool _disposed = false;
  int _request = 0;

  bool get hasNext =>
      result != null &&
      (result!.hasMore ??
          ((query.page + 1) * IntakeQuery.pageSize < (result!.total ?? 0)));

  Future<void> load({
    String? search,
    IntakeStatus? status,
    bool changeStatus = false,
    int? page,
  }) async {
    if (_disposed) return;
    final request = ++_request;
    query = IntakeQuery(
      search: search ?? query.search,
      status: changeStatus ? status : query.status,
      page: search != null || changeStatus ? 0 : page ?? query.page,
    );
    busy = true;
    issue = null;
    result = null;
    notifyListeners();
    try {
      final loaded = await _repository.list(query);
      if (_disposed || request != _request) return;
      result = loaded;
    } catch (error) {
      if (_disposed || request != _request) return;
      issue = error is IntakeFailure ? error.issue : IntakeIssue.unavailable;
    } finally {
      if (!_disposed && request == _request) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    result = null;
    super.dispose();
  }
}
