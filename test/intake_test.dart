import 'dart:async';
import 'fake_identity.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/intake_controller.dart';
import 'package:segunda_opinion_panel/controllers/intake_detail_controller.dart';
import 'package:segunda_opinion_panel/domain/intake_request.dart';
import 'package:segunda_opinion_panel/domain/repositories/intake_repository.dart';
import 'package:segunda_opinion_panel/repositories/preview_intake_repository.dart';
import 'package:segunda_opinion_panel/widgets/intake_detail_content.dart';

class ControlledRepository implements IntakeRepository {
  final pages = <Completer<IntakePage>>[];
  final detail = Completer<IntakeRequest>();
  @override
  Future<IntakePage> list(IntakeQuery query) {
    final pending = Completer<IntakePage>();
    pages.add(pending);
    return pending.future;
  }

  @override
  Future<IntakeRequest> get(String id) => detail.future;
}

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'enabling intake does not redirect other roles into a denied inbox',
    (tester) async {
      for (final role in [
        PanelRole.superadmin,
        PanelRole.doctor,
        PanelRole.finance,
        PanelRole.medicalDirector,
      ]) {
        final repository = ControlledRepository();
        await tester.pumpWidget(
          PanelApp(
            key: ValueKey(role),
            identity: FakeIdentity(
              current: PanelPrincipal(
                id: 'local-test',
                roles: {role},
                countries: {'CL'},
              ),
            ),
            repository: repository,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Resumen'), findsWidgets);
        expect(repository.pages, isEmpty);
      }
    },
  );
  test('cursor-based pages work without an invented total', () async {
    final repository = ControlledRepository();
    final controller = IntakeController(repository);
    addTearDown(controller.dispose);
    final first = controller.load();
    repository.pages.single.complete(IntakePage(items: [], hasMore: true));
    await first;
    expect(controller.result!.total, isNull);
    expect(controller.hasNext, isTrue);
    final last = controller.load(page: 1);
    repository.pages.last.complete(IntakePage(items: [], hasMore: false));
    await last;
    expect(controller.hasNext, isFalse);
  });
  test(
    'preview pages are stable, bounded and independent from filters',
    () async {
      final repository = PreviewIntakeRepository();
      final ids = <String>{};
      for (var page = 0; page < 3; page++) {
        final result = await repository.list(IntakeQuery(page: page));
        expect(result.total, 18);
        expect(result.items.length, lessThanOrEqualTo(8));
        ids.addAll(result.items.map((item) => item.id));
        expect(() => result.items.clear(), throwsUnsupportedError);
      }
      expect(ids.length, 18);
      final filtered = await repository.list(
        const IntakeQuery(status: IntakeStatus.needsDocuments),
      );
      expect(filtered.total, 6);
      expect(
        filtered.items.every(
          (item) => item.status == IntakeStatus.needsDocuments,
        ),
        isTrue,
      );
      final found = await repository.list(
        const IntakeQuery(search: '  demo-0001  '),
      );
      expect(found.items.single.reference, 'DEMO-0001');
      expect(
        () => found.items.single.documents.clear(),
        throwsUnsupportedError,
      );
      await expectLater(
        repository.list(const IntakeQuery(page: -1)),
        throwsA(isA<IntakeFailure>()),
      );
      await expectLater(
        repository.get('not-a-real-patient'),
        throwsA(isA<IntakeFailure>()),
      );
    },
  );
  test('controller ignores stale results and clears rows on error', () async {
    final repository = ControlledRepository();
    final controller = IntakeController(repository);
    addTearDown(controller.dispose);
    final first = controller.load();
    final second = controller.load(search: 'new');
    repository.pages[1].complete(IntakePage(items: [], total: 0));
    await second;
    repository.pages[0].complete(IntakePage(items: [], total: 99));
    await first;
    expect(controller.result!.total, 0);
    final failing = controller.load();
    repository.pages.last.completeError(
      const IntakeFailure(IntakeIssue.unavailable),
    );
    await failing;
    expect(controller.result, isNull);
    expect(controller.issue, IntakeIssue.unavailable);
    expect(controller.busy, isFalse);
  });
  test(
    'filter changes reset page; dispose ignores pending list and detail',
    () async {
      final controller = IntakeController(PreviewIntakeRepository());
      await controller.load(page: 2);
      expect(controller.hasNext, isFalse);
      await controller.load(status: IntakeStatus.received, changeStatus: true);
      expect(controller.query.page, 0);
      expect(controller.result!.total, 6);
      controller.dispose();
      final pending = ControlledRepository();
      final list = IntakeController(pending);
      final detail = IntakeDetailController(pending, 'example-1');
      final loading = list.load();
      final loadingDetail = detail.load();
      list.dispose();
      detail.dispose();
      pending.pages.single.complete(IntakePage(items: [], total: 20));
      pending.detail.complete(await PreviewIntakeRepository().get('example-1'));
      await Future.wait([loading, loadingDetail]);
      expect(list.result, isNull);
      expect(detail.request, isNull);
    },
  );
  test('unknown detail never becomes a placeholder case', () async {
    final controller = IntakeDetailController(
      PreviewIntakeRepository(),
      'unknown',
    );
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.issue, IntakeIssue.notFound);
    expect(controller.request, isNull);
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('search, details and return preserve filters at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        PanelApp(
          repository: PreviewIntakeRepository(),
          identity: FakeIdentity(
            current: PanelPrincipal(
              id: 'test-operations',
              roles: {PanelRole.operations},
              countries: {'CL'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('DESARROLLO ·'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'DEMO-0001');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Página 1 · 1 resultado'), findsOneWidget);
      final button = width == 1440
          ? find.byTooltip('Ver detalle DEMO-0001')
          : find.text('Ver detalle').first;
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(IntakeDetailContent), findsOneWidget);
      expect(
        find.textContaining('El contenido clínico no es accesible'),
        findsOneWidget,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'DEMO-0001',
      );
      expect(find.text('Página 1 · 1 resultado'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'not-found');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No hay solicitudes que coincidan'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('pagination, state chips and scope are usable', (tester) async {
    await tester.pumpWidget(
      PanelApp(
        repository: PreviewIntakeRepository(),
        identity: FakeIdentity(
          current: PanelPrincipal(
            id: 'test-operations',
            roles: {PanelRole.operations},
            countries: {'CL'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Siguiente');
    expect(find.text('Página 2 · 18 resultados'), findsOneWidget);
    final filter = find.widgetWithText(ChoiceChip, 'Falta documentación');
    await tester.ensureVisible(filter);
    await tester.tap(filter);
    await tester.pumpAndSettle();
    expect(find.text('Página 1 · 6 resultados'), findsOneWidget);
    await tester.tap(find.byTooltip('Alcance de esta vista previa'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No hay registro público'), findsOneWidget);
    await tapText(tester, 'Entendido');
  });
  testWidgets('large text remains accessible on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      PanelApp(
        repository: PreviewIntakeRepository(),
        identity: FakeIdentity(
          current: PanelPrincipal(
            id: 'test-operations',
            roles: {PanelRole.operations},
            countries: {'CL'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
