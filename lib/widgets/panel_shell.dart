import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import 'responsive_layout.dart';
import 'responsive_content.dart';
import 'preview_banner.dart';

class PanelShell extends StatelessWidget {
  const PanelShell({super.key, required this.child, this.detail = false});
  final Widget child;
  final bool detail;

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
        appBar: AppBar(
          title: Text(detail ? text.detail : text.workspace),
          titleSpacing: detail ? 0 : 24,
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
              SizedBox(
                width: 224,
                child: ColoredBox(
                  color: AppColors.pageBackground,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 76,
                            semanticLabel: text.appTitle,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            text.previewLabel,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.inbox_outlined),
                            title: Text(text.inbox),
                            selected: !detail,
                            onTap: detail
                                ? () => Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (_) => false,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        const PreviewBanner(),
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
