import 'package:flutter/material.dart';
import '../controllers/intake_assignment_controller.dart';
import '../core/localization.dart';
import '../core/assignment_messages.dart';
import '../domain/intake_assignment.dart';

class IntakeAssignmentEditor extends StatefulWidget {
  const IntakeAssignmentEditor({
    super.key,
    required this.controller,
    this.release = false,
  });
  final IntakeAssignmentController controller;
  final bool release;
  @override
  State<IntakeAssignmentEditor> createState() => _IntakeAssignmentEditorState();
}

class _IntakeAssignmentEditorState extends State<IntakeAssignmentEditor> {
  final form = GlobalKey<FormState>();
  String? doctorId;
  AssignmentReason? reason;
  @override
  void initState() {
    super.initState();
    if (!widget.release) widget.controller.loadCandidates();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context), controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => PopScope(
        canPop: !controller.busy,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(
            widget.release ? text.assignmentRelease : text.assignmentChoose,
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.release
                          ? text.assignmentReleaseHelp
                          : text.assignmentCandidatesHelp,
                    ),
                    const SizedBox(height: 16),
                    if (widget.release)
                      DropdownButtonFormField<AssignmentReason>(
                        isExpanded: true,
                        isDense: false,
                        decoration: InputDecoration(
                          labelText: text.assignmentReason,
                          errorMaxLines: 4,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        items: AssignmentReason.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  assignmentReasonLabel(context, value),
                                  maxLines: 2,
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) =>
                            value == null ? text.assignmentRequired : null,
                        onChanged: controller.busy
                            ? null
                            : (value) => reason = value,
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        isDense: false,
                        decoration: InputDecoration(
                          labelText: text.assignmentCandidate,
                          errorMaxLines: 4,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        items: controller.candidates
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(
                                  '${item.name} · RNPI ${item.registry}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) =>
                            controller.candidates.any(
                              (item) => item.id == value,
                            )
                            ? null
                            : text.assignmentRequired,
                        onChanged: controller.busy
                            ? null
                            : (value) => doctorId = value,
                      ),
                      if (!controller.busy && controller.candidates.isEmpty)
                        Text(text.assignmentEmpty),
                      if (controller.cursor != null)
                        TextButton(
                          onPressed: controller.busy
                              ? null
                              : () => controller.loadCandidates(more: true),
                          child: Text(text.assignmentMore),
                        ),
                    ],
                    const SizedBox(height: 16),
                    FormField<bool>(
                      initialValue: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value == true ? null : text.assignmentRequired,
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(text.assignmentConfirm),
                            value: field.value ?? false,
                            onChanged: controller.busy ? null : field.didChange,
                          ),
                          if (field.errorText != null)
                            Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          if (controller.busy) const LinearProgressIndicator(),
                          if (controller.issue != null)
                            Text(
                              assignmentIssueLabel(context, controller.issue!),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: !controller.canEdit
                                ? null
                                : () async {
                                    if (!form.currentState!.validate()) return;
                                    final saved = await controller.save(
                                      doctorId: widget.release
                                          ? null
                                          : doctorId,
                                      reason: reason,
                                      confirmed: field.value == true,
                                    );
                                    if (saved && context.mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  },
                            child: Text(
                              widget.release
                                  ? text.assignmentRelease
                                  : text.assignmentSave,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.busy
                  ? null
                  : () => Navigator.pop(context, false),
              child: Text(text.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
