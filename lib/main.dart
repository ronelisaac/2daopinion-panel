import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'repositories/firebase_panel_identity_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future<void>? initialization;
  Future<void> initialize() => initialization ??= (() async {
    try {
      const emulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
      if (emulators && !kDebugMode) {
        throw StateError('Emulators require debug.');
      }
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: emulators
              ? const FirebaseOptions(
                  apiKey: 'demo-key',
                  appId: '1:123456789:web:panel',
                  messagingSenderId: '123456789',
                  projectId: 'demo-2daopinion',
                )
              : PanelFirebaseOptions.web,
        );
      }
      if (emulators) {
        await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      }
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
      }
    } catch (_) {
      initialization = null;
      rethrow;
    }
  })();
  runApp(
    PanelApp(
      identity: FirebasePanelIdentityRepository(
        auth: () => FirebaseAuth.instance,
        initialize: initialize,
      ),
    ),
  );
}
