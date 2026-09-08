import 'package:flutter/widgets.dart';
import '../controllers/panel_session_controller.dart';

class PanelSessionScope extends InheritedNotifier<PanelSessionController> {
  const PanelSessionScope({
    super.key,
    required PanelSessionController session,
    required super.child,
  }) : super(notifier: session);
  static PanelSessionController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PanelSessionScope>()!
      .notifier!;
}
