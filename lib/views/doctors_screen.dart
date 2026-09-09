import 'package:flutter/material.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/doctor_administration_controller.dart';
import '../widgets/doctor_administration_editor.dart';
import '../core/doctor_messages.dart';
import '../core/localization.dart';
import '../domain/doctor_record.dart';
import '../domain/panel_access.dart';
import '../widgets/doctor_editor.dart';
import '../widgets/doctor_record_card.dart';
import '../widgets/doctor_review_editor.dart';
import '../widgets/panel_shell.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key, required this.createController});
  final DoctorController Function() createController;
  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _edit({DoctorRecord? record, bool review = false}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => review
          ? DoctorReviewEditor(controller: controller, record: record!)
          : DoctorEditor(controller: controller, previous: record),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings(context).doctorSaved)));
      await controller.load();
    }
  }

  Future<void> _administration(DoctorRecord record) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DoctorAdministrationEditor(
        name: record.input.name,
        createController: () => DoctorAdministrationController(
          controller.administrationRepository!,
          controller.principal,
          controller.country,
          controller.administration[record.id]!,
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings(context).doctorAdminSaved)),
      );
    }
    await controller.load();
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
              text.menuDoctors,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(text.doctorsIntro),
            if (!controller.canRegister &&
                !controller.principal
                    .rolesFor(controller.country)
                    .contains(PanelRole.medicalDirector))
              Text(text.superadminReadOnly),
            if (controller.canRegister &&
                controller.administrationRepository != null) ...[
              const SizedBox(height: 12),
              Text(text.doctorAvailabilityHelp),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (controller.canRegister)
                  FilledButton.icon(
                    onPressed: controller.busy ? null : () => _edit(),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(text.doctorCreate),
                  ),
                OutlinedButton.icon(
                  onPressed: controller.busy ? null : controller.load,
                  icon: const Icon(Icons.refresh),
                  label: Text(text.doctorRefresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.busy) const LinearProgressIndicator(),
            if (controller.issue != null) ...[
              Text(
                doctorIssueLabel(context, controller.issue!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: controller.busy ? null : controller.load,
                child: Text(text.retry),
              ),
            ],
            if (!controller.busy &&
                controller.issue == null &&
                controller.records.isEmpty)
              Text(text.doctorEmpty),
            for (final record in controller.records)
              DoctorRecordCard(
                record: record,
                administration: controller.administration[record.id],
                onAdministration:
                    !controller.busy &&
                        controller.issue == null &&
                        controller.canRegister &&
                        controller.administration.containsKey(record.id)
                    ? () => _administration(record)
                    : null,
                onEdit:
                    !controller.busy &&
                        controller.issue == null &&
                        controller.canRegister &&
                        record.editable
                    ? () => _edit(record: record)
                    : null,
                onReview:
                    !controller.busy &&
                        controller.issue == null &&
                        controller.canReview(record) &&
                        DoctorStatus.values.any(record.permits)
                    ? () => _edit(record: record, review: true)
                    : null,
              ),
            if (controller.nextCursor != null)
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.load(more: true),
                child: Text(text.doctorMore),
              ),
          ],
        ),
      ),
    );
  }
}
