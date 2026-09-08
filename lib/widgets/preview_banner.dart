import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';

class PreviewBanner extends StatelessWidget {
  const PreviewBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.science_outlined),
        const SizedBox(width: 12),
        Expanded(child: Text(strings(context).previewNotice)),
      ],
    ),
  );
}
