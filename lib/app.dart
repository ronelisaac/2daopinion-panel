import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'controllers/intake_controller.dart';
import 'controllers/intake_detail_controller.dart';
import 'domain/repositories/intake_repository.dart';
import 'l10n/app_localizations.dart';
import 'views/intake_screen.dart';
import 'views/intake_detail_screen.dart';

class PanelApp extends StatelessWidget {
  const PanelApp({super.key, required this.repository});
  final IntakeRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    theme: buildAppTheme(),
    locale: const Locale('es'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    onGenerateRoute: (settings) {
      final uri = Uri.tryParse(settings.name ?? '/');
      final segments = uri?.pathSegments ?? [];
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => segments.isEmpty
            ? IntakeScreen(createController: () => IntakeController(repository))
            : IntakeDetailScreen(
                createController: () => IntakeDetailController(
                  repository,
                  segments.length == 2 && segments.first == 'requests'
                      ? segments.last
                      : '',
                ),
              ),
      );
    },
  );
}
