import 'package:flutter/material.dart';

import 'responsive_layout.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveMetrics.contentMaxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
