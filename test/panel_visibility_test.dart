import 'package:flutter_test/flutter_test.dart';
import 'package:segunda_opinion_panel/domain/panel_access.dart';

void main() {
  test('superadmin sees every module only within active country scope', () {
    final principal = PanelPrincipal(
      id: 'root',
      roles: {PanelRole.superadmin},
      countries: {'CL', 'AR'},
      countryRoles: {
        'CL': {PanelRole.superadmin},
        'AR': {PanelRole.finance},
      },
    );
    for (final module in PanelModule.values) {
      expect(PanelAccess.visible(principal, 'CL', module), isTrue);
      expect(PanelAccess.visible(principal, 'PE', module), isFalse);
      expect(
        PanelAccess.visible(principal, 'AR', module),
        PanelAccess.allows(principal, 'AR', module),
      );
    }
    expect(PanelAccess.allows(principal, 'CL', PanelModule.doctors), isTrue);
    expect(PanelAccess.allows(principal, 'CL', PanelModule.requests), isTrue);
    expect(
      PanelAccess.allows(principal, 'CL', PanelModule.doctorWorkspace),
      isFalse,
    );
    final inactive = PanelPrincipal(
      id: 'root',
      roles: {PanelRole.superadmin},
      countries: {'CL'},
      active: false,
    );
    for (final module in PanelModule.values) {
      expect(PanelAccess.visible(inactive, 'CL', module), isFalse);
    }
  });
}
