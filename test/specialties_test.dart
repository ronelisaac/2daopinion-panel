import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/specialty_controller.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/specialty.dart';
import 'package:segunda_opinion_panel/domain/repositories/specialty_repository.dart';
import 'package:segunda_opinion_panel/widgets/specialty_editor.dart';
import 'fake_identity.dart';

PanelPrincipal principal(PanelRole role, {String country = 'CL'}) =>
    PanelPrincipal(id: 'tester', roles: {role}, countries: {country});
Specialty record({bool active = true, String country = 'CL'}) => Specialty(
  id: '${country}_qa',
  country: country,
  input: SpecialtyInput('qa', 'Especialidad ficticia', ''),
  active: active,
  revision: 1,
  updatedAt: DateTime.utc(2026, 9, 9),
);

class TestSpecialties implements SpecialtyRepository {
  List<Specialty> records = [];
  SpecialtyIssue? failure;
  Completer<SpecialtyPage>? pending;
  String? nextCursor;
  String? lastCursor;
  int writes = 0;
  int reads = 0;
  @override
  Future<SpecialtyPage> list(String country, {String? cursor}) async {
    reads++;
    lastCursor = cursor;
    if (pending != null) return pending!.future;
    if (failure != null) throw SpecialtyFailure(failure!);
    return SpecialtyPage(records, nextCursor);
  }

  @override
  Future<void> save(
    String country,
    SpecialtyInput input, {
    Specialty? previous,
  }) async {
    writes++;
    if (failure != null) throw SpecialtyFailure(failure!);
  }

  @override
  Future<void> setActive(Specialty previous, bool active) async {
    writes++;
    if (failure != null) throw SpecialtyFailure(failure!);
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
  TestSpecialties repository,
  PanelRole role,
) async {
  await tester.pumpWidget(
    PanelApp(
      identity: FakeIdentity(current: principal(role)),
      specialtyRepository: repository,
    ),
  );
  await tester.pumpAndSettle();
  Navigator.of(
    tester.element(find.byType(Scaffold).first),
  ).pushNamed('/specialties');
  await tester.pumpAndSettle();
}

void main() {
  test('input normalization, types and exact boundaries', () {
    final input = SpecialtyInput(' QA_12 ', ' Nombre ', ' Descripción ');
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
      expect(SpecialtyInput(code, 'Nombre', '').valid, isFalse);
    }
    expect(SpecialtyInput('a' * 32, 'ab', 'a' * 500).valid, isTrue);
    expect(SpecialtyInput('qa', 'a' * 100, '').valid, isTrue);
    expect(SpecialtyInput('qa', 'a' * 101, '').valid, isFalse);
    expect(SpecialtyInput('qa', 'Nombre', 'a' * 501).valid, isFalse);
    expect(SpecialtyInput('qa', '   ', '').valid, isFalse);
    expect(SpecialtyInput('qa', '😀' * 100, '').valid, isTrue);
  });
  test(
    'only superadmin manages, country and inactive principal are guarded',
    () async {
      final repository = TestSpecialties();
      for (final role in PanelRole.values) {
        final controller = SpecialtyController(
          repository,
          principal(role),
          'CL',
        );
        expect(controller.canManage, role == PanelRole.superadmin);
        expect(
          await controller.save(SpecialtyInput('qa', 'Nombre', '')),
          role == PanelRole.superadmin,
        );
        controller.dispose();
      }
      final foreign = SpecialtyController(
        repository,
        principal(PanelRole.superadmin, country: 'AR'),
        'AR',
      );
      await foreign.load();
      expect(foreign.issue, SpecialtyIssue.denied);
      final inactive = SpecialtyController(
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
    expect(
      SpecialtyController(TestSpecialties(), user, 'CL').canManage,
      isFalse,
    );
  });
  test(
    'invalid input, changed code, foreign record and no-op status never write',
    () async {
      final repository = TestSpecialties();
      final controller = SpecialtyController(
        repository,
        principal(PanelRole.superadmin),
        'CL',
      );
      expect(await controller.save(SpecialtyInput('', '', '')), isFalse);
      expect(
        await controller.save(
          SpecialtyInput('other', 'Nombre', ''),
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
    final repository = TestSpecialties()
      ..records = [record()]
      ..nextCursor = 'CL_qa';
    final controller = SpecialtyController(
      repository,
      principal(PanelRole.superadmin),
      'CL',
    );
    await controller.load();
    await controller.load(more: true);
    expect(repository.lastCursor, 'CL_qa');
    expect(controller.records.length, 2);
    repository.failure = SpecialtyIssue.denied;
    await controller.load();
    expect(controller.records, isEmpty);
    expect(controller.nextCursor, isNull);
  });
  test(
    'late results do not restore data after disposal and duplicate loads are ignored',
    () async {
      final repository = TestSpecialties()
        ..pending = Completer<SpecialtyPage>();
      final controller = SpecialtyController(
        repository,
        principal(PanelRole.superadmin),
        'CL',
      );
      final pending = controller.load();
      await controller.load();
      expect(repository.reads, 1);
      controller.dispose();
      repository.pending!.complete(SpecialtyPage([record()], null));
      await pending;
      expect(controller.records, isEmpty);
    },
  );
  test('duplicate and conflict errors remain specific', () async {
    final repository = TestSpecialties();
    final controller = SpecialtyController(
      repository,
      principal(PanelRole.superadmin),
      'CL',
    );
    for (final issue in [SpecialtyIssue.duplicate, SpecialtyIssue.conflict]) {
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
      final repository = TestSpecialties();
      await open(tester, repository, PanelRole.superadmin);
      expect(
        find.text('Todavía no hay especialidades registradas para este país.'),
        findsOneWidget,
      );
      await tap(tester, 'Crear especialidad');
      await tap(tester, 'Guardar especialidad');
      expect(repository.writes, 0);
      expect(find.text('Escribe entre 2 y 100 caracteres.'), findsOneWidget);
      final fields = find.descendant(
        of: find.byType(SpecialtyEditor),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'qa');
      await tester.enterText(fields.at(1), 'Nombre ficticio');
      await tap(tester, 'Guardar especialidad');
      expect(repository.writes, 1);
      repository.records = [record()];
      await tap(tester, 'Actualizar especialidades');
      await tap(tester, 'Editar especialidad');
      expect(
        tester
            .widget<TextFormField>(
              find
                  .descendant(
                    of: find.byType(SpecialtyEditor),
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
        final repository = TestSpecialties()..records = [record()];
        await open(tester, repository, PanelRole.superadmin);
        await tap(tester, 'Desactivar especialidad');
        await tap(tester, 'Cancelar');
        expect(repository.writes, 0);
        await tap(tester, 'Desactivar especialidad');
        await tap(tester, 'Confirmar cambio');
        expect(find.text('Inactiva'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tap(tester, 'Reactivar especialidad');
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
      final repository = TestSpecialties()..records = [record()];
      await open(tester, repository, PanelRole.operations);
      expect(find.text('Crear especialidad'), findsNothing);
      expect(find.text('Editar especialidad'), findsNothing);
      repository.failure = SpecialtyIssue.denied;
      await tap(tester, 'Actualizar especialidades');
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Especialidad ficticia'), findsNothing);
    },
  );
}
