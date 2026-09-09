import 'package:flutter/material.dart';
import '../controllers/doctor_workspace_controller.dart';
import '../core/localization.dart';
import '../domain/doctor_workspace.dart';

class DoctorAvailabilityEditor extends StatelessWidget {
  const DoctorAvailabilityEditor({super.key, required this.controller});
  final DoctorWorkspaceController controller;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final workspace = controller.workspace!;
    final ready = workspace.state == WorkspaceState.ready;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text.workspaceAvailability,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              workspace.accepting
                  ? text.workspaceAvailable
                  : text.workspacePaused,
            ),
            const SizedBox(height: 8),
            Text(text.workspaceAvailabilityHelp),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(text.workspaceAccepting),
              value: controller.accepting,
              onChanged: controller.busy || !ready ? null : controller.select,
            ),
            if (workspace.updatedAt != null)
              Text(
                text.workspaceUpdated(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(workspace.updatedAt!.toLocal()),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed:
                  controller.busy ||
                      !ready ||
                      workspace.accepting == controller.accepting
                  ? null
                  : () async {
                      final saved = await controller.save();
                      if (saved && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(text.workspaceSaved)),
                        );
                      }
                    },
              icon: const Icon(Icons.save_outlined),
              label: Text(text.workspaceSave),
            ),
          ],
        ),
      ),
    );
  }
}
