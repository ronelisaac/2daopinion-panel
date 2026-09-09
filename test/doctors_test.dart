import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/doctor_controller.dart';
import 'package:segunda_opinion_panel/domain/doctor_record.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/repositories/doctor_repository.dart';
import 'package:segunda_opinion_panel/widgets/doctor_editor.dart';
import 'package:segunda_opinion_panel/widgets/doctor_review_editor.dart';
import 'fake_identity.dart';

PanelPrincipal principal(
  PanelRole role, {
  String id = 'operator',
  String country = 'CL',
}) => PanelPrincipal(id: id, roles: {role}, countries: {country});
DoctorRecord record({
  DoctorStatus status = DoctorStatus.pending,
  String creator = 'operator',
}) => DoctorRecord(
  id: 'CL_123',
  country: 'CL',
  input: DoctorInput('Nombre ficticio', '123', 'Especialidad ficticia'),
  status: status,
  revision: 1,
  createdBy: creator,
  updatedAt: DateTime.utc(2026, 9, 9),
);
DoctorReview review({bool checked = true}) => DoctorReview(
  status: DoctorStatus.verified,
  evidence: 'FICTICIO-1',
  note: 'Revisión ficticia sin uso clínico',
  identityChecked: checked,
  titleChecked: checked,
  specialtyChecked: checked,
);

class TestDoctors implements DoctorRepository {
  List<DoctorRecord> records = [];
  DoctorIssue? failure;
  Completer<DoctorPage>? pending;
  int writes = 0;
  int reads = 0;
  @override
  Future<DoctorPage> list(String country, {String? cursor}) async {
    reads++;
    if (pending != null) return pending!.future;
    if (failure != null) throw DoctorFailure(failure!);
    return DoctorPage(records, null);
  }

  @override
  Future<void> save(
    String country,
    DoctorInput input, {
    DoctorRecord? previous,
  }) async {
    writes++;
    if (failure != null) throw DoctorFailure(failure!);
  }

  @override
  Future<void> review(DoctorRecord previous, DoctorReview review) async {
    writes++;
    if (failure != null) throw DoctorFailure(failure!);
  }
}

