import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/controllers/intake_classification_controller.dart';
import 'package:segunda_opinion_panel/domain/intake_classification.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/specialty.dart';
import 'package:segunda_opinion_panel/domain/repositories/intake_classification_repository.dart';
import 'package:segunda_opinion_panel/domain/repositories/specialty_repository.dart';
import 'package:segunda_opinion_panel/widgets/intake_classification_card.dart';
import 'package:segunda_opinion_panel/widgets/intake_classification_editor.dart';
import 'package:segunda_opinion_panel/core/app_theme.dart';
import 'package:segunda_opinion_panel/l10n/app_localizations.dart';

IntakeClassification record({int revision = 0, bool editable = true}) =>
    IntakeClassification(
      id: 'a' * 20,
      revision: revision,
      source: revision == 0
          ? ClassificationSource.unconfirmed
          : ClassificationSource.patientConfirmed,
      specialtyId: revision == 0 ? null : 'CL_test',
      specialtyName: revision == 0 ? null : 'Especialidad ficticia',
      updatedAt: revision == 0 ? null : DateTime.utc(2026, 9, 9),
      specialtyActive: revision > 0,
      editable: editable,
    );

class Repository implements IntakeClassificationRepository {
  IntakeClassification current = record();
  ClassificationIssue? failure;
  final requests = <String>[];
  Completer<IntakeClassification>? waiting;
  @override
  Future<IntakeClassification> get(String country, String id) async {
    if (failure != null) throw ClassificationFailure(failure!);
    return waiting?.future ?? current;
  }

  @override
  Future<void> save(
    String country,
    IntakeClassification previous,
    ClassificationInput input,
    String requestId,
  ) async {
    requests.add(requestId);
    if (failure != null) throw ClassificationFailure(failure!);
    current = record(revision: previous.revision + 1);
  }
}

class Catalog implements SpecialtyRepository {
  bool fail = false;
  bool empty = false;
  @override
  Future<SpecialtyPage> list(String country, {String? cursor}) async {
    if (fail) throw const SpecialtyFailure(SpecialtyIssue.denied);
    return SpecialtyPage(
      empty
          ? []
          : [
              Specialty(
                id: 'CL_test',
                country: 'CL',
                input: SpecialtyInput('test', 'Especialidad ficticia', ''),
                active: true,
                revision: 1,
                updatedAt: DateTime.utc(2026),
              ),
            ],
      null,
    );
  }

  @override
  Future<void> save(
    String country,
    SpecialtyInput input, {
    Specialty? previous,
  }) async {}
  @override
  Future<void> setActive(Specialty previous, bool active) async {}
}

