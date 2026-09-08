import 'package:firebase_auth/firebase_auth.dart';
import '../domain/panel_access.dart';
import '../domain/panel_claims.dart';
import '../domain/repositories/panel_identity_repository.dart';

class FirebasePanelIdentityRepository implements PanelIdentityRepository {
  FirebasePanelIdentityRepository({
    required FirebaseAuth Function() auth,
    required this.initialize,
  }) : _auth = auth;
  final FirebaseAuth Function() _auth;
  final Future<void> Function() initialize;
  bool _signingIn = false;
  PanelAccessFailure _failure(Object error) {
    if (error is PanelAccessFailure) return error;
    if (error is FirebaseAuthException) {
      return PanelAccessFailure(switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-email' ||
        'user-disabled' => PanelAccessIssue.invalidCredentials,
        'too-many-requests' => PanelAccessIssue.tooManyRequests,
        _ => PanelAccessIssue.unavailable,
      });
    }
    return const PanelAccessFailure(PanelAccessIssue.unavailable);
  }

  Future<PanelPrincipal> _principal(User user, {bool refresh = false}) async {
    final token = await user.getIdTokenResult(refresh);
    if (_auth().currentUser?.uid != user.uid) {
      throw const PanelAccessFailure(PanelAccessIssue.denied);
    }
    return principalFromClaims(
      user.uid,
      token.claims?['email_verified'] == true,
      token.claims,
    );
  }

  @override
  Stream<PanelPrincipal?> watch() async* {
    await initialize();
    yield* _auth().idTokenChanges().asyncMap((user) async {
      if (user == null) return null;
      if (_signingIn) return null;
      try {
        return await _principal(user);
      } catch (_) {
        await _auth().signOut();
        return null;
      }
    });
  }

  @override
  Future<PanelPrincipal> signIn(String email, String password) async {
    _signingIn = true;
    try {
      await initialize();
      final result = await _auth().signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) {
        throw const PanelAccessFailure(PanelAccessIssue.invalidCredentials);
      }
      return await _principal(user, refresh: true);
    } catch (error) {
      try {
        await _auth().signOut();
      } catch (_) {}
      throw _failure(error);
    } finally {
      _signingIn = false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await initialize();
      await _auth().sendPasswordResetEmail(email: email.trim());
    } catch (error) {
      if (error is FirebaseAuthException && error.code == 'user-not-found') {
        return;
      }
      throw _failure(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await initialize();
      await _auth().signOut();
    } catch (error) {
      throw _failure(error);
    }
  }
}
