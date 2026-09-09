import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/doctor_controller.dart';
import '../core/doctor_messages.dart';
import '../core/localization.dart';
import '../domain/doctor_record.dart';

class DoctorEditor extends StatefulWidget {
  const DoctorEditor({super.key, required this.controller, this.previous});
  final DoctorController controller;
  final DoctorRecord? previous;
  @override
  State<DoctorEditor> createState() => _DoctorEditorState();
}

class _DoctorEditorState extends State<DoctorEditor> {
  late final name = TextEditingController(text: widget.previous?.input.name);
  late final registry = TextEditingController(
    text: widget.previous?.input.registry,
  );
  late final specialty = TextEditingController(
    text: widget.previous?.input.specialty,
  );
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    name.dispose();
    registry.dispose();
    specialty.dispose();
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
            widget.previous == null ? text.doctorCreate : text.doctorEdit,
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
                    Text(text.doctorsIntro),
                    Text(text.doctorRequiredHint),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: name,
                      enabled: !controller.busy,
                      maxLength: 120,
                      decoration: InputDecoration(
                        labelText: text.doctorName,
                        errorMaxLines: 4,
                      ),
                      validator: (value) => DoctorInput.validName(value ?? '')
                          ? null
                          : text.doctorNameInvalid,
                    ),
                    TextFormField(
                      controller: registry,
                      enabled: !controller.busy && widget.previous == null,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: text.doctorRegistry,
                        helperText: text.doctorRegistryHelp,
                        helperMaxLines: 5,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          DoctorInput.validRegistry(value ?? '')
                          ? null
                          : text.doctorRegistryInvalid,
                    ),
                    TextFormField(
                      controller: specialty,
                      enabled: !controller.busy,
                      maxLength: 120,
                      decoration: InputDecoration(
                        labelText: text.doctorSpecialty,
                        errorMaxLines: 4,
                      ),
                      validator: (value) =>
                          DoctorInput.validSpecialty(value ?? '')
                          ? null
                          : text.doctorSpecialtyInvalid,
                    ),
                    if (controller.issue != null)
                      Text(
                        doctorIssueLabel(context, controller.issue!),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (controller.busy) const LinearProgressIndicator(),
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
                        DoctorInput(name.text, registry.text, specialty.text),
                        previous: widget.previous,
                      );
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(text.doctorSave),
            ),
          ],
        ),
      ),
    );
  }
}
