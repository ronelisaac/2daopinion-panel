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
import 'package:segunda_opinion_panel/domain/doctor_record.dart';
import 'package:segunda_opinion_panel/repositories/firebase_doctor_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'actual adapter persists registration, revision and independent review with immutable events',
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
      final repository = FirebaseDoctorRepository(
        database: () => database,
        auth: () => auth,
        initialize: () async {},
      );
      final suffix = DateTime.now().microsecondsSinceEpoch;
      const password = 'Only-emulator-Doctor-482!';
      final identities = <String, String>{};
      for (final role in ['operations', 'medicalDirector']) {
        final email = '$role-$suffix@example.test';
        final user = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = user.user!.uid;
        identities[role] = uid;
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

      final seeded = await http.patch(
        Uri.parse(
          'http://127.0.0.1:8080/v1/projects/demo-2daopinion/databases/(default)/documents/specialties/CL_qa_specialty',
        ),
        headers: {
          'Authorization': 'Bearer owner',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fields': {
            'countryCode': {'stringValue': 'CL'},
            'active': {'booleanValue': true},
            'name': {'stringValue': 'Especialidad ficticia'},
          },
        }),
      );
      expect(seeded.statusCode, 200);
      await login('operations');
      final registry = '${1000000000 + suffix % 9000000000}';
      final input = DoctorInput(
        'Médico ficticio integración',
        registry,
        'Especialidad ficticia',
        specialtyId: 'CL_qa_specialty',
      );
      await repository.save('CL', input);
      await expectLater(
        repository.save('CL', input),
        throwsA(
          isA<DoctorFailure>().having(
            (error) => error.issue,
            'issue',
            DoctorIssue.duplicate,
          ),
        ),
      );
      final first = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.input.registry == registry);
      expect(first.revision, 1);
      expect(first.status, DoctorStatus.pending);
      await repository.save(
        'CL',
        DoctorInput(
          'Nombre ficticio corregido',
          registry,
          'Especialidad ficticia',
          specialtyId: 'CL_qa_specialty',
        ),
        previous: first,
      );
      await expectLater(
        repository.save('CL', input, previous: first),
        throwsA(
          isA<DoctorFailure>().having(
            (error) => error.issue,
            'issue',
            DoctorIssue.conflict,
          ),
        ),
      );
      await login('medicalDirector');
      final current = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.id == first.id);
      await repository.review(
        current,
        DoctorReview(
          status: DoctorStatus.verified,
          evidence: 'FICTICIO-E214',
          note: 'Revisión ficticia independiente, no clínica.',
          identityChecked: true,
          titleChecked: true,
          specialtyChecked: true,
        ),
      );
      await login('operations');
      final approved = (await repository.list(
        'CL',
      )).items.singleWhere((item) => item.id == first.id);
      expect(approved.status, DoctorStatus.verified);
      expect(approved.revision, 3);
      expect(approved.reviewedBy, identities['medicalDirector']);
      expect(approved.reviewedAt, isNotNull);
      final history = await database
          .collection('doctorRecords')
          .doc(first.id)
          .collection('events')
          .limit(50)
          .get();
      expect(history.docs.length, 3);
      await auth.signOut();
      await expectLater(repository.list('CL'), throwsA(isA<DoctorFailure>()));
    },
  );
}
