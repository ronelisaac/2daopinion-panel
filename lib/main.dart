import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'repositories/firebase_intake_repository.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'repositories/firebase_panel_identity_repository.dart';
import 'repositories/firebase_panel_staff_repository.dart';

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
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: false,
        );
        FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
        await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
        FirebaseFunctions.instanceFor(
          region: 'southamerica-west1',
        ).useFunctionsEmulator('127.0.0.1', 5001);
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
      repository: const bool.fromEnvironment('USE_FIREBASE_EMULATORS')
          ? FirebaseIntakeRepository(
              database: () => FirebaseFirestore.instance,
              auth: () => FirebaseAuth.instance,
              initialize: initialize,
            )
          : null,
      staffRepository: FirebasePanelStaffRepository(
        functions: () =>
            FirebaseFunctions.instanceFor(region: 'southamerica-west1'),
        initialize: initialize,
      ),
      identity: FirebasePanelIdentityRepository(
        auth: () => FirebaseAuth.instance,
        initialize: initialize,
      ),
    ),
  );
}
