import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';
import 'intake_status_badge.dart';

class IntakeRequestCard extends StatelessWidget {
  const IntakeRequestCard({
    super.key,
    required this.request,
    required this.onOpen,
  });
  final IntakeRequest request;
  final VoidCallback onOpen;
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
              request.reference,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: IntakeStatusBadge(status: request.status),
            ),
            const SizedBox(height: 12),
            Text(modeLabel(context, request.mode)),
            Text(text.documentCount(request.documentCount)),
            Text(
              MaterialLocalizations.of(
                context,
              ).formatCompactDate(request.createdAt.toLocal()),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward),
                label: Text(text.view),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
