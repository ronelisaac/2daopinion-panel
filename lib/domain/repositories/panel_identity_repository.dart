import '../panel_access.dart';

abstract interface class PanelIdentityRepository {
  Stream<PanelPrincipal?> watch();
  Future<PanelPrincipal> signIn(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
