import 'package:flutter/material.dart';
import '../controllers/doctor_workspace_controller.dart';
import '../core/localization.dart';
import '../domain/doctor_workspace.dart';
import '../widgets/panel_shell.dart';
import '../widgets/doctor_workspace_summary.dart';
import '../widgets/doctor_availability_editor.dart';

class DoctorWorkspaceScreen extends StatefulWidget {
  const DoctorWorkspaceScreen({super.key, required this.createController});
  final DoctorWorkspaceController Function() createController;
  @override
  State<DoctorWorkspaceScreen> createState() => _DoctorWorkspaceScreenState();
}

class _DoctorWorkspaceScreenState extends State<DoctorWorkspaceScreen> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return PanelShell(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text.workspaceTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(text.workspaceIntro),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: controller.busy ? null : controller.load,
                icon: const Icon(Icons.refresh),
                label: Text(text.workspaceRefresh),
              ),
            ),
            if (controller.busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              Text(text.workspaceLoading),
            ],
            if (controller.issue != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  switch (controller.issue!) {
                    WorkspaceIssue.denied => text.workspaceDenied,
                    WorkspaceIssue.conflict => text.workspaceConflict,
                    WorkspaceIssue.blocked => text.workspaceBlocked,
                    WorkspaceIssue.limit => text.workspaceLimit,
                    WorkspaceIssue.invalid => text.workspaceInvalid,
                    WorkspaceIssue.unavailable => text.workspaceUnavailable,
                  },
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (controller.workspace != null) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final summary = DoctorWorkspaceSummary(
                    workspace: controller.workspace!,
                    country: controller.country,
                  );
                  final availability = DoctorAvailabilityEditor(
                    controller: controller,
                  );
                  return constraints.maxWidth >= 850
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: summary),
                            const SizedBox(width: 16),
                            Expanded(child: availability),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            summary,
                            const SizedBox(height: 16),
                            availability,
                          ],
                        );
                },
              ),
              const SizedBox(height: 16),
              Text(text.workspaceCasesPending),
            ],
          ],
        ),
      ),
    );
  }
}
