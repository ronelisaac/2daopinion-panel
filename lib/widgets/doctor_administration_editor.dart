import 'package:flutter/material.dart';
import '../controllers/doctor_administration_controller.dart';
import '../domain/doctor_administration.dart';
import '../core/localization.dart';

class DoctorAdministrationEditor extends StatefulWidget {
  const DoctorAdministrationEditor({
    super.key,
    required this.createController,
    required this.name,
  });
  final DoctorAdministrationController Function() createController;
  final String name;
  @override
  State<DoctorAdministrationEditor> createState() =>
      _DoctorAdministrationEditorState();
}

class _DoctorAdministrationEditorState
    extends State<DoctorAdministrationEditor> {
  late final controller = widget.createController();
  final reason = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
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
            controller.previous.active
                ? text.doctorAdminPause
                : text.doctorAdminActivate,
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
                      widget.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(text.doctorAdminHelp),
                    if (controller.previous.reason != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        text.doctorAdminPreviousReason(
                          controller.previous.reason!,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reason,
                      enabled: !controller.busy,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 500,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: text.doctorAdminReason,
                        helperText: text.doctorAdminReasonHelp,
                        helperMaxLines: 3,
                        errorMaxLines: 6,
                      ),
                      validator: (value) =>
                          DoctorAdministration.validReason(value ?? '')
                          ? null
                          : text.doctorAdminInvalid,
                    ),
                    if (controller.busy) const LinearProgressIndicator(),
                    if (controller.issue != null)
                      Text(
                        switch (controller.issue!) {
                          DoctorAdministrationIssue.invalid =>
                            text.doctorAdminInvalid,
                          DoctorAdministrationIssue.denied =>
                            text.doctorAdminDenied,
                          DoctorAdministrationIssue.conflict =>
                            text.doctorAdminConflict,
                          DoctorAdministrationIssue.limit =>
                            text.doctorAdminLimit,
                          DoctorAdministrationIssue.unavailable =>
                            text.doctorAdminUnavailable,
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
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
            FilledButton(
              onPressed: !controller.canSave
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      final saved = await controller.save(reason.text);
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(text.doctorAdminConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
