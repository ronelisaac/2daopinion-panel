import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/app.dart';
import 'package:segunda_opinion_panel/controllers/panel_login_controller.dart';
import 'package:segunda_opinion_panel/controllers/panel_session_controller.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';
import 'package:segunda_opinion_panel/domain/panel_claims.dart';
import 'package:segunda_opinion_panel/views/panel_login_screen.dart';
import 'fake_identity.dart';

Map<String, dynamic> claims({
  bool active = true,
  Object? memberships = const {
    'CL': ['superadmin'],
  },
}) => {
  'panelAccess': {'version': 1, 'active': active, 'memberships': memberships},
};
Future<void> tapText(WidgetTester tester, String label) async {
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'claims deny ordinary patient, unverified, disabled and malformed scopes',
    () {
      for (final data in [
        null,
        <String, dynamic>{},
        claims(active: false),
        claims(memberships: {}),
        claims(
          memberships: {
            'CL': ['unknown'],
          },
        ),
        claims(memberships: {'CL': []}),
        claims(
          memberships: {
            'cl': ['superadmin'],
          },
        ),
      ]) {
        expect(
          () => principalFromClaims('uid', true, data),
          throwsA(isA<PanelAccessFailure>()),
        );
      }
      expect(
        () => principalFromClaims('uid', false, claims()),
        throwsA(isA<PanelAccessFailure>()),
      );
    },
  );
  test('roles are isolated per country instead of cross product', () {
    final principal = principalFromClaims(
      'uid',
      true,
      claims(
        memberships: {
          'CL': ['superadmin'],
          'AR': ['finance'],
        },
      ),
    );
    expect(PanelAccess.allows(principal, 'CL', PanelModule.users), isTrue);
    expect(PanelAccess.allows(principal, 'AR', PanelModule.users), isFalse);
    expect(PanelAccess.allows(principal, 'AR', PanelModule.payments), isTrue);
    expect(PanelAccess.allows(principal, 'CL', PanelModule.payments), isFalse);
    expect(PanelAccess.allows(principal, 'PE', PanelModule.dashboard), isFalse);
    expect(
      () => principal.countryRoles!['AR']!.clear(),
      throwsUnsupportedError,
    );
  });
  test(
    'login validation avoids requests, recovery is neutral, failures do not authenticate',
    () async {
      final identity = FakeIdentity()
        ..failure = PanelAccessIssue.invalidCredentials;
      final controller = PanelLoginController(identity);
      addTearDown(controller.dispose);
      addTearDown(identity.changes.close);
      expect(await controller.signIn('invalid', ''), isNull);
      expect(identity.signIns, 0);
      expect(
        await controller.signIn('user@example.test', 'invalid-password'),
        isNull,
      );
      expect(controller.issue, PanelAccessIssue.invalidCredentials);
      await controller.resetPassword('invalid');
      expect(identity.resets, 0);
      await controller.resetPassword('user@example.test');
      expect(controller.resetSent, isTrue);
      expect(identity.resets, 1);
    },
  );
  test(
    'restored session restricts countries and removes data on logout',
    () async {
      final identity = FakeIdentity(
        current: principalFromClaims('uid', true, claims()),
      );
      final session = PanelSessionController(identity);
      addTearDown(session.dispose);
      addTearDown(identity.changes.close);
      await Future<void>.delayed(Duration.zero);
      expect(session.principal!.id, 'uid');
      final epoch = session.epoch;
      session.selectCountry('AR');
      expect(session.country, 'CL');
      identity.changes.add(identity.current);
      await Future<void>.delayed(Duration.zero);
      expect(session.epoch, epoch);
      await session.signOut();
      expect(session.principal, isNull);
    },
  );
  for (final width in [320.0, 1440.0]) {
    testWidgets(
      'real login flow without simulator at $width; reset and logout',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final identity = FakeIdentity();
        await tester.pumpWidget(PanelApp(identity: identity));
        await tester.pumpAndSettle();
        expect(find.byType(PanelLoginScreen), findsOneWidget);
        expect(find.textContaining('Explorar panel'), findsNothing);
        expect(find.textContaining('no hay registro público'), findsOneWidget);
        await tester.enterText(
          find.byType(TextField).first,
          'user@example.test',
        );
        await tapText(tester, 'Olvidé mi contraseña');
        expect(identity.resets, 1);
        expect(find.textContaining('Si el correo corresponde'), findsOneWidget);
        await tester.enterText(
          find.byType(TextField).last,
          'Fictitious-test-password',
        );
        await tapText(tester, 'Ingresar');
        expect(find.byType(PanelLoginScreen), findsNothing);
        expect(identity.signIns, 1);
        expect(find.textContaining('Simular'), findsNothing);
        if (width == 320) {
          await tester.tap(find.byType(DrawerButton));
          await tester.pumpAndSettle();
        }
        await tapText(tester, 'Cerrar sesión');
        expect(find.byType(PanelLoginScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('failed credentials remain visible and clear password', (
    tester,
  ) async {
    final identity = FakeIdentity()
      ..failure = PanelAccessIssue.invalidCredentials;
    await tester.pumpWidget(PanelApp(identity: identity));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'user@example.test');
    await tester.enterText(find.byType(TextField).last, 'bad-password');
    await tapText(tester, 'Ingresar');
    expect(
      find.text('No pudimos iniciar sesión con esas credenciales.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      isEmpty,
    );
    expect(find.byType(PanelLoginScreen), findsOneWidget);
  });
}
