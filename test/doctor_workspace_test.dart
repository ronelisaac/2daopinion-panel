import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/doctor_workspace_controller.dart';
import 'package:segunda_opinion_panel/domain/doctor_workspace.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/repositories/doctor_workspace_repository.dart';
import 'fake_identity.dart';

PanelPrincipal user([PanelRole role = PanelRole.doctor]) =>
    PanelPrincipal(id: 'fictitious-doctor', roles: {role}, countries: {'CL'});
DoctorWorkspace ready({bool accepting = false, int revision = 0}) =>
    DoctorWorkspace(
      state: WorkspaceState.ready,
      accepting: accepting,
      revision: revision,
      token: 'a' * 64,
      name: 'Profesional ficticio',
      registry: '123',
      specialty: 'Especialidad ficticia',
    );

class WorkspaceRepository implements DoctorWorkspaceRepository {
  DoctorWorkspace value = ready();
  WorkspaceIssue? failure;
  Completer<DoctorWorkspace>? pending;
  int reads = 0;
  final requests = <String>[];
  @override
  Future<DoctorWorkspace> read(String country) async {
    reads++;
    if (pending != null) return pending!.future;
    if (failure != null) throw WorkspaceFailure(failure!);
    return value;
  }

  @override
  Future<void> save(
    String country,
    DoctorWorkspace previous,
    bool accepting,
    String requestId,
  ) async {
    requests.add(requestId);
    if (failure != null) throw WorkspaceFailure(failure!);
    value = ready(accepting: accepting, revision: previous.revision + 1);
  }
}

void main() {
  test(
    'workspace is doctor-only, does not inherit superadmin, enforces country',
    () async {
      for (final role in PanelRole.values.where(
        (role) => role != PanelRole.doctor,
      )) {
        final repository = WorkspaceRepository();
        final controller = DoctorWorkspaceController(
          repository,
          user(role),
          'CL',
        );
        await controller.load();
        expect(controller.issue, WorkspaceIssue.denied);
        expect(repository.reads, 0);
        expect(await controller.save(), false);
        controller.dispose();
      }
      final controller = DoctorWorkspaceController(
        WorkspaceRepository(),
        user(),
        'AR',
      );
      expect(controller.allowed, false);
      controller.dispose();
    },
  );
  test(
    'save requires ready state and a change, refreshes authoritative state',
    () async {
      final repository = WorkspaceRepository();
      final controller = DoctorWorkspaceController(repository, user(), 'CL');
      addTearDown(controller.dispose);
      expect(await controller.save(), false);
      await controller.load();
      expect(await controller.save(), false);
      controller.select(true);
      expect(await controller.save(), true);
      expect(controller.workspace!.accepting, true);
      expect(controller.workspace!.revision, 1);
      expect(repository.requests.single, matches(RegExp(r'^[a-f0-9]{32}$')));
      controller.select(false);
      expect(await controller.save(), true);
      expect(controller.workspace!.accepting, false);
    },
  );
  test(
    'uncertain retry keeps operation id and permission errors clear data',
    () async {
      final repository = WorkspaceRepository();
      final controller = DoctorWorkspaceController(repository, user(), 'CL');
      addTearDown(controller.dispose);
      await controller.load();
      controller.select(true);
      repository.failure = WorkspaceIssue.unavailable;
      expect(await controller.save(), false);
      expect(controller.workspace, isNotNull);
      repository.failure = null;
      expect(await controller.save(), true);
      expect(repository.requests[0], repository.requests[1]);
      repository.failure = WorkspaceIssue.denied;
      controller.select(false);
      expect(await controller.save(), false);
      expect(controller.workspace, isNull);
      expect(controller.issue, WorkspaceIssue.denied);
    },
  );
  test('blocked, unlinked and disposed controllers cannot persist', () async {
    for (final state in [WorkspaceState.blocked, WorkspaceState.unlinked]) {
      final repository = WorkspaceRepository()
        ..value = DoctorWorkspace(state: state, accepting: false, revision: 0);
      final controller = DoctorWorkspaceController(repository, user(), 'CL');
      await controller.load();
      controller.select(true);
      expect(await controller.save(), false);
      expect(repository.requests, isEmpty);
      controller.dispose();
    }
    final repository = WorkspaceRepository()
      ..pending = Completer<DoctorWorkspace>();
    final controller = DoctorWorkspaceController(repository, user(), 'CL');
    final loading = controller.load();
    controller.dispose();
    repository.pending!.complete(ready());
    await loading;
    expect(controller.workspace, isNull);
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets(
      'doctor workspace responsive save and empty/error states at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = WorkspaceRepository();
        await tester.pumpWidget(
          PanelApp(
            identity: FakeIdentity(current: user()),
            workspaceRepository: repository,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Profesional ficticio'), findsOneWidget);
        final toggle = find.byType(SwitchListTile);
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        final save = find.text('Guardar disponibilidad');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(repository.value.accepting, true);
        expect(find.textContaining('Preferencia guardada'), findsOneWidget);
        repository.value = const DoctorWorkspace(
          state: WorkspaceState.unlinked,
          accepting: false,
          revision: 1,
        );
        final refresh = find.text('Actualizar mi espacio');
        await tester.ensureVisible(refresh);
        await tester.tap(refresh);
        await tester.pumpAndSettle();
        expect(find.text('Vinculación pendiente'), findsOneWidget);
        repository.failure = WorkspaceIssue.denied;
        await tester.tap(refresh);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('No tienes permisos vigentes'),
          findsOneWidget,
        );
        expect(find.text('Profesional ficticio'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
