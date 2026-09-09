import 'package:flutter/material.dart';
import '../controllers/intake_detail_controller.dart';
import '../controllers/intake_classification_controller.dart';
import '../widgets/intake_classification_card.dart';
import '../core/localization.dart';
import '../domain/intake_request.dart';
import '../widgets/panel_shell.dart';
import '../widgets/intake_detail_content.dart';

class IntakeDetailScreen extends StatefulWidget {
  const IntakeDetailScreen({
    super.key,
    required this.createController,
    this.createClassificationController,
  });
  final IntakeDetailController Function() createController;
  final IntakeClassificationController Function()?
  createClassificationController;
  @override
  State<IntakeDetailScreen> createState() => _IntakeDetailScreenState();
}

class _IntakeDetailScreenState extends State<IntakeDetailScreen> {
  late final IntakeDetailController controller;
  @override
  void initState() {
    super.initState();
    controller = widget.createController()..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PanelShell(
    preview: false,
    detail: true,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.busy) const LinearProgressIndicator(),
          if (controller.issue != null) ...[
            Text(
              controller.issue == IntakeIssue.notFound
                  ? strings(context).notFound
                  : strings(context).failed,
            ),
            TextButton(
              onPressed: controller.load,
              child: Text(strings(context).retry),
            ),
          ],
          if (controller.request != null)
            IntakeDetailContent(request: controller.request!),
          if (controller.request != null &&
              widget.createClassificationController != null) ...[
            const SizedBox(height: 24),
            IntakeClassificationCard(
              createController: widget.createClassificationController!,
            ),
          ],
        ],
      ),
    ),
  );
}
