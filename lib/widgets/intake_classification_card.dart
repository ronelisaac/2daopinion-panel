import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/intake_classification_controller.dart';
import '../core/localization.dart';
import '../core/classification_messages.dart';
import '../domain/intake_classification.dart';
import 'intake_classification_editor.dart';

class IntakeClassificationCard extends StatefulWidget {
  const IntakeClassificationCard({
    super.key,
    required this.createController,
    this.onChanged,
  });
  final IntakeClassificationController Function() createController;
  final VoidCallback? onChanged;
  @override
  State<IntakeClassificationCard> createState() =>
      _IntakeClassificationCardState();
}

class _IntakeClassificationCardState extends State<IntakeClassificationCard> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                  text.classificationTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(text.classificationNotAssignment),
                const SizedBox(height: 12),
                if (controller.busy) const LinearProgressIndicator(),
                if (controller.issue != null)
                  Text(
                    classificationIssueLabel(context, controller.issue!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (record != null) ...[
                  Text(
                    record.specialtyName ?? text.classificationPending,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(classificationSourceLabel(context, record.source)),
                  if (record.source != ClassificationSource.unconfirmed &&
                      !record.specialtyActive)
                    Text(
                      text.classificationInactive,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (record.updatedAt != null)
                    Text(
                      text.classificationDate(
                        DateFormat.yMd(
                          Localizations.localeOf(context).toLanguageTag(),
                        ).add_Hm().format(record.updatedAt!.toLocal()),
                      ),
                    ),
                  if (!controller.canEdit)
                    Text(text.superadminReadOnly)
                  else if (!record.editable)
                    Text(text.classificationLocked),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (controller.canEdit && record?.editable == true)
                      FilledButton.icon(
                        icon: const Icon(Icons.category_outlined),
                        label: Text(text.classificationEdit),
                        onPressed: controller.busy
                            ? null
                            : () async {
                                final saved = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => IntakeClassificationEditor(
                                    controller: controller,
                                  ),
                                );
                                if (saved == true && context.mounted) {
                                  widget.onChanged?.call();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(text.classificationSaved),
                                    ),
                                  );
                                }
                                if (context.mounted) await controller.load();
                              },
                      ),
                    TextButton(
                      onPressed: controller.busy ? null : controller.load,
                      child: Text(text.classificationRefresh),
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
