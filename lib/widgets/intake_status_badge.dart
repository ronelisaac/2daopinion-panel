import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';

class IntakeStatusBadge extends StatelessWidget {
  const IntakeStatusBadge({super.key, required this.status});
  final IntakeStatus status;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(switch (status) {
          IntakeStatus.received => Icons.inbox_outlined,
          IntakeStatus.reviewing => Icons.fact_check_outlined,
          IntakeStatus.needsDocuments => Icons.folder_off_outlined,
        }, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(statusLabel(context, status))),
      ],
    ),
  );
}
