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
import 'package:segunda_opinion_panel/repositories/firebase_intake_repository.dart';
import 'package:segunda_opinion_panel/domain/intake_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FirebaseCoreWeb.registerWith(webPluginRegistrar);
  FirebaseAuthWeb.registerWith(webPluginRegistrar);
  FirebaseFirestoreWeb.registerWith(webPluginRegistrar);
  webPluginRegistrar.registerMessageHandler();
  test(
    'actual panel adapter reads patient reception and bounded pages; countries and revocation enforced',
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
      final fixture = await auth.createUserWithEmailAndPassword(
        email: 'intake-${DateTime.now().microsecondsSinceEpoch}@example.test',
        password: 'Test-only-Intake-391!',
      );
      final uid = fixture.user!.uid;
      final verify = await http.post(
        Uri.parse(
          'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update',
        ),
        headers: {
          'Authorization': 'Bearer owner',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'localId': uid, 'emailVerified': true}),
      );
      expect(verify.statusCode, 200);
      await auth.currentUser!.reload();
      await auth.currentUser!.getIdToken(true);
      Future<void> put(String path, Map<String, dynamic> fields) async {
        final response = await http.patch(
          Uri.parse(
            'http://127.0.0.1:8080/v1/projects/demo-2daopinion/databases/(default)/documents/$path',
          ),
          headers: {
            'Authorization': 'Bearer owner',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'fields': fields}),
        );
        expect(response.statusCode, 200);
      }

      Map<String, dynamic> staff(bool active) => {
        'uid': {'stringValue': uid},
        'active': {'booleanValue': active},
        'provisioning': {'stringValue': 'ready'},
        'memberships': {
          'mapValue': {
            'fields': {
              'CL': {
                'arrayValue': {
                  'values': [
                    {'stringValue': 'operations'},
                  ],
                },
              },
            },
          },
        },
      };
      await put('panelStaff/$uid', staff(true));
      final repository = FirebaseIntakeRepository(
        database: () => database,
        auth: () => auth,
        initialize: () async {},
      );
      final received = await repository.list(const IntakeQuery());
      expect(
        received.items.length,
        1,
        reason:
            'The preceding patient integration must create a real emulated reception.',
      );
      final patientRequest = received.items.single;
      expect(patientRequest.status, IntakeStatus.received);
      expect((await repository.get(patientRequest.id)).id, patientRequest.id);
      expect(patientRequest.documents, isEmpty);
      await expectLater(
        database.collection('consultationSubmissions').limit(1).get(),
        throwsA(isA<FirebaseException>()),
      );
      for (var index = 0; index < 17; index++) {
        final id = 'Fixture${index.toString().padLeft(13, '0')}';
        await put('intakeRequests/$id', {
          'id': {'stringValue': id},
          'countryCode': {'stringValue': 'CL'},
          'status': {'stringValue': 'received'},
          'mode': {'stringValue': 'document_review'},
          'environment': {'stringValue': 'development'},
          'createdAt': {
            'timestampValue': DateTime.utc(
              2026,
              1,
              1,
            ).add(Duration(minutes: index)).toIso8601String(),
          },
        });
      }
      final first = await repository.list(const IntakeQuery());
      final second = await repository.list(const IntakeQuery(page: 1));
      final last = await repository.list(const IntakeQuery(page: 2));
      expect(first.items.length, 8);
      expect(second.items.length, 8);
      expect(last.items.length, 2);
      expect(first.hasMore, true);
      expect(last.hasMore, false);
      expect(
        {
          ...first.items,
          ...second.items,
          ...last.items,
        }.map((item) => item.id).toSet().length,
        18,
      );
      expect(
        (await repository.list(
          IntakeQuery(search: patientRequest.reference),
        )).items.single.id,
        patientRequest.id,
      );
      expect(
        (await repository.list(
          const IntakeQuery(status: IntakeStatus.reviewing),
        )).items,
        isEmpty,
      );
      await expectLater(
        repository.list(const IntakeQuery(countryCode: 'AR')),
        throwsA(isA<IntakeFailure>()),
      );
      await put('panelStaff/$uid', staff(false));
      await expectLater(
        repository.get(patientRequest.id),
        throwsA(isA<IntakeFailure>()),
      );
      await auth.signOut();
      await expectLater(
        repository.list(const IntakeQuery()),
        throwsA(isA<IntakeFailure>()),
      );
    },
  );
}
