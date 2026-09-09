import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/specialty.dart';

class SpecialtyCard extends StatelessWidget {
  const SpecialtyCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onToggle,
  });
  final Specialty record;
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
            Text(record.active ? text.specialtyActive : text.specialtyInactive),
            Text('${record.country} · ${record.input.code}'),
            if (record.input.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(record.input.description),
            ],
            const SizedBox(height: 8),
            Text(
              text.specialtyRevision(
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
                      label: Text(text.specialtyEdit),
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
                            ? text.specialtyDeactivate
                            : text.specialtyReactivate,
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
