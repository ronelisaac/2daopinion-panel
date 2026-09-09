import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/controllers/intake_assignment_controller.dart';
import 'package:segunda_opinion_panel/domain/intake_assignment.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/repositories/intake_assignment_repository.dart';
import 'package:segunda_opinion_panel/widgets/intake_assignment_card.dart';
import 'package:segunda_opinion_panel/widgets/intake_assignment_editor.dart';
import 'package:segunda_opinion_panel/core/app_theme.dart';
import 'package:segunda_opinion_panel/l10n/app_localizations.dart';

class Repository implements IntakeAssignmentRepository {
  AssignmentIssue? failure;
  final requests = <String>[];
  bool empty = false;
  Completer<IntakeAssignment>? waiting;
  IntakeAssignment current = record();
  static IntakeAssignment record([
    AssignmentStatus status = AssignmentStatus.unassigned,
  ]) => IntakeAssignment(
    id: 'a' * 20,
    revision: status == AssignmentStatus.unassigned ? 0 : 1,
    status: status,
    classificationRevision: 1,
    canAssign: status != AssignmentStatus.pendingAcceptance,
    canRelease: status == AssignmentStatus.pendingAcceptance,
    doctorName: status == AssignmentStatus.unassigned
        ? null
        : 'Profesional ficticio',
    specialtyName: 'Especialidad ficticia',
  );
  @override
  Future<IntakeAssignment> get(String country, String id) async {
    if (failure != null) throw AssignmentFailure(failure!);
    return waiting?.future ?? current;
  }

  @override
  Future<AssignmentCandidates> candidates(
    String country,
    IntakeAssignment previous, {
    String? cursor,
  }) async {
    if (failure != null) throw AssignmentFailure(failure!);
    return AssignmentCandidates(
      empty
          ? []
          : [
              const AssignmentCandidate(
                'CL_123',
                'Profesional ficticio',
                '123',
              ),
            ],
      null,
    );
  }

  @override
  Future<void> assign(
    String country,
    IntakeAssignment previous,
    String doctorId,
    String requestId,
  ) async {
    requests.add(requestId);
    if (failure != null) throw AssignmentFailure(failure!);
    current = record(AssignmentStatus.pendingAcceptance);
  }

  @override
  Future<void> release(
    String country,
    IntakeAssignment previous,
    AssignmentReason reason,
    String requestId,
  ) async {
    requests.add(requestId);
    if (failure != null) throw AssignmentFailure(failure!);
    current = record(AssignmentStatus.released);
  }
}

IntakeAssignmentController controller(
  Repository repository, {
  PanelRole role = PanelRole.operations,
}) => IntakeAssignmentController(
  repository,
  PanelPrincipal(id: 'operator', roles: {role}, countries: {'CL'}),
  'CL',
  'a' * 20,
);
Widget app(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test(
    'selection and confirmation required; retry preserves command; revoked data discarded',
    () async {
      final repository = Repository(), state = controller(Repository());
      state.dispose();
      final current = controller(repository);
      await current.load();
      await current.loadCandidates();
      expect(
        await current.save(doctorId: 'CL_wrong', confirmed: true),
        isFalse,
      );
      expect(await current.save(doctorId: 'CL_123', confirmed: false), isFalse);
      repository.failure = AssignmentIssue.unavailable;
      expect(await current.save(doctorId: 'CL_123', confirmed: true), isFalse);
      expect(await current.save(doctorId: 'CL_123', confirmed: true), isFalse);
      expect(repository.requests.toSet().length, 1);
      repository.failure = AssignmentIssue.denied;
      await current.save(doctorId: 'CL_123', confirmed: true);
      expect(current.record, isNull);
      expect(current.candidates, isEmpty);
      current.dispose();
    },
  );
  test(
    'superadmin can manage; late loads disposed; release and reload update state',
    () async {
      final denied = controller(Repository(), role: PanelRole.superadmin);
      await denied.load();
      expect(denied.issue, isNull);
      expect(denied.record, isNotNull);
      expect(denied.canEdit, isTrue);
      denied.dispose();
      final repository = Repository()
            ..current = Repository.record(AssignmentStatus.pendingAcceptance),
          state = controller(repository);
      await state.load();
      expect(
        await state.save(
          reason: AssignmentReason.wrongSelection,
          confirmed: true,
        ),
        isTrue,
      );
      await state.load();
      expect(state.record!.status, AssignmentStatus.released);
      repository.waiting = Completer<IntakeAssignment>();
      final loading = state.load();
      state.dispose();
      repository.waiting!.complete(Repository.record());
      await loading;
      expect(state.record, isNull);
    },
  );
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('assignment states and errors responsive at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = Repository();
      late IntakeAssignmentController state;
      await tester.pumpWidget(
        app(
          IntakeAssignmentCard(
            createController: () => state = controller(repository),
            onChanged: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sin médico asignado'), findsOneWidget);
      repository.current = Repository.record(
        AssignmentStatus.pendingAcceptance,
      );
      await state.load();
      await tester.pumpAndSettle();
      expect(find.text('Pendiente de aceptación'), findsOneWidget);
      expect(find.text('Elegir médico'), findsNothing);
      repository.failure = AssignmentIssue.denied;
      await state.load();
      await tester.pumpAndSettle();
      expect(find.text('Liberar asignación'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'empty candidates and mandatory confirmation shown without mutation',
    (tester) async {
      final repository = Repository()..empty = true,
          state = controller(repository);
      await state.load();
      await tester.pumpWidget(app(IntakeAssignmentEditor(controller: state)));
      await tester.pumpAndSettle();
      expect(find.textContaining('No hay médicos elegibles'), findsOneWidget);
      await tester.ensureVisible(find.text('Confirmar asignación'));
      await tester.tap(find.text('Confirmar asignación'));
      await tester.pumpAndSettle();
      expect(
        find.text('Completa la selección y confirma antes de continuar.'),
        findsWidgets,
      );
      expect(repository.requests, isEmpty);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
  testWidgets('release requires reason and confirmation', (tester) async {
    final repository = Repository()
          ..current = Repository.record(AssignmentStatus.pendingAcceptance),
        state = controller(repository);
    await state.load();
    await tester.pumpWidget(
      app(IntakeAssignmentEditor(controller: state, release: true)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Liberar asignación'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Liberar asignación'));
    await tester.pumpAndSettle();
    expect(
      find.text('Completa la selección y confirma antes de continuar.'),
      findsWidgets,
    );
    expect(repository.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}
