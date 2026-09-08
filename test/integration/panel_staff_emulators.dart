import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_web/cloud_functions_web.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_panel/repositories/firebase_panel_staff_repository.dart';
import 'package:segunda_opinion_panel/domain/panel_staff.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFunctionsWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'Flutter invokes the actual callable for list/create/edit/disable and denies signed-out access',
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
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-west1',
      );
      functions.useFunctionsEmulator('127.0.0.1', 5001);
      final repository = FirebasePanelStaffRepository(
        functions: () => functions,
        initialize: () async {},
      );
      await expectLater(repository.list('CL'), throwsA(isA<StaffFailure>()));
      final fixture = await auth.createUserWithEmailAndPassword(
        email: 'callable-root@example.test',
        password: 'Test-only-Panel-391!',
      );
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
        ),
        headers: {
          'Authorization': 'Bearer owner',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'localId': fixture.user!.uid,
          'emailVerified': true,
          'customAttributes': jsonEncode({
            'panelAccess': {
              'version': 1,
              'active': true,
              'memberships': {
                'CL': ['superadmin'],
              },
            },
          }),
        }),
      );
      expect(response.statusCode, 200);
      await auth.currentUser!.reload();
      await auth.currentUser!.getIdToken(true);
      final initial = await repository.list('CL');
      expect(initial.users.length, 1);
      expect(initial.users.single.editable, isFalse);
      await repository.mutate({
        'action': 'create',
        'country': 'CL',
        'requestId': '1' * 32,
        'name': 'Equipo integración',
        'email': 'callable-staff@example.test',
        'memberships': {
          'CL': ['doctor'],
        },
      });
      final page = await repository.list('CL');
      final staff = page.users.singleWhere(
        (user) => user.email == 'callable-staff@example.test',
      );
      expect(staff.pending, isFalse);
      expect(staff.editable, isTrue);
      await repository.mutate({
        'action': 'update',
        'country': 'CL',
        'requestId': '2' * 32,
        'uid': staff.uid,
        'revision': 1,
        'name': 'Nombre actualizado',
        'memberships': {
          'CL': ['finance'],
        },
      });
      await repository.mutate({
        'action': 'setActive',
        'country': 'CL',
        'requestId': '3' * 32,
        'uid': staff.uid,
        'revision': 2,
        'active': false,
      });
      expect(
        (await repository.list(
          'CL',
        )).users.singleWhere((user) => user.uid == staff.uid).active,
        isFalse,
      );
      await auth.signOut();
      await expectLater(repository.list('CL'), throwsA(isA<StaffFailure>()));
    },
  );
}
