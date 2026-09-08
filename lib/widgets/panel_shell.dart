import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import 'responsive_layout.dart';
import 'responsive_content.dart';
import 'preview_banner.dart';
import 'panel_menu.dart';

class PanelShell extends StatelessWidget {
  const PanelShell({
    super.key,
    required this.child,
    this.detail = false,
    this.preview = false,
  });
  final Widget child;
  final bool detail;
  final bool preview;

  void _scope(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings(context).scope),
      content: SingleChildScrollView(child: Text(strings(context).scopeBody)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings(context).close),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    builder: (context, layout) {
      final text = strings(context);
      return Scaffold(
        drawer: layout.isExpanded ? null : const Drawer(child: PanelMenu()),
        appBar: AppBar(
          title: Text(detail ? text.detail : text.workspace),
          titleSpacing: detail ? 0 : 16,
          leading: detail
              ? BackButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                )
              : null,
          actions: [
            if (detail && !layout.isExpanded)
              Builder(
                builder: (context) => IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).openAppDrawerTooltip,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ),
            IconButton(
              tooltip: text.scope,
              onPressed: () => _scope(context),
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            color: AppColors.pageBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text.footer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (layout.isExpanded)
              const SizedBox(
                width: 272,
                child: ColoredBox(
                  color: AppColors.pageBackground,
                  child: PanelMenu(),
                ),
              ),
            Expanded(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(layout.pagePadding),
                  child: ResponsiveContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!layout.isExpanded) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 56,
                              semanticLabel: text.appTitle,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (preview)
                          const PreviewBanner()
                        else
                          Text(text.developmentNotice),
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