Future<void> tap(WidgetTester tester, String text) async {
  final target = find.text(text).last;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> open(
  WidgetTester tester,
  TestDoctors repository,
  PanelPrincipal user,
) async {
  await tester.pumpWidget(
    PanelApp(
      identity: FakeIdentity(current: user),
      doctorRepository: repository,
    ),
  );
  await tester.pumpAndSettle();
  final context = tester.element(find.byType(Scaffold).first);
  Navigator.of(context).pushNamed('/doctors');
  await tester.pumpAndSettle();
}

void main() {
  test('typed normalized registration validates exact boundaries', () {
    final input = DoctorInput(' Nombre ', '123', ' Clínica ');
    expect(input.name, 'Nombre');
    expect(input.valid, isTrue);
    for (final number in [
      '',
      '0123',
      '1.2',
      '1e3',
      '-1',
      '12345678901',
      'abc',
    ]) {
      expect(DoctorInput('Nombre', number, 'Clínica').valid, isFalse);
    }
    expect(DoctorInput('x' * 120, '1234567890', 'x' * 120).valid, isTrue);
    expect(DoctorInput('x' * 121, '123', 'Clínica').valid, isFalse);
    expect(DoctorInput('   ', '123', 'Clínica').valid, isFalse);
  });
  test('approval requires evidence, rationale and every manual check', () {
    expect(review().valid, isTrue);
    expect(review(checked: false).valid, isFalse);
    expect(
      DoctorReview(
        status: DoctorStatus.rejected,
        evidence: 'ref',
        note: 'short',
        identityChecked: false,
        titleChecked: false,
        specialtyChecked: false,
      ).valid,
      isFalse,
    );
  });
  test('verification transitions cannot bypass correction or suspension', () {
    expect(record().permits(DoctorStatus.verified), isTrue);
    expect(
      record(status: DoctorStatus.rejected).permits(DoctorStatus.verified),
      isFalse,
    );
    expect(record(status: DoctorStatus.verified).editable, isFalse);
    expect(
      record(status: DoctorStatus.verified).permits(DoctorStatus.suspended),
      isTrue,
    );
  });
  test(
    'controller blocks other country, wrong role and self review before repository',
    () async {
      final repository = TestDoctors();
      final operations = DoctorController(
        repository,
        principal(PanelRole.operations),
        'CL',
      );
      final medical = DoctorController(
        repository,
        principal(PanelRole.medicalDirector),
        'CL',
      );
      final argentina = DoctorController(
        repository,
        principal(PanelRole.operations, country: 'AR'),
        'AR',
      );
      addTearDown(operations.dispose);
      addTearDown(medical.dispose);
      addTearDown(argentina.dispose);
      expect(await operations.review(record(), review()), isFalse);
      expect(await medical.review(record(), review()), isFalse);
      expect(await medical.save(record().input), isFalse);
      await argentina.load();
      expect(repository.reads, 0);
      expect(repository.writes, 0);
    },
  );
  test(
    'invalid values and changed registry are blocked before writes',
    () async {
      final repository = TestDoctors();
      final controller = DoctorController(
        repository,
        principal(PanelRole.operations),
        'CL',
      );
      addTearDown(controller.dispose);
      expect(await controller.save(DoctorInput('', '123', 'abc')), isFalse);
      expect(
        await controller.save(
          DoctorInput('Nombre', '124', 'abc'),
          previous: record(),
        ),
        isFalse,
      );
      expect(repository.writes, 0);
      expect(await controller.save(record().input), isTrue);
    },
  );
  test(
    'conflict preserved and revoked read clears previously visible records',
    () async {
      final repository = TestDoctors()..records = [record()];
      final controller = DoctorController(
        repository,
        principal(PanelRole.operations),
        'CL',
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.records.length, 1);
      repository.failure = DoctorIssue.conflict;
      expect(
        await controller.save(record().input, previous: record()),
        isFalse,
      );
      expect(controller.issue, DoctorIssue.conflict);
      repository.failure = DoctorIssue.denied;
      await controller.load();
      expect(controller.records, isEmpty);
    },
  );
  test('late reads cannot restore records after disposal', () async {
    final repository = TestDoctors()..pending = Completer<DoctorPage>();
    final controller = DoctorController(
      repository,
      principal(PanelRole.operations),
      'CL',
    );
    final pending = controller.load();
    controller.dispose();
    repository.pending!.complete(DoctorPage([record()], null));
    await pending;
    expect(controller.records, isEmpty);
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('registration required fields and numeric input at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = TestDoctors();
      await open(tester, repository, principal(PanelRole.operations));
      expect(
        find.text('Todavía no hay médicos registrados para este país.'),
        findsOneWidget,
      );
      await tap(tester, 'Registrar médico');
      await tap(tester, 'Guardar registro');
      expect(repository.writes, 0);
      expect(
        find.text('Introduce de 1 a 10 dígitos, sin ceros iniciales.'),
        findsOneWidget,
      );
      final fields = find.descendant(
        of: find.byType(DoctorEditor),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'Médico ficticio');
      await tester.enterText(fields.at(1), '12abc3');
      expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text,
        '123',
      );
      await tester.enterText(fields.at(2), 'Especialidad ficticia');
      await tap(tester, 'Guardar registro');
      expect(repository.writes, 1);
      expect(tester.takeException(), isNull);
    });
    testWidgets('review controls and required checks at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = TestDoctors()..records = [record()];
      await open(
        tester,
        repository,
        principal(PanelRole.medicalDirector, id: 'director'),
      );
      expect(find.text('Registrar médico'), findsNothing);
      await tap(tester, 'Registrar revisión');
      await tap(tester, 'Guardar revisión');
      expect(repository.writes, 0);
      expect(
        find.text('Para aprobar, confirma las tres comprobaciones.'),
        findsOneWidget,
      );
      final fields = find.descendant(
        of: find.byType(DoctorReviewEditor),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'FICTICIO-1');
      await tester.enterText(fields.at(1), 'Revisión ficticia sin uso clínico');
      for (final label in [
        'Identidad contrastada',
        'Título profesional contrastado',
        'Especialidad y su vigencia contrastadas',
      ]) {
        await tap(tester, label);
      }
      await tap(tester, 'Guardar revisión');
      expect(repository.writes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
