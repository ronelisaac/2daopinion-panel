import 'package:flutter/material.dart';
import '../core/localization.dart';

class IntakePagination extends StatelessWidget {
  const IntakePagination({
    super.key,
    required this.page,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });
  final int page;
  final int? total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 12,
    runSpacing: 8,
    children: [
      Text(
        total == null
            ? strings(context).pageWithoutTotal(page + 1)
            : strings(context).pageSummary(page + 1, total!),
      ),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: onPrevious,
            child: Text(strings(context).previous),
          ),
          OutlinedButton(onPressed: onNext, child: Text(strings(context).next)),
        ],
      ),
    ],
  );
}
