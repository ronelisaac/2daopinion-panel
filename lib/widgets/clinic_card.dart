import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/clinic.dart';

class ClinicCard extends StatelessWidget {
  const ClinicCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onToggle,
  });
  final Clinic record;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              record.input.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(record.active ? text.clinicActive : text.clinicInactive),
            Text('${record.country} · ${record.input.code}'),
            Text(text.clinicLocation(record.input.city, record.input.address)),
            if (record.input.email.isNotEmpty)
              Text(text.clinicEmailValue(record.input.email)),
            if (record.input.phone.isNotEmpty)
              Text(text.clinicPhoneValue(record.input.phone)),
            if (record.input.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(record.input.description),
            ],
            const SizedBox(height: 8),
            Text(
              text.clinicRevision(
                record.revision,
                MaterialLocalizations.of(
                  context,
                ).formatShortDate(record.updatedAt.toLocal()),
              ),
            ),
            if (onEdit != null || onToggle != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (onEdit != null)
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(text.clinicEdit),
                    ),
                  if (onToggle != null)
                    OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: Icon(
                        record.active
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                      label: Text(
                        record.active
                            ? text.clinicDeactivate
                            : text.clinicReactivate,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
