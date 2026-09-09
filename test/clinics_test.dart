import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/clinic_controller.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/clinic.dart';
import 'package:segunda_opinion_panel/domain/repositories/clinic_repository.dart';
import 'package:segunda_opinion_panel/widgets/clinic_editor.dart';
import 'fake_identity.dart';

PanelPrincipal principal(PanelRole role, {String country = 'CL'}) =>
    PanelPrincipal(id: 'tester', roles: {role}, countries: {country});
Clinic record({bool active = true, String country = 'CL'}) => Clinic(
  id: '${country}_qa',
  country: country,
  input: clinicInput('qa', 'Clínica ficticia', ''),
  active: active,
  revision: 1,
  updatedAt: DateTime.utc(2026, 9, 9),
);

class TestClinics implements ClinicRepository {
  List<Clinic> records = [];
  ClinicIssue? failure;
  Completer<ClinicPage>? pending;
  String? nextCursor;
  String? lastCursor;
  int writes = 0;
  int reads = 0;
  @override
  Future<ClinicPage> list(String country, {String? cursor}) async {
    reads++;
    lastCursor = cursor;
    if (pending != null) return pending!.future;
    if (failure != null) throw ClinicFailure(failure!);
    return ClinicPage(records, nextCursor);
  }

  @override
  Future<void> save(
    String country,
    ClinicInput input, {
    Clinic? previous,
  }) async {
    writes++;
    if (failure != null) throw ClinicFailure(failure!);
  }

