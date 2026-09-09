import 'package:flutter/material.dart';
import '../controllers/clinic_controller.dart';
import '../core/localization.dart';
import '../core/clinic_messages.dart';
import '../domain/clinic.dart';
import '../widgets/panel_shell.dart';
import '../widgets/clinic_card.dart';
import '../widgets/clinic_editor.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key, required this.createController});
  final ClinicController Function() createController;
  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saved(bool saved) async {
    if (!saved || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings(context).clinicSaved)));
    await controller.load();
  }

  Future<void> _edit([Clinic? previous]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ClinicEditor(controller: controller, previous: previous),
    );
    await _saved(saved == true);
  }

  Future<void> _toggle(Clinic previous) async {
    final text = strings(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          previous.active ? text.clinicDeactivate : text.clinicReactivate,
        ),
        content: Text(text.clinicToggleConfirm(previous.input.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(text.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(text.clinicConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _saved(await controller.setActive(previous, !previous.active));
    }
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
              text.menuClinics,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(text.clinicsIntro),
            if (!controller.canManage) Text(text.clinicReadOnly),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (controller.canManage)
                  FilledButton.icon(
                    onPressed: controller.busy ? null : () => _edit(),
                    icon: const Icon(Icons.add),
                    label: Text(text.clinicCreate),
                  ),
                OutlinedButton.icon(
                  onPressed: controller.busy ? null : controller.load,
                  icon: const Icon(Icons.refresh),
                  label: Text(text.clinicRefresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.busy)
              LinearProgressIndicator(semanticsLabel: text.clinicLoading),
            if (controller.issue != null) ...[
              Text(
                clinicIssueLabel(context, controller.issue!),
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
              Text(text.clinicEmpty),
            for (final record in controller.records)
              ClinicCard(
                record: record,
                onEdit:
                    controller.canManage &&
                        !controller.busy &&
                        controller.issue == null
                    ? () => _edit(record)
                    : null,
                onToggle:
                    controller.canManage &&
                        !controller.busy &&
                        controller.issue == null
                    ? () => _toggle(record)
                    : null,
              ),
            if (controller.nextCursor != null)
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.load(more: true),
                child: Text(text.clinicMore),
              ),
          ],
        ),
      ),
    );
  }
}
