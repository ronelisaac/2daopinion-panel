import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/doctor_workspace.dart';

class DoctorWorkspaceSummary extends StatelessWidget {
  const DoctorWorkspaceSummary({
    super.key,
    required this.workspace,
    required this.country,
  });
  final DoctorWorkspace workspace;
  final String country;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.badge_outlined, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              workspace.name ?? text.workspaceUnlinkedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (workspace.registry != null)
              Text(text.doctorRegistrySummary(country, workspace.registry!)),
            if (workspace.specialty != null) Text(workspace.specialty!),
            const SizedBox(height: 12),
            Text(switch (workspace.state) {
              WorkspaceState.unlinked => text.workspaceUnlinked,
              WorkspaceState.blocked => text.workspaceBlocked,
              WorkspaceState.ready => text.workspaceReady,
            }),
          ],
        ),
      ),
    );
  }
}
