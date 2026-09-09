import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/doctor_controller.dart';
import 'package:segunda_opinion_panel/domain/doctor_administration.dart';
import 'package:segunda_opinion_panel/domain/doctor_operational_availability.dart';
import 'package:segunda_opinion_panel/domain/doctor_record.dart';
import 'package:segunda_opinion_panel/widgets/doctor_availability_status.dart';
import 'doctor_administration_test.dart' as fixtures;
import 'fake_identity.dart';

DoctorAdministration administrative(DoctorAvailabilityState state) =>
    DoctorAdministration(
      id: 'CL_123',
      active: true,
      revision: 0,
      availability: DoctorOperationalAvailability(
        state: state,
        checkedAt: DateTime.utc(2026, 9, 9, 12),
        confirmedAt:
            state == DoctorAvailabilityState.available ||
                state == DoctorAvailabilityState.paused
            ? DateTime.utc(2026, 9, 9, 11)
            : null,
      ),
    );
void main() {
  test(
    'refresh replaces availability and denial removes stale values',
    () async {
      final repository = fixtures.Administration()
        ..state = administrative(DoctorAvailabilityState.available);
      final controller = DoctorController(
        fixtures.Records(),
        fixtures.principal(),
        'CL',
        administrationRepository: repository,
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(
        controller.administration['CL_123']!.availability!.state,
        DoctorAvailabilityState.available,
      );
      repository.state = administrative(DoctorAvailabilityState.blockedAccount);
      await controller.load();
      expect(
        controller.administration['CL_123']!.availability!.state,
        DoctorAvailabilityState.blockedAccount,
      );
      repository.failure = DoctorAdministrationIssue.denied;
      await controller.load();
      expect(controller.administration, isEmpty);
      expect(controller.records, isEmpty);
      expect(controller.issue, DoctorIssue.denied);
    },
  );
  const labels = {
    DoctorAvailabilityState.available: 'Disponible · Confirmación vigente',
    DoctorAvailabilityState.paused: 'Recepción pausada por el médico',
    DoctorAvailabilityState.needsConfirmation:
        'Pendiente de confirmar disponibilidad',
    DoctorAvailabilityState.unlinked: 'Sin cuenta médica vinculada',
    DoctorAvailabilityState.blockedAdministration:
        'No disponible: ficha administrativa pausada',
    DoctorAvailabilityState.blockedReview:
        'No disponible: revisión profesional pendiente o no habilitada',
    DoctorAvailabilityState.blockedSpecialty:
        'No disponible: especialidad no habilitada',
    DoctorAvailabilityState.blockedAccount:
        'No disponible: cuenta médica no habilitada',
    DoctorAvailabilityState.linkMismatch:
        'No disponible: revisar vínculo de cuenta',
    DoctorAvailabilityState.unavailable: 'Disponibilidad sin confirmar',
  };
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets(
      'all operational states are responsive and readonly at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final entry in labels.entries) {
          final repository = fixtures.Administration()
            ..state = administrative(entry.key);
          await tester.pumpWidget(
            PanelApp(
              key: UniqueKey(),
              identity: FakeIdentity(current: fixtures.principal()),
              doctorRepository: fixtures.Records(),
              administrationRepository: repository,
            ),
          );
          await tester.pumpAndSettle();
          Navigator.of(
            tester.element(find.byType(Scaffold).first),
          ).pushNamed('/doctors');
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(DoctorAvailabilityStatus));
          await tester.pumpAndSettle();
          expect(find.text(entry.value), findsOneWidget);
          expect(find.textContaining('Consultado:'), findsOneWidget);
          expect(
            find.textContaining('no una reserva ni asignación'),
            findsOneWidget,
          );
          expect(find.byType(SwitchListTile), findsNothing);
          expect(find.text('Guardar disponibilidad'), findsNothing);
          expect(repository.requests, isEmpty);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
