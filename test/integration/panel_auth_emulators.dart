import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/repositories/firebase_panel_identity_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'Firebase adapter signs in, restores, logs out, resets and denies nonstaff',
    () async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-key',
          appId: '1:123456789:web:panel',
          messagingSenderId: '123456789',
          projectId: 'demo-2daopinion',
        ),
      );
      final auth = FirebaseAuth.instance;
      await auth.useAuthEmulator('127.0.0.1', 9099);
      await auth.setPersistence(Persistence.SESSION);
      final repository = FirebasePanelIdentityRepository(
        auth: () => auth,
        initialize: () async {},
      );
      final email =
          'panel-${DateTime.now().microsecondsSinceEpoch}@example.test';
      const password = 'Fictitious-Panel-938!';
      final fixture = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = fixture.user!.uid;
      Future<void> update(Map<String, dynamic> fields) async {
        final response = await http.post(
          Uri.parse(
            'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
          ),
          headers: {
            'Authorization': 'Bearer owner',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'localId': uid, ...fields}),
        );
        expect(response.statusCode, 200);
      }

      await auth.signOut();
      await expectLater(
        repository.signIn(email, password),
        throwsA(isA<PanelAccessFailure>()),
      );
      expect(auth.currentUser, isNull);
      await update({'emailVerified': true});
      await expectLater(
        repository.signIn(email, password),
        throwsA(isA<PanelAccessFailure>()),
      );
      expect(auth.currentUser, isNull);
      await update({
        'customAttributes': jsonEncode({
          'panelAccess': {
            'version': 1,
            'active': true,
            'memberships': {
              'CL': ['superadmin'],
              'AR': ['finance'],
            },
          },
        }),
      });
      final principal = await repository.signIn(email, password);
      expect(principal.id, uid);
      expect(PanelAccess.allows(principal, 'CL', PanelModule.users), isTrue);
      expect(PanelAccess.allows(principal, 'AR', PanelModule.users), isFalse);
      expect((await repository.watch().first)!.id, uid);
      await repository.signOut();
      expect(auth.currentUser, isNull);
      await expectLater(
        repository.signIn(email, 'wrong-password'),
        throwsA(isA<PanelAccessFailure>()),
      );
      await repository.resetPassword(email);
      final oob = await http.get(
        Uri.parse(
          'http://127.0.0.1:9099/emulator/v1/projects/demo-2daopinion/oobCodes',
        ),
      );
      expect(oob.statusCode, 200);
      expect(
        (jsonDecode(oob.body)['oobCodes'] as List).any(
          (code) =>
              code['email'] == email && code['requestType'] == 'PASSWORD_RESET',
        ),
        isTrue,
      );
      await update({'disableUser': true});
      await expectLater(
        repository.signIn(email, password),
        throwsA(isA<PanelAccessFailure>()),
      );
      expect(auth.currentUser, isNull);
    },
  );
}