  @override
  Future<void> setActive(Clinic previous, bool active) async {
    writes++;
    if (failure != null) throw ClinicFailure(failure!);
    records = [record(active: active)];
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
  TestClinics repository,
  PanelRole role,
) async {
  await tester.pumpWidget(
    PanelApp(
      identity: FakeIdentity(current: principal(role)),
      clinicRepository: repository,
    ),
  );
  await tester.pumpAndSettle();
  Navigator.of(
    tester.element(find.byType(Scaffold).first),
  ).pushNamed('/clinics');
  await tester.pumpAndSettle();
}

ClinicInput clinicInput(String code, String name, String description) =>
    ClinicInput(
      code,
      name,
      description,
      city: 'Ciudad ficticia',
      address: 'Dirección ficticia 123',
    );

void main() {
  test('city, address and optional contact validation boundaries', () {
    expect(ClinicInput.validCity('a'), isFalse);
    expect(ClinicInput.validCity('ab'), isTrue);
    expect(ClinicInput.validCity('a' * 101), isFalse);
    expect(ClinicInput.validAddress('abcd'), isFalse);
    expect(ClinicInput.validAddress('abcde'), isTrue);
    expect(ClinicInput.validAddress('a' * 200), isTrue);
    expect(ClinicInput.validAddress('a' * 201), isFalse);
    for (final email in [
      '',
      'QA+contact@example.test',
      'a.b@sub.example.test',
    ]) {
      expect(ClinicInput.validEmail(email), isTrue);
    }
    for (final email in [
      'no@',
      'a..b@example.test',
      'a b@example.test',
      'a@example',
      'a@-example.test',
      '${'a' * 250}@example.test',
    ]) {
      expect(ClinicInput.validEmail(email), isFalse);
    }
    for (final phone in ['', '+12345678', '+123456789012345']) {
      expect(ClinicInput.validPhone(phone), isTrue);
    }
    for (final phone in [
      '12345678',
      '+012345678',
      '+56 12345678',
      '+1234567',
      '+1234567890123456',
    ]) {
      expect(ClinicInput.validPhone(phone), isFalse);
    }
    final normalized = ClinicInput(
      ' QA ',
      ' Nombre ',
      '',
      city: ' Ciudad ',
      address: ' Calle 123 ',
      email: ' Contact@example.test ',
      phone: ' +12345678 ',
    );
    expect(normalized.city, 'Ciudad');
    expect(normalized.address, 'Calle 123');
    expect(normalized.email, 'Contact@example.test');
    expect(normalized.phone, '+12345678');
    expect(normalized.valid, isTrue);
  });
  test('input normalization, types and exact boundaries', () {
    final input = clinicInput(' QA_12 ', ' Nombre ', ' Descripción ');
    expect(input.code, 'qa_12');
    expect(input.name, 'Nombre');
    expect(input.description, 'Descripción');
    expect(input.valid, isTrue);
    for (final code in [
      '',
      'a',
      '12aa',
      'con espacio',
      'clínica',
      '../bad',
      'a' * 33,
    ]) {
      expect(clinicInput(code, 'Nombre', '').valid, isFalse);
    }
    expect(clinicInput('a' * 32, 'ab', 'a' * 500).valid, isTrue);
    expect(clinicInput('qa', 'a' * 100, '').valid, isTrue);
    expect(clinicInput('qa', 'a' * 101, '').valid, isFalse);
    expect(clinicInput('qa', 'Nombre', 'a' * 501).valid, isFalse);
    expect(clinicInput('qa', '   ', '').valid, isFalse);
    expect(clinicInput('qa', '😀' * 100, '').valid, isTrue);
  });
  test(
    'only superadmin manages, country and inactive principal are guarded',
    () async {
      final repository = TestClinics();
      for (final role in PanelRole.values) {
        final controller = ClinicController(repository, principal(role), 'CL');
        expect(controller.canManage, role == PanelRole.superadmin);
        expect(
          await controller.save(clinicInput('qa', 'Nombre', '')),
          role == PanelRole.superadmin,
        );
        controller.dispose();
      }
      final foreign = ClinicController(
        repository,
        principal(PanelRole.superadmin, country: 'AR'),
        'AR',
      );
      await foreign.load();
      expect(foreign.issue, ClinicIssue.denied);
      final inactive = ClinicController(
        repository,
        PanelPrincipal(
          id: 'disabled',
          roles: {PanelRole.superadmin},
          countries: {'CL'},
          active: false,
        ),
        'CL',
      );
      expect(inactive.canManage, isFalse);
    },
  );
  test('country-scoped roles do not leak from another country', () {
    final user = PanelPrincipal(
      id: 'scoped',
      roles: {PanelRole.superadmin, PanelRole.operations},
      countries: {'CL', 'AR'},
      countryRoles: {
        'CL': {PanelRole.operations},
        'AR': {PanelRole.superadmin},
      },
    );
    expect(ClinicController(TestClinics(), user, 'CL').canManage, isFalse);
  });
  test(
    'invalid input, changed code, foreign record and no-op status never write',
    () async {
      final repository = TestClinics();
      final controller = ClinicController(
        repository,
        principal(PanelRole.superadmin),
        'CL',
      );
      expect(await controller.save(clinicInput('', '', '')), isFalse);
      expect(
        await controller.save(
          clinicInput('other', 'Nombre', ''),
          previous: record(),
        ),
        isFalse,
      );
      expect(await controller.setActive(record(country: 'AR'), false), isFalse);
      expect(await controller.setActive(record(), true), isFalse);
      expect(repository.writes, 0);
    },
  );
  test('pagination uses cursor and errors clear stale records', () async {
    final repository = TestClinics()
      ..records = [record()]
      ..nextCursor = 'CL_qa';
    final controller = ClinicController(
      repository,
      principal(PanelRole.superadmin),
      'CL',
    );
    await controller.load();
    await controller.load(more: true);
    expect(repository.lastCursor, 'CL_qa');
    expect(controller.records.length, 2);
    repository.failure = ClinicIssue.denied;
    await controller.load();
    expect(controller.records, isEmpty);
    expect(controller.nextCursor, isNull);
  });
  test(
    'late results do not restore data after disposal and duplicate loads are ignored',
    () async {
      final repository = TestClinics()..pending = Completer<ClinicPage>();
      final controller = ClinicController(
        repository,
        principal(PanelRole.superadmin),
        'CL',
      );
      final pending = controller.load();
      await controller.load();
      expect(repository.reads, 1);
      controller.dispose();
      repository.pending!.complete(ClinicPage([record()], null));
      await pending;
      expect(controller.records, isEmpty);
    },
  );
  test('duplicate and conflict errors remain specific', () async {
    final repository = TestClinics();
    final controller = ClinicController(
      repository,
      principal(PanelRole.superadmin),
      'CL',
    );
    for (final issue in [ClinicIssue.duplicate, ClinicIssue.conflict]) {
      repository.failure = issue;
      expect(await controller.save(record().input), isFalse);
      expect(controller.issue, issue);
    }
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('required form and immutable code at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = TestClinics();
      await open(tester, repository, PanelRole.superadmin);
      expect(
        find.text('Todavía no hay clínicas registradas para este país.'),
        findsOneWidget,
      );
      await tap(tester, 'Crear clínica');
      await tap(tester, 'Guardar clínica');
      expect(repository.writes, 0);
      expect(find.text('Escribe entre 2 y 100 caracteres.'), findsOneWidget);
      final fields = find.descendant(
        of: find.byType(ClinicEditor),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'qa');
      await tester.enterText(fields.at(1), 'Nombre ficticio');
      await tester.enterText(fields.at(2), 'Ciudad ficticia');
      await tester.enterText(fields.at(3), 'Dirección ficticia 123');
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: fields.at(4),
                matching: find.byType(TextField),
              ),
            )
            .keyboardType,
        TextInputType.emailAddress,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: fields.at(5),
                matching: find.byType(TextField),
              ),
            )
            .keyboardType,
        TextInputType.phone,
      );
      await tester.enterText(fields.at(4), 'correo incorrecto');
      await tester.enterText(fields.at(5), '123');
      await tap(tester, 'Guardar clínica');
      expect(repository.writes, 0);
      await tester.enterText(fields.at(4), 'qa@example.test');
      await tester.enterText(fields.at(5), '+12345678');
      await tap(tester, 'Guardar clínica');
      expect(repository.writes, 1);
      repository.records = [record()];
      await tap(tester, 'Actualizar clínicas');
      await tap(tester, 'Editar clínica');
      expect(
        tester
            .widget<TextFormField>(
              find
                  .descendant(
                    of: find.byType(ClinicEditor),
                    matching: find.byType(TextFormField),
                  )
                  .first,
            )
            .enabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'deactivation confirmation, cancel and reactivation at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = TestClinics()..records = [record()];
        await open(tester, repository, PanelRole.superadmin);
        await tap(tester, 'Desactivar clínica');
        await tap(tester, 'Cancelar');
        expect(repository.writes, 0);
        await tap(tester, 'Desactivar clínica');
        await tap(tester, 'Confirmar cambio');
        expect(find.text('Inactiva'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tap(tester, 'Reactivar clínica');
        await tap(tester, 'Confirmar cambio');
        expect(find.text('Activa'), findsOneWidget);
        expect(repository.writes, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'operations reads without write controls and errors offer retry',
    (tester) async {
      final repository = TestClinics()..records = [record()];
      await open(tester, repository, PanelRole.operations);
      expect(find.text('Crear clínica'), findsNothing);
      expect(find.text('Editar clínica'), findsNothing);
      repository.failure = ClinicIssue.denied;
      await tap(tester, 'Actualizar clínicas');
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Clínica ficticia'), findsNothing);
    },
  );
}
