import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/intake_assignment_controller.dart';
import '../core/localization.dart';
import '../core/assignment_messages.dart';
import '../domain/intake_assignment.dart';
import 'intake_assignment_editor.dart';

class IntakeAssignmentCard extends StatefulWidget {
  const IntakeAssignmentCard({
    super.key,
    required this.createController,
    required this.onChanged,
  });
  final IntakeAssignmentController Function() createController;
  final VoidCallback onChanged;
  @override
  State<IntakeAssignmentCard> createState() => _IntakeAssignmentCardState();
}

class _IntakeAssignmentCardState extends State<IntakeAssignmentCard> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> edit(bool release) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          IntakeAssignmentEditor(controller: controller, release: release),
    );
    if (!mounted) return;
    if (saved == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings(context).assignmentSaved)));
      widget.onChanged();
    }
    await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final record = controller.record;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  text.assignmentTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(text.assignmentHelp),
                const SizedBox(height: 12),
                if (controller.busy) const LinearProgressIndicator(),
                if (controller.issue != null)
                  Text(
                    assignmentIssueLabel(context, controller.issue!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (record != null) ...[
                  Text(switch (record.status) {
                    AssignmentStatus.unassigned => text.assignmentNone,
                    AssignmentStatus.pendingAcceptance =>
                      text.assignmentPending,
                    AssignmentStatus.released => text.assignmentReleased,
                  }, style: Theme.of(context).textTheme.titleMedium),
                  if (record.doctorName != null)
                    Text(text.assignmentPrevious(record.doctorName!)),
                  if (record.specialtyName != null) Text(record.specialtyName!),
                  if (record.updatedAt != null)
                    Text(
                      text.classificationDate(
                        DateFormat.yMd(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).add_Hm().format(record.updatedAt!.toLocal()),
                      ),
                    ),
                  if (!record.canAssign && !record.canRelease)
                    Text(
                      controller.canOperate
                          ? text.assignmentBlocked
                          : text.superadminReadOnly,
                    ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (controller.canEdit && record?.canAssign == true)
                      FilledButton.icon(
                        onPressed: controller.busy ? null : () => edit(false),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(text.assignmentChoose),
                      ),
                    if (controller.canEdit && record?.canRelease == true)
                      OutlinedButton(
                        onPressed: controller.busy ? null : () => edit(true),
                        child: Text(text.assignmentRelease),
                      ),
                    TextButton(
                      onPressed: controller.busy ? null : controller.load,
                      child: Text(text.assignmentRefresh),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
