import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/panel_staff_controller.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/panel_staff.dart';
import 'package:segunda_opinion_panel/domain/repositories/panel_staff_repository.dart';
import 'package:segunda_opinion_panel/widgets/staff_editor.dart';
import 'fake_identity.dart';

final principal = PanelPrincipal(
  id: 'admin',
  roles: {PanelRole.superadmin},
  countries: {'CL'},
);
PanelStaff member({bool editable = true}) => PanelStaff(
  uid: 'member',
  name: 'Equipo de prueba',
  email: 'member@example.test',
  memberships: {
    'CL': {PanelRole.doctor},
  },
  active: true,
  verified: false,
  editable: editable,
  revision: 1,
  pending: false,
  invitationSent: true,
);

class TestStaffRepository implements PanelStaffRepository {
  final commands = <Map<String, Object?>>[];
  StaffIssue? failure;
  int reads = 0;
  Completer<StaffPage>? pending;
  bool readOnly = false;
  @override
  Future<StaffPage> list(String country, {String? cursor}) async {
    reads++;
    if (pending != null) return pending!.future;
    if (failure != null) throw StaffFailure(failure!);
    return StaffPage([member(editable: !readOnly)], null);
  }

  @override
  Future<bool> mutate(Map<String, Object?> command) async {
    commands.add(Map.of(command));
    if (failure != null) throw StaffFailure(failure!);
    return true;
  }
}

Future<void> tapText(WidgetTester tester, String label) async {
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'retry after an uncertain write uses the same idempotency key',
    () async {
      final repository = TestStaffRepository()
        ..failure = StaffIssue.unavailable;
      final controller = PanelStaffController(repository, principal, 'CL');
      addTearDown(controller.dispose);
      Future<bool> save() => controller.save(
        name: ' Equipo ',
        email: 'USER@EXAMPLE.TEST',
        memberships: {
          'CL': {PanelRole.doctor},
        },
      );
      expect(await save(), isFalse);
      repository.failure = null;
      expect(await save(), isTrue);
      expect(
        repository.commands[0]['requestId'],
        repository.commands[1]['requestId'],
      );
      expect(repository.commands[0]['email'], 'user@example.test');
      expect(controller.invitationSent, isTrue);
    },
  );
  test(
    'failed reads clear users; disposal ignores in-flight responses',
    () async {
      final repository = TestStaffRepository();
      final controller = PanelStaffController(repository, principal, 'CL');
      await controller.load();
      expect(controller.users.length, 1);
      repository.failure = StaffIssue.denied;
      await controller.load();
      expect(controller.users, isEmpty);
      repository.failure = null;
      repository.pending = Completer<StaffPage>();
      final loading = controller.load();
      controller.dispose();
      repository.pending!.complete(StaffPage([member()], null));
      await loading;
      expect(controller.users, isEmpty);
    },
  );
  for (final width in [320.0, 1440.0]) {
    testWidgets(
      'real user editor validates and submits role/country at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final repository = TestStaffRepository();
        await tester.pumpWidget(
          PanelApp(
            identity: FakeIdentity(current: principal),
            staffRepository: repository,
          ),
        );
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed('/users');
        await tester.pumpAndSettle();
        expect(find.text('Equipo de prueba'), findsOneWidget);
        await tapText(tester, 'Crear usuario');
        expect(find.byType(StaffEditor), findsOneWidget);
        await tapText(tester, 'Crear y enviar acceso');
        expect(repository.commands, isEmpty);
        final inputs = find.descendant(
          of: find.byType(StaffEditor),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(inputs.first, 'Nuevo equipo');
        await tester.enterText(inputs.last, 'new@example.test');
        await tapText(tester, 'Médico');
        await tapText(tester, 'Crear y enviar acceso');
        expect(repository.commands.single['action'], 'create');
        expect(repository.commands.single['memberships'], {
          'CL': ['doctor'],
        });
        expect(find.byType(StaffEditor), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'deactivation requires confirmation and no destructive delete is offered',
    (tester) async {
      final repository = TestStaffRepository();
      await tester.pumpWidget(
        PanelApp(
          identity: FakeIdentity(current: principal),
          staffRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/users');
      await tester.pumpAndSettle();
      await tapText(tester, 'Desactivar acceso');
      expect(repository.commands, isEmpty);
      await tapText(tester, 'Cancelar');
      expect(repository.commands, isEmpty);
      await tapText(tester, 'Desactivar acceso');
      await tapText(tester, 'Confirmar');
      expect(repository.commands.single['active'], isFalse);
      expect(find.text('Eliminar usuario'), findsNothing);
    },
  );
  testWidgets('own and protected accounts expose no edit buttons', (
    tester,
  ) async {
    final repository = TestStaffRepository()..readOnly = true;
    await tester.pumpWidget(
      PanelApp(
        identity: FakeIdentity(current: principal),
        staffRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/users');
    await tester.pumpAndSettle();
    expect(find.text('Editar usuario'), findsNothing);
    expect(find.text('Desactivar acceso'), findsNothing);
  });
}
