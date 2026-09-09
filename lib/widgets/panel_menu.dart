import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/panel_session_scope.dart';
import '../domain/panel_access.dart';

class PanelMenu extends StatelessWidget {
  const PanelMenu({super.key});
  IconData _icon(PanelModule module) => switch (module) {
    PanelModule.doctorWorkspace => Icons.work_outline,
    PanelModule.dashboard => Icons.dashboard_outlined,
    PanelModule.requests => Icons.inbox_outlined,
    PanelModule.doctors => Icons.verified_user_outlined,
    PanelModule.specialties => Icons.category_outlined,
    PanelModule.clinics => Icons.local_hospital_outlined,
    PanelModule.clinicalReview => Icons.health_and_safety_outlined,
    PanelModule.assignments => Icons.assignment_ind_outlined,
    PanelModule.myCases => Icons.folder_shared_outlined,
    PanelModule.agenda => Icons.calendar_month_outlined,
    PanelModule.reports => Icons.description_outlined,
    PanelModule.prescriptions => Icons.medication_outlined,
    PanelModule.payments => Icons.payments_outlined,
    PanelModule.payouts => Icons.account_balance_wallet_outlined,
    PanelModule.reconciliation => Icons.fact_check_outlined,
    PanelModule.pricing => Icons.sell_outlined,
    PanelModule.users => Icons.manage_accounts_outlined,
    PanelModule.countries => Icons.public,
    PanelModule.gateways => Icons.credit_card,
    PanelModule.audit => Icons.history,
  };
  @override
  Widget build(BuildContext context) {
    final session = PanelSessionScope.of(context);
    final text = strings(context);
    final principal = session.principal!;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 64,
                  semanticLabel: text.appTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  principal
                      .rolesFor(session.country)
                      .map((role) => roleLabel(context, role))
                      .join(' · '),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: session.country,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: text.country),
                  items: [
                    for (final country in principal.countries)
                      DropdownMenuItem(
                        value: country,
                        child: Text(
                          country == 'CL'
                              ? text.chile
                              : country == 'AR'
                              ? text.argentina
                              : country,
                        ),
                      ),
                  ],
                  onChanged: (country) {
                    if (country != null) session.selectCountry(country);
                  },
                ),
                const SizedBox(height: 16),
                for (final module in PanelModule.values)
                  if (PanelAccess.visible(principal, session.country, module))
                    ListTile(
                      dense: true,
                      leading: Icon(_icon(module), size: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(moduleLabel(context, module)),
                      selected:
                          (ModalRoute.of(context)?.settings.name ?? '/') ==
                              '/${module.name}' ||
                          (ModalRoute.of(context)?.settings.name == '/' &&
                              module ==
                                  (principal.rolesFor(session.country).length ==
                                              1 &&
                                          principal
                                              .rolesFor(session.country)
                                              .contains(PanelRole.doctor)
                                      ? PanelModule.doctorWorkspace
                                      : PanelModule.dashboard)),
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/${module.name}',
                        (_) => false,
                      ),
                    ),
              ],
            ),
          ),
          const Divider(),
          TextButton.icon(
            onPressed: session.signOut,
            icon: const Icon(Icons.logout),
            label: Text(text.signOut),
          ),
        ],
      ),
    );
  }
}
