import 'package:flutter/material.dart';
import '../controllers/intake_classification_controller.dart';
import '../core/localization.dart';
import '../core/classification_messages.dart';
import '../domain/intake_classification.dart';
import 'classification_specialty_field.dart';

class IntakeClassificationEditor extends StatefulWidget {
  const IntakeClassificationEditor({super.key, required this.controller});
  final IntakeClassificationController controller;
  @override
  State<IntakeClassificationEditor> createState() =>
      _IntakeClassificationEditorState();
}

class _IntakeClassificationEditorState
    extends State<IntakeClassificationEditor> {
  final form = GlobalKey<FormState>();
  late ClassificationSource source = widget.controller.record!.source;
  String? specialtyId;
  @override
  void initState() {
    super.initState();
    widget.controller.loadSpecialties();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller, text = strings(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => PopScope(
        canPop: !controller.busy,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          title: Text(text.classificationTitle),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(text.classificationHelp),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ClassificationSource>(
                      initialValue: source,
                      isExpanded: true,
                      isDense: false,
                      decoration: InputDecoration(
                        labelText: text.classificationOrigin,
                      ),
                      items: ClassificationSource.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                classificationSourceLabel(context, value),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.busy
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  source = value;
                                  specialtyId = null;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    if (source != ClassificationSource.unconfirmed)
                      ClassificationSpecialtyField(
                        key: ValueKey(source),
                        controller: controller,
                        onChanged: (value) => specialtyId = value,
                      ),
                    FormField<bool>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: false,
                      validator: (value) =>
                          value == true ? null : text.classificationRequired,
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: field.value ?? false,
                            title: Text(text.classificationConfirm),
                            onChanged: controller.busy ? null : field.didChange,
                          ),
                          if (field.errorText != null)
                            Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (controller.busy) const LinearProgressIndicator(),
                          if (controller.issue != null)
                            Text(
                              classificationIssueLabel(
                                context,
                                controller.issue!,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: !controller.canSave
                                ? null
                                : () async {
                                    if (!form.currentState!.validate()) return;
                                    final saved = await controller.save(
                                      ClassificationInput(
                                        source,
                                        source ==
                                                ClassificationSource.unconfirmed
                                            ? null
                                            : specialtyId,
                                        field.value == true,
                                      ),
                                    );
                                    if (saved && context.mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  },
                            child: Text(text.classificationSave),
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
