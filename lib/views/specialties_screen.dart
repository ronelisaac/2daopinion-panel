import 'package:flutter/material.dart';
import '../controllers/specialty_controller.dart';
import '../core/localization.dart';
import '../core/specialty_messages.dart';
import '../domain/specialty.dart';
import '../widgets/panel_shell.dart';
import '../widgets/specialty_card.dart';
import '../widgets/specialty_editor.dart';

class SpecialtiesScreen extends StatefulWidget {
  const SpecialtiesScreen({super.key, required this.createController});
  final SpecialtyController Function() createController;
  @override
  State<SpecialtiesScreen> createState() => _SpecialtiesScreenState();
}

class _SpecialtiesScreenState extends State<SpecialtiesScreen> {
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
    ).showSnackBar(SnackBar(content: Text(strings(context).specialtySaved)));
    await controller.load();
  }

  Future<void> _edit([Specialty? previous]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          SpecialtyEditor(controller: controller, previous: previous),
    );
    await _saved(saved == true);
  }

  Future<void> _toggle(Specialty previous) async {
    final text = strings(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          previous.active ? text.specialtyDeactivate : text.specialtyReactivate,
        ),
        content: Text(text.specialtyToggleConfirm(previous.input.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(text.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(text.specialtyConfirm),
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
              text.menuSpecialties,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(text.specialtiesIntro),
            if (!controller.canManage) Text(text.specialtyReadOnly),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (controller.canManage)
                  FilledButton.icon(
                    onPressed: controller.busy ? null : () => _edit(),
                    icon: const Icon(Icons.add),
                    label: Text(text.specialtyCreate),
                  ),
                OutlinedButton.icon(
                  onPressed: controller.busy ? null : controller.load,
                  icon: const Icon(Icons.refresh),
                  label: Text(text.specialtyRefresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.busy)
              LinearProgressIndicator(semanticsLabel: text.specialtyLoading),
            if (controller.issue != null) ...[
              Text(
                specialtyIssueLabel(context, controller.issue!),
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
              Text(text.specialtyEmpty),
            for (final record in controller.records)
              SpecialtyCard(
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
                child: Text(text.specialtyMore),
              ),
          ],
        ),
      ),
    );
  }
}
