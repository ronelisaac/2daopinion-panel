import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/panel_staff.dart';

class StaffMemberCard extends StatelessWidget {
  const StaffMemberCard({
    super.key,
    required this.user,
    required this.busy,
    required this.onEdit,
    required this.onToggle,
    required this.onInvite,
    required this.onResume,
    this.onDoctorLink,
    this.doctorId,
  });
  final VoidCallback? onDoctorLink;
  final String? doctorId;
  final PanelStaff user;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onInvite;
  final VoidCallback onResume;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(
                    user.pending
                        ? text.staffPending
                        : user.active
                        ? text.staffActive
                        : text.staffInactive,
                  ),
                ),
                Chip(
                  label: Text(
                    user.verified ? text.staffVerified : text.staffUnverified,
                  ),
                ),
              ],
            ),
            for (final entry in user.memberships.entries)
              Text(
                '${entry.key} · ${entry.value.map((role) => roleLabel(context, role)).join(' · ')}',
              ),
            if (doctorId != null) Text('${text.staffDoctorLinked}: $doctorId'),
            if (onDoctorLink != null)
              TextButton.icon(
                onPressed: busy ? null : onDoctorLink,
                icon: const Icon(Icons.link),
                label: Text(
                  doctorId == null
                      ? text.staffDoctorLink
                      : text.staffDoctorUnlink,
                ),
              ),
            if (!user.invitationSent) Text(text.staffInviteNotSent),
            if (!user.editable)
              Text(
                text.staffReadOnly,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (user.editable)
              Wrap(
                spacing: 8,
                children: user.pending
                    ? [
                        TextButton.icon(
                          onPressed: busy ? null : onResume,
                          icon: const Icon(Icons.sync),
                          label: Text(text.staffResume),
                        ),
                      ]
                    : [
                        TextButton.icon(
                          onPressed: busy ? null : onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(text.staffEdit),
                        ),
                        TextButton.icon(
                          onPressed: busy ? null : onToggle,
                          icon: Icon(
                            user.active
                                ? Icons.person_off_outlined
                                : Icons.person_outline,
                          ),
                          label: Text(
                            user.active
                                ? text.staffDeactivate
                                : text.staffReactivate,
                          ),
                        ),
                        if (user.active)
                          TextButton.icon(
                            onPressed: busy ? null : onInvite,
                            icon: const Icon(Icons.mail_outline),
                            label: Text(text.staffResend),
                          ),
                      ],
              ),
          ],
        ),
      ),
    );
  }
}
