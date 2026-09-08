import 'dart:async';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/repositories/panel_identity_repository.dart';

class FakeIdentity implements PanelIdentityRepository {
  FakeIdentity({this.current});
  PanelPrincipal? current;
  final changes = StreamController<PanelPrincipal?>.broadcast();
  PanelAccessIssue? failure;
  int signIns = 0;
  int resets = 0;
  @override
  Stream<PanelPrincipal?> watch() async* {
    yield current;
    yield* changes.stream;
  }

  @override
  Future<PanelPrincipal> signIn(String email, String password) async {
    signIns++;
    if (failure != null) throw PanelAccessFailure(failure!);
    current = PanelPrincipal(
      id: 'verified-test-admin',
      roles: {PanelRole.superadmin},
      countries: {'CL'},
    );
    changes.add(current);
    return current!;
  }

  @override
  Future<void> signOut() async {
    current = null;
    changes.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    resets++;
  }
}
