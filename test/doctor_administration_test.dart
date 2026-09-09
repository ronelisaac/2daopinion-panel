import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/doctor_administration_controller.dart';
import 'package:segunda_opinion_panel/controllers/doctor_controller.dart';
import 'package:segunda_opinion_panel/domain/doctor_administration.dart';
import 'package:segunda_opinion_panel/domain/doctor_record.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/repositories/doctor_administration_repository.dart';
import 'package:segunda_opinion_panel/domain/repositories/doctor_repository.dart';
import 'fake_identity.dart';

PanelPrincipal principal([PanelRole role = PanelRole.operations]) =>
    PanelPrincipal(id: 'operator', roles: {role}, countries: {'CL'});

class Records implements DoctorRepository {
  @override
  Future<DoctorPage> list(String country, {String? cursor}) async =>
      DoctorPage([
        DoctorRecord(
          id: 'CL_123',
          country: 'CL',
          input: DoctorInput(
            'Profesional ficticio',
            '123',
            'Especialidad ficticia',
          ),
          status: DoctorStatus.verified,
          revision: 2,
          createdBy: 'creator',
          updatedAt: DateTime.utc(2026),
        ),
      ], null);
  @override
  Future<void> save(
    String country,
    DoctorInput input, {
    DoctorRecord? previous,
  }) async {}
  @override
  Future<void> review(DoctorRecord previous, DoctorReview review) async {}
}

class Administration implements DoctorAdministrationRepository {
  DoctorAdministration state = const DoctorAdministration(
    id: 'CL_123',
    active: true,
    revision: 0,
  );
  DoctorAdministrationIssue? failure;
  Completer<void>? pending;
  final requests = <String>[];
  @override
  Future<List<DoctorAdministration>> list(
    String country,
    List<String> ids,
  ) async {
    if (failure != null) throw DoctorAdministrationFailure(failure!);
    return ids.isEmpty ? [] : [state];
  }

  @override
  Future<void> setActive(
    String country,
    DoctorAdministration previous,
    bool active,
    String reason,
    String requestId,
  ) async {
    requests.add(requestId);
    if (pending != null) await pending!.future;
    if (failure != null) throw DoctorAdministrationFailure(failure!);
    state = DoctorAdministration(
      id: previous.id,
      active: active,
      revision: previous.revision + 1,
      reason: reason,
      updatedAt: DateTime.utc(2026),
    );
  }
}

void main() {
  test('reason is required with matching trimmed Unicode limits', () {
    for (final value in ['', '       ', 'a' * 9, 'a' * 501, '😀' * 501]) {
      expect(DoctorAdministration.validReason(value), false);
    }
    for (final value in [
      'a' * 10,
      'a' * 500,
      '😀' * 500,
      '  a long reason  ',
    ]) {
      expect(DoctorAdministration.validReason(value), true);
    }
  });
  test(
    'operations and superadmin in CL can change administration, never professional review',
    () async {
      for (final role in PanelRole.values.where(
        (role) => role != PanelRole.operations && role != PanelRole.superadmin,
      )) {
        final repository = Administration();
        final controller = DoctorAdministrationController(
          repository,
          principal(role),
          'CL',
          repository.state,
        );
        expect(await controller.save('Reason for administration'), false);
        expect(repository.requests, isEmpty);
        controller.dispose();
      }
      final repository = Administration();
      final controller = DoctorAdministrationController(
        repository,
        principal(),
        'AR',
        repository.state,
      );
      expect(controller.allowed, false);
      controller.dispose();
    },
  );
  test(
    'invalid inputs do not write, uncertain retry retains id, conflict disables save',
    () async {
      final repository = Administration();
      final controller = DoctorAdministrationController(
        repository,
        principal(),
        'CL',
        repository.state,
      );
      addTearDown(controller.dispose);
      expect(await controller.save(' '), false);
      expect(repository.requests, isEmpty);
      repository.failure = DoctorAdministrationIssue.unavailable;
      expect(await controller.save('  Administrative reason  '), false);
      repository.failure = null;
      expect(await controller.save('Administrative reason'), true);
      expect(repository.requests[0], repository.requests[1]);
      expect(repository.state.active, false);
      expect(repository.state.reason, 'Administrative reason');
      expect(repository.requests[0], matches(RegExp(r'^[a-f0-9]{32}$')));
      final stale = DoctorAdministrationController(
        repository,
        principal(),
        'CL',
        repository.state,
      );
      repository.failure = DoctorAdministrationIssue.conflict;
      expect(await stale.save('Another valid reason'), false);
      expect(stale.canSave, false);
      stale.dispose();
    },
  );
  test('disposing pending save ignores delayed UI results', () async {
    final repository = Administration()..pending = Completer<void>();
    final controller = DoctorAdministrationController(
      repository,
      principal(),
      'CL',
      repository.state,
    );
    final saving = controller.save('Administrative reason');
    controller.dispose();
    repository.pending!.complete();
    expect(await saving, false);
  });
  test(
    'list joins current state and clears stale records on administrative denial',
    () async {
      final repository = Administration();
      final controller = DoctorController(
        Records(),
        principal(),
        'CL',
        administrationRepository: repository,
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.administration['CL_123']!.active, true);
      repository.failure = DoctorAdministrationIssue.denied;
      await controller.load();
      expect(controller.records, isEmpty);
      expect(controller.administration, isEmpty);
      expect(controller.issue, DoctorIssue.denied);
    },
  );
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('required reason, pause and reactivate at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = Administration();
      await tester.pumpWidget(
        PanelApp(
          identity: FakeIdentity(current: principal()),
          doctorRepository: Records(),
          administrationRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed('/doctors');
      await tester.pumpAndSettle();
      expect(find.text('Administración: activa'), findsOneWidget);
      Future<void> tap(String label) async {
        final target = find.text(label).last;
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tap('Pausar ficha');
      await tap('Confirmar cambio');
      expect(find.textContaining('Escribe un motivo'), findsOneWidget);
      expect(repository.requests, isEmpty);
      await tester.enterText(
        find.byType(TextFormField).last,
        'Pausa ficticia de prueba',
      );
      await tap('Confirmar cambio');
      expect(find.text('Administración: pausada'), findsOneWidget);
      expect(repository.state.active, false);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tap('Reactivar ficha');
      expect(find.textContaining('Último motivo registrado:'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).last,
        'Reactivación ficticia de prueba',
      );
      await tap('Confirmar cambio');
      expect(find.text('Administración: activa'), findsOneWidget);
      expect(repository.state.revision, 2);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('director sees administrative state but cannot pause', (
    tester,
  ) async {
    await tester.pumpWidget(
      PanelApp(
        identity: FakeIdentity(current: principal(PanelRole.medicalDirector)),
        doctorRepository: Records(),
        administrationRepository: Administration(),
      ),
    );
    await tester.pumpAndSettle();
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).pushNamed('/doctors');
    await tester.pumpAndSettle();
    expect(find.text('Administración: activa'), findsOneWidget);
    expect(find.text('Pausar ficha'), findsNothing);
  });
}
