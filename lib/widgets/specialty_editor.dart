import 'package:flutter/material.dart';
import '../controllers/specialty_controller.dart';
import '../core/localization.dart';
import '../core/specialty_messages.dart';
import '../domain/specialty.dart';

class SpecialtyEditor extends StatefulWidget {
  const SpecialtyEditor({super.key, required this.controller, this.previous});
  final SpecialtyController controller;
  final Specialty? previous;
  @override
  State<SpecialtyEditor> createState() => _SpecialtyEditorState();
}

class _SpecialtyEditorState extends State<SpecialtyEditor> {
  late final code = TextEditingController(text: widget.previous?.input.code);
  late final name = TextEditingController(text: widget.previous?.input.name);
  late final description = TextEditingController(
    text: widget.previous?.input.description,
  );
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    code.dispose();
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final controller = widget.controller;
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
            widget.previous == null ? text.specialtyCreate : text.specialtyEdit,
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(text.specialtyRequired),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: code,
                      enabled: !controller.busy && widget.previous == null,
                      maxLength: 32,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: text.specialtyCode,
                        helperText: text.specialtyCodeHelp,
                        helperMaxLines: 5,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          SpecialtyInput.validCode(value ?? '')
                          ? null
                          : text.specialtyCodeInvalid,
                    ),
                    TextFormField(
                      controller: name,
                      enabled: !controller.busy,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: text.specialtyName,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          SpecialtyInput.validName(value ?? '')
                          ? null
                          : text.specialtyNameInvalid,
                    ),
                    TextFormField(
                      controller: description,
                      enabled: !controller.busy,
                      maxLength: 500,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: text.specialtyDescription,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          SpecialtyInput.validDescription(value ?? '')
                          ? null
                          : text.specialtyDescriptionInvalid,
                    ),
                    if (controller.issue != null)
                      Text(
                        specialtyIssueLabel(context, controller.issue!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (controller.busy)
                      LinearProgressIndicator(
                        semanticsLabel: text.specialtySaving,
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
            FilledButton(
              onPressed: controller.busy
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      final saved = await controller.save(
                        SpecialtyInput(code.text, name.text, description.text),
                        previous: widget.previous,
                      );
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(text.specialtySave),
            ),
          ],
        ),
      ),
    );
  }
}
