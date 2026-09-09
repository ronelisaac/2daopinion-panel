import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/panel_staff_controller.dart';
import '../core/localization.dart';
import '../core/staff_messages.dart';
import '../domain/doctor_account_preview.dart';
import '../domain/doctor_record.dart';
import '../domain/panel_staff.dart';

class DoctorAccountEditor extends StatefulWidget {
  const DoctorAccountEditor({
    super.key,
    required this.controller,
    required this.user,
  });
  final PanelStaffController controller;
  final PanelStaff user;
  @override
  State<DoctorAccountEditor> createState() => _DoctorAccountEditorState();
}

class _DoctorAccountEditorState extends State<DoctorAccountEditor> {
  final registry = TextEditingController();
  final form = GlobalKey<FormState>();
  DoctorAccountPreview? preview;
  @override
  void dispose() {
    registry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context), controller = widget.controller;
    final unlinking = widget.user.doctorLinks.containsKey(controller.country);
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
            unlinking ? text.staffDoctorUnlink : text.staffDoctorLink,
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
                    Text(
                      widget.user.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(widget.user.email),
                    const SizedBox(height: 16),
                    Text(
                      unlinking
                          ? text.staffDoctorUnlinkHint
                          : text.staffDoctorLinkIntro,
                    ),
                    const SizedBox(height: 16),
                    if (unlinking)
                      Text(widget.user.doctorLinks[controller.country]!)
                    else if (preview == null)
                      TextFormField(
                        controller: registry,
                        enabled: !controller.busy,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: text.doctorRegistry,
                          errorMaxLines: 4,
                        ),
                        validator: (value) =>
                            DoctorInput.validRegistry(value ?? '')
                            ? null
                            : text.doctorRegistryInvalid,
                      )
                    else ...[
                      Text(
                        preview!.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(preview!.specialty),
                      Text(
                        text.doctorRegistrySummary(
                          controller.country,
                          preview!.registry,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(text.staffDoctorConfirmHint),
                      TextButton(
                        onPressed: controller.busy
                            ? null
                            : () => setState(() => preview = null),
                        child: Text(text.staffDoctorChange),
                      ),
                    ],
                    if (controller.issue != null)
                      Text(
                        controller.issue == StaffIssue.duplicate
                            ? text.staffDoctorBound
                            : staffMessage(context, controller.issue!),
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
                      if (!unlinking && preview == null) {
                        final result = await controller.previewDoctor(
                          widget.user,
                          registry.text,
                        );
                        if (mounted) setState(() => preview = result);
                        return;
                      }
                      final saved = unlinking
                          ? await controller.unlinkDoctor(widget.user)
                          : await controller.linkDoctor(widget.user, preview!);
                      if (saved && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(
                unlinking
                    ? text.confirm
                    : preview == null
                    ? text.staffDoctorSearch
                    : text.staffDoctorConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
