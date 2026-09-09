import 'package:flutter/material.dart';
import '../controllers/panel_staff_controller.dart';
import '../core/localization.dart';
import '../core/staff_messages.dart';
import '../domain/panel_staff.dart';
import '../widgets/panel_shell.dart';
import '../widgets/staff_editor.dart';
import '../widgets/doctor_account_editor.dart';
import '../widgets/staff_member_card.dart';

class PanelStaffScreen extends StatefulWidget {
  const PanelStaffScreen({super.key, required this.createController});
  final PanelStaffController Function() createController;
  @override
  State<PanelStaffScreen> createState() => _PanelStaffScreenState();
}

class _PanelStaffScreenState extends State<PanelStaffScreen> {
  late final controller = widget.createController()..load();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _edit([PanelStaff? user]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StaffEditor(controller: controller, user: user),
    );
    if (saved == true && mounted) {
      _notice();
      await controller.load();
    }
  }

  Future<void> _doctorLink(PanelStaff user) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DoctorAccountEditor(controller: controller, user: user),
    );
    if (saved == true && mounted) {
      _notice();
      await controller.load();
    }
  }

  void _notice() {
    final text = strings(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.invitationSent == false
              ? text.staffMailFailed
              : controller.invitationSent == true
              ? text.staffMailSent
              : text.staffSaved,
        ),
      ),
    );
  }

  Future<void> _act(PanelStaff user, String action) async {
    final text = strings(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          action == 'invite'
              ? text.staffResend
              : action == 'resume'
              ? text.staffResume
              : user.active
              ? text.staffDeactivate
              : text.staffReactivate,
        ),
        content: Text(
          action == 'invite'
              ? text.staffResendConfirm
              : text.staffChangeConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(text.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(text.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final saved = await (action == 'invite'
        ? controller.invite(user)
        : action == 'resume'
        ? controller.resume(user)
        : controller.setActive(user));
    if (saved && mounted) {
      _notice();
      await controller.load();
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
              text.menuUsers,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${text.country}: ${controller.country}'),
            const SizedBox(height: 8),
            Text(text.staffIntro),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: controller.busy || controller.issue != null
                  ? null
                  : _edit,
              icon: const Icon(Icons.person_add_outlined),
              label: Text(text.staffCreate),
            ),
            const SizedBox(height: 16),
            if (controller.busy) const LinearProgressIndicator(),
            if (controller.issue != null) ...[
              Text(
                staffMessage(context, controller.issue!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(
                onPressed: controller.busy ? null : controller.load,
                child: Text(text.retry),
              ),
            ],
            if (!controller.busy &&
                controller.issue == null &&
                controller.users.isEmpty)
              Text(text.staffEmpty),
            for (final user in controller.users)
              StaffMemberCard(
                user: user,
                doctorId: user.doctorLinks[controller.country],
                onDoctorLink:
                    controller.canLinkDoctor(user) ||
                        (user.editable &&
                            !user.pending &&
                            user.doctorLinks.containsKey(controller.country))
                    ? () => _doctorLink(user)
                    : null,
                busy: controller.busy || controller.issue != null,
                onEdit: () => _edit(user),
                onToggle: () => _act(user, 'toggle'),
                onInvite: () => _act(user, 'invite'),
                onResume: () => _act(user, 'resume'),
              ),
            if (controller.nextCursor != null)
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.load(more: true),
                child: Text(text.staffMore),
              ),
          ],
        ),
      ),
    );
  }
}