IntakeClassificationController controller(
  Repository repository,
  Catalog catalog, {
  PanelRole role = PanelRole.operations,
}) => IntakeClassificationController(
  repository,
  catalog,
  PanelPrincipal(id: 'operator', roles: {role}, countries: {'CL'}),
  'CL',
  'a' * 20,
);
Widget app(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  test(
    'typed classification requires explicit valid origin and confirmation',
    () {
      expect(
        const ClassificationInput(
          ClassificationSource.patientConfirmed,
          'CL_test',
          true,
        ).valid,
        isTrue,
      );
      expect(
        const ClassificationInput(
          ClassificationSource.unconfirmed,
          null,
          true,
        ).valid,
        isTrue,
      );
      for (final input in [
        const ClassificationInput(
          ClassificationSource.patientConfirmed,
          null,
          true,
        ),
        const ClassificationInput(
          ClassificationSource.patientConfirmed,
          'AR_test',
          true,
        ),
        const ClassificationInput(
          ClassificationSource.unconfirmed,
          'CL_test',
          true,
        ),
        const ClassificationInput(
          ClassificationSource.medicalReferral,
          'CL_test',
          false,
        ),
      ]) {
        expect(input.valid, isFalse);
      }
    },
  );
  test(
    'retries reuse ID, permission failures discard stale data, no role inheritance',
    () async {
      final repository = Repository(),
          catalog = Catalog(),
          state = controller(repository, catalog);
      await state.load();
      await state.loadSpecialties();
      repository.failure = ClassificationIssue.unavailable;
      const input = ClassificationInput(
        ClassificationSource.patientConfirmed,
        'CL_test',
        true,
      );
      expect(await state.save(input), isFalse);
      expect(await state.save(input), isFalse);
      expect(repository.requests.toSet().length, 1);
      repository.failure = ClassificationIssue.denied;
      expect(await state.save(input), isFalse);
      expect(state.record, isNull);
      expect(state.specialties, isEmpty);
      state.dispose();
      final denied = controller(
        Repository(),
        Catalog(),
        role: PanelRole.superadmin,
      );
      await denied.load();
      expect(denied.issue, ClassificationIssue.denied);
      denied.dispose();
    },
  );
  test(
    'catalog failure, inactive selection, locked request and disposal prevent writes',
    () async {
      final repository = Repository(),
          catalog = Catalog(),
          state = controller(repository, catalog);
      await state.load();
      catalog.fail = true;
      await state.loadSpecialties();
      expect(
        await state.save(
          const ClassificationInput(
            ClassificationSource.patientConfirmed,
            'CL_test',
            true,
          ),
        ),
        isFalse,
      );
      expect(repository.requests, isEmpty);
      repository.current = record(editable: false);
      await state.load();
      expect(state.canSave, isFalse);
      repository.waiting = Completer<IntakeClassification>();
      final pending = state.load();
      state.dispose();
      repository.waiting!.complete(record());
      await pending;
      expect(state.record, isNull);
    },
  );
  testWidgets('empty catalog is explicit and cannot submit a specialty', (
    tester,
  ) async {
    final repository = Repository()..current = record(revision: 1);
    final catalog = Catalog()..empty = true;
    final state = controller(repository, catalog);
    await state.load();
    await tester.pumpWidget(app(IntakeClassificationEditor(controller: state)));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No hay especialidades activas'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Guardar clasificación'));
    await tester.tap(find.text('Guardar clasificación'));
    await tester.pumpAndSettle();
    expect(
      find.text('Selecciona una especialidad activa del catálogo.'),
      findsOneWidget,
    );
    expect(repository.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets('corrected fields remove stale validation messages', (
    tester,
  ) async {
    final repository = Repository()..current = record(revision: 1);
    final state = controller(repository, Catalog());
    await state.load();
    await tester.pumpWidget(app(IntakeClassificationEditor(controller: state)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar clasificación'));
    await tester.tap(find.text('Guardar clasificación'));
    await tester.pumpAndSettle();
    expect(
      find.text('Selecciona una especialidad activa del catálogo.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Especialidad ficticia · test').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Selecciona una especialidad activa del catálogo.'),
      findsNothing,
    );
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(
      find.text('Confirma la información antes de guardar.'),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets(
      'classification pending, success, loading and denied responsive at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = Repository(), catalog = Catalog();
        late IntakeClassificationController state;
        await tester.pumpWidget(
          app(
            IntakeClassificationCard(
              createController: () => state = controller(repository, catalog),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Especialidad pendiente de confirmar'),
          findsOneWidget,
        );
        repository.current = record(revision: 1);
        await state.load();
        await tester.pumpAndSettle();
        expect(find.text('Especialidad ficticia'), findsOneWidget);
        repository.waiting = Completer<IntakeClassification>();
        final pending = state.load();
        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        repository.waiting!.complete(record(revision: 1));
        await pending;
        await tester.pumpAndSettle();
        repository.failure = ClassificationIssue.denied;
        await state.load();
        await tester.pumpAndSettle();
        expect(find.text('Especialidad ficticia'), findsNothing);
        expect(find.text('Clasificar solicitud'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'form confirmation required and selection must be from active catalog',
    (tester) async {
      final repository = Repository(),
          catalog = Catalog(),
          state = controller(repository, catalog);
      await state.load();
      await tester.pumpWidget(
        app(IntakeClassificationEditor(controller: state)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar clasificación'));
      await tester.tap(find.text('Guardar clasificación'));
      await tester.pumpAndSettle();
      expect(
        find.text('Confirma la información antes de guardar.'),
        findsOneWidget,
      );
      expect(repository.requests, isEmpty);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    },
  );
}
