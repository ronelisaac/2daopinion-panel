import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';
import 'intake_status_badge.dart';

class IntakeRequestTable extends StatelessWidget {
  const IntakeRequestTable({
    super.key,
    required this.items,
    required this.onOpen,
  });
  final List<IntakeRequest> items;
  final ValueChanged<IntakeRequest> onOpen;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 72,
        dataRowMaxHeight: 112,
        columnSpacing: 24,
        columns: [
          DataColumn(label: Text(text.reference)),
          DataColumn(label: Text(text.status)),
          DataColumn(label: Text(text.modality)),
          DataColumn(label: Text(text.documents)),
          DataColumn(label: Text(text.view)),
        ],
        rows: [
          for (final request in items)
            DataRow(
              cells: [
                DataCell(Text(request.reference)),
                DataCell(
                  SizedBox(
                    width: 210,
                    child: IntakeStatusBadge(status: request.status),
                  ),
                ),
                DataCell(Text(modeLabel(context, request.mode))),
                DataCell(Text(text.documentCount(request.documentCount))),
                DataCell(
                  IconButton(
                    tooltip: '${text.view} ${request.reference}',
                    onPressed: () => onOpen(request),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
