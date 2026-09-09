import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:segunda_opinion_panel/domain/clinic.dart';
import 'package:segunda_opinion_panel/repositories/firebase_clinic_repository.dart';

ClinicInput clinicInput(String code, String name, String description) =>
    ClinicInput(
      code,
      name,
      description,
      city: 'Ciudad ficticia',
      address: 'Dirección ficticia 123',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'real adapter persists CRUD, detects conflicts, paginates and enforces read-only access',
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
      final database = FirebaseFirestore.instance;
      await auth.useAuthEmulator('127.0.0.1', 9099);
      database.settings = const Settings(persistenceEnabled: false);
      database.useFirestoreEmulator('127.0.0.1', 8080);
      final repository = FirebaseClinicRepository(
        database: () => database,
        auth: () => auth,
        initialize: () async {},
      );
      final suffix = DateTime.now().microsecondsSinceEpoch;
      const password = 'Only-emulator-Clinic-482!';
      for (final role in ['superadmin', 'operations']) {
        final user = await auth.createUserWithEmailAndPassword(
          email: '$role-$suffix@example.test',
          password: password,
        );
        final uid = user.user!.uid;
        final updated = await http.post(
          Uri.parse(
            'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
          ),
          headers: {
            'Authorization': 'Bearer owner',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'localId': uid,
            'emailVerified': true,
            'customAttributes': jsonEncode({
              'panelAccess': {
                'version': 1,
                'active': true,
                'memberships': {
                  'CL': [role],
                },
              },
            }),
          }),
        );
        expect(updated.statusCode, 200);
        final staff = await http.patch(
          Uri.parse(
            'http://127.0.0.1:8080/v1/projects/demo-2daopinion/databases/(default)/documents/panelStaff/$uid',
          ),
          headers: {
            'Authorization': 'Bearer owner',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fields': {
              'active': {'booleanValue': true},
              'provisioning': {'stringValue': 'ready'},
              'memberships': {
                'mapValue': {
                  'fields': {
                    'CL': {
                      'arrayValue': {
                        'values': [
                          {'stringValue': role},
                        ],
                      },
                    },
                  },
                },
              },
            },
          }),
        );
        expect(staff.statusCode, 200);
        await auth.signOut();
      }
      Future<void> login(String role) async {
        await auth.signOut();
        await auth.signInWithEmailAndPassword(
          email: '$role-$suffix@example.test',
          password: password,
        );
      }

      Matcher failure(ClinicIssue issue) =>
          isA<ClinicFailure>().having((error) => error.issue, 'issue', issue);
      await login('superadmin');
      final code = 'it_$suffix';
      final input = clinicInput(code, 'Clínica de integración', '');
      await repository.save('CL', input);
      await expectLater(
        repository.save('CL', input),
        throwsA(failure(ClinicIssue.duplicate)),
      );
      final first = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.input.code == code);
      expect(first.revision, 1);
      await repository.save(
        'CL',
        clinicInput(code, 'Nombre corregido', 'Descripción ficticia'),
        previous: first,
      );
      await expectLater(
        repository.save('CL', input, previous: first),
        throwsA(failure(ClinicIssue.conflict)),
      );
      var current = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.id == first.id);
      await repository.setActive(current, false);
      current = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.id == first.id);
      expect(current.active, isFalse);
      await repository.setActive(current, true);
      await login('operations');
      current = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.id == first.id);
      expect(current.active, isTrue);
      expect(current.revision, 4);
      expect(current.input.name, 'Nombre corregido');
      await expectLater(
        repository.setActive(current, false),
        throwsA(failure(ClinicIssue.denied)),
      );
      final events = await database
          .collection('clinics')
          .doc(first.id)
          .collection('events')
          .limit(50)
          .get();
      expect(events.docs.length, 4);
      expect(events.docs.last.data()['action'], 'reactivate');
      await login('superadmin');
      for (var index = 0; index < 21; index++) {
        await repository.save(
          'CL',
          clinicInput(
            '${code}_${index.toString().padLeft(2, '0')}',
            'Página ficticia $index',
            '',
          ),
        );
      }
      final firstPage = await repository.list('CL');
      expect(firstPage.items.length, 20);
      expect(firstPage.nextCursor, isNotNull);
      final secondPage = await repository.list(
        'CL',
        cursor: firstPage.nextCursor,
      );
      expect(secondPage.items, isNotEmpty);
      expect(
        firstPage.items
            .map((item) => item.id)
            .toSet()
            .intersection(secondPage.items.map((item) => item.id).toSet()),
        isEmpty,
      );
      await auth.signOut();
      await expectLater(
        repository.list('CL'),
        throwsA(failure(ClinicIssue.denied)),
      );
    },
  );
}
