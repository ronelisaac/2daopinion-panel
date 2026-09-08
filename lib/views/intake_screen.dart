import 'package:flutter/material.dart';
import '../controllers/intake_controller.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';
import '../widgets/panel_shell.dart';
import '../widgets/intake_filters.dart';
import '../widgets/intake_pagination.dart';
import '../widgets/intake_request_card.dart';
import '../widgets/intake_request_table.dart';
import '../widgets/responsive_layout.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key, required this.createController});
  final IntakeController Function() createController;
  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  late final IntakeController controller;
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller = widget.createController()..load();
  }

  @override
  void dispose() {
    search.dispose();
    controller.dispose();
    super.dispose();
  }

  void _open(IntakeRequest request) => Navigator.pushNamed(
    context,
    '/requests/${Uri.encodeComponent(request.id)}',
  );
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return PanelShell(
      preview: true,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    text.inbox,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  tooltip: text.refresh,
                  onPressed: controller.busy ? null : controller.load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Text(text.inboxSubtitle),
            const SizedBox(height: 24),
            IntakeFilters(
              search: search,
              status: controller.query.status,
              busy: controller.busy,
              onSearch: () => controller.load(search: search.text),
              onStatus: (status) => controller.load(
                status: status,
                changeStatus: true,
                search: search.text,
              ),
            ),
            const SizedBox(height: 24),
            if (controller.busy) const LinearProgressIndicator(),
            if (controller.issue != null) ...[
              Text(text.failed),
              TextButton(onPressed: controller.load, child: Text(text.retry)),
            ],
            if (controller.result != null) ...[
              if (controller.result!.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(text.empty),
                ),
              if (controller.result!.items.isNotEmpty)
                ResponsiveLayout(
                  builder: (context, layout) => layout.width >= 900
                      ? IntakeRequestTable(
                          items: controller.result!.items,
                          onOpen: _open,
                        )
                      : Column(
                          children: [
                            for (final request in controller.result!.items)
                              IntakeRequestCard(
                                key: ValueKey(request.id),
                                request: request,
                                onOpen: () => _open(request),
                              ),
                          ],
                        ),
                ),
              const SizedBox(height: 24),
              IntakePagination(
                page: controller.query.page,
                total: controller.result!.total,
                onPrevious: controller.query.page == 0
                    ? null
                    : () => controller.load(page: controller.query.page - 1),
                onNext: controller.hasNext
                    ? () => controller.load(page: controller.query.page + 1)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
