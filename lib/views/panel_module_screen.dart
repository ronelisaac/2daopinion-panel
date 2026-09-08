import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../core/panel_session_scope.dart';
import '../domain/panel_access.dart';
import '../widgets/panel_shell.dart';

class PanelModuleScreen extends StatelessWidget {
  const PanelModuleScreen({super.key, this.module, this.denied = false});
  final PanelModule? module;
  final bool denied;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final session = PanelSessionScope.of(context);
    return PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            denied
                ? text.accessDenied
                : moduleLabel(context, module ?? PanelModule.dashboard),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(denied ? text.accessDeniedHint : text.modulePending),
          const SizedBox(height: 16),
          Text('${text.country}: ${session.country}'),
          if (module == PanelModule.dashboard) ...[
            const SizedBox(height: 24),
            Text(text.dashboardHint),
            for (final item in [PanelModule.requests, PanelModule.users])
              if (PanelAccess.allows(session.principal!, session.country, item))
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/${item.name}'),
                  child: Text(moduleLabel(context, item)),
                ),
          ],
        ],
      ),
    );
  }
}
