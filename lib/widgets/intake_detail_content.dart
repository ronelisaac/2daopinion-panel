import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';
import 'intake_status_badge.dart';

class IntakeDetailContent extends StatelessWidget {
  const IntakeDetailContent({super.key, required this.request});
  final IntakeRequest request;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final material = MaterialLocalizations.of(context);
    final date = request.createdAt.toLocal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          request.reference,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: IntakeStatusBadge(status: request.status),
        ),
        const SizedBox(height: 24),
        Text(
          '${text.country}: ${request.countryCode == 'CL' ? text.chile : request.countryCode}',
        ),
        Text('${text.modality}: ${modeLabel(context, request.mode)}'),
        Text(
          '${text.date}: ${material.formatCompactDate(date)} · ${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
        ),
        const SizedBox(height: 24),
        Text(text.documents, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(text.metadataOnly),
        Text(text.documentCount(request.documentCount)),
        const SizedBox(height: 12),
        for (final document in request.documents)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(documentLabel(context, document.category)),
                  ),
                  const SizedBox(width: 12),
                  Text(document.extension),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(text.video, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text(request.hasVideo ? text.withVideo : text.withoutVideo),
      ],
    );
  }
}
