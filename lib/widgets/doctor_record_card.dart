import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/doctor_messages.dart';
import '../core/localization.dart';
import '../domain/doctor_record.dart';

class DoctorRecordCard extends StatelessWidget {
  const DoctorRecordCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onReview,
  });
  final DoctorRecord record;
  final VoidCallback? onEdit;
  final VoidCallback? onReview;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final date = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
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
            Text(
              doctorStatusLabel(context, record.status),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              text.doctorRegistrySummary(record.country, record.input.registry),
            ),
            Text(record.input.specialty),
            Text(
              text.doctorRevision(
                record.revision,
                date.format(record.updatedAt.toLocal()),
              ),
            ),
            if (record.review != null) ...[
              const Divider(),
              Text(
                text.doctorReviewTrace(
                  date.format(record.reviewedAt!.toLocal()),
                  record.reviewedBy!,
                ),
              ),
              Text(record.review!.evidence),
              Text(record.review!.note),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (onEdit != null)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(text.doctorEdit),
                  ),
                if (onReview != null)
                  FilledButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(text.doctorReview),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
