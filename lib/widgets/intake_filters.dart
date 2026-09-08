import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';

class IntakeFilters extends StatelessWidget {
  const IntakeFilters({
    super.key,
    required this.search,
    required this.status,
    required this.busy,
    required this.onSearch,
    required this.onStatus,
  });
  final TextEditingController search;
  final IntakeStatus? status;
  final bool busy;
  final VoidCallback onSearch;
  final ValueChanged<IntakeStatus?> onStatus;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: search,
          maxLength: 64,
          textInputAction: TextInputAction.search,
          onSubmitted: busy ? null : (_) => onSearch(),
          decoration: InputDecoration(
            labelText: text.search,
            hintText: text.searchHint,
            suffixIcon: IconButton(
              tooltip: text.searchAction,
              onPressed: busy ? null : onSearch,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(text.all),
              selected: status == null,
              onSelected: busy ? null : (_) => onStatus(null),
            ),
            for (final option in IntakeStatus.values)
              ChoiceChip(
                label: Text(statusLabel(context, option)),
                selected: status == option,
                onSelected: busy ? null : (_) => onStatus(option),
              ),
          ],
        ),
      ],
    );
  }
}
