import '../domain/panel_access.dart';
import '../domain/intake_request.dart';
import '../domain/repositories/intake_repository.dart';

class ScopedIntakeRepository implements IntakeRepository {
  ScopedIntakeRepository(this._delegate, this.actor, this.country);
  final IntakeRepository _delegate;
  final PanelPrincipal actor;
  final String country;
  void _check() {
    if (!PanelAccess.allows(actor, country, PanelModule.requests)) {
      throw const IntakeFailure(IntakeIssue.unavailable);
    }
  }

  @override
  Future<IntakePage> list(IntakeQuery query) async {
    _check();
    return _delegate.list(
      IntakeQuery(
        search: query.search,
        status: query.status,
        page: query.page,
        countryCode: country,
      ),
    );
  }

  @override
  Future<IntakeRequest> get(String id) async {
    _check();
    final result = await _delegate.get(id);
    if (result.countryCode != country) {
      throw const IntakeFailure(IntakeIssue.notFound);
    }
    return result;
  }
}
