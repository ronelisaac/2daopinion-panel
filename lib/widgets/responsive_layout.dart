import 'package:flutter/material.dart';

enum WindowSize { compact, medium, expanded }

class ResponsiveMetrics {
  const ResponsiveMetrics(this.width);

  static const tabletBreakpoint = 600.0;
  static const desktopBreakpoint = 1024.0;
  static const contentMaxWidth = 1200.0;

  final double width;

  WindowSize get windowSize => width < tabletBreakpoint
      ? WindowSize.compact
      : width < desktopBreakpoint
      ? WindowSize.medium
      : WindowSize.expanded;

  bool get isCompact => windowSize == WindowSize.compact;
  bool get isExpanded => windowSize == WindowSize.expanded;
  double get pagePadding => isCompact ? 24 : 40;
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.builder});

  final Widget Function(BuildContext context, ResponsiveMetrics layout) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        builder(context, ResponsiveMetrics(constraints.maxWidth)),
  );
}
