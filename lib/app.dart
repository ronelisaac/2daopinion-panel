import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/panel_session_scope.dart';
import 'controllers/intake_controller.dart';
import 'controllers/intake_detail_controller.dart';
import 'controllers/panel_login_controller.dart';
import 'controllers/panel_session_controller.dart';
import 'controllers/panel_staff_controller.dart';
import 'domain/repositories/panel_staff_repository.dart';
import 'views/panel_staff_screen.dart';
import 'domain/panel_access.dart';
import 'domain/repositories/intake_repository.dart';
import 'domain/repositories/panel_identity_repository.dart';
import 'l10n/app_localizations.dart';
import 'repositories/scoped_intake_repository.dart';
import 'views/intake_screen.dart';
import 'views/intake_detail_screen.dart';
import 'views/panel_login_screen.dart';
import 'views/panel_module_screen.dart';

class PanelApp extends StatefulWidget {
  const PanelApp({
    super.key,
    required this.identity,
    this.repository,
    this.staffRepository,
  });
  final PanelIdentityRepository identity;
  final IntakeRepository? repository;
  final PanelStaffRepository? staffRepository;
  @override
  State<PanelApp> createState() => _PanelAppState();
}

class _PanelAppState extends State<PanelApp> {
  late final session = PanelSessionController(widget.identity);
  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  Widget _page(String name) {
    final principal = session.principal;
    if (principal == null) {
      return PanelLoginScreen(
        createController: () => PanelLoginController(widget.identity),
      );
    }
    final country = session.country;
    final segments = Uri.tryParse(name)?.pathSegments ?? [];
    final moduleName = segments.isEmpty
        ? (widget.repository != null &&
                  PanelAccess.allows(principal, country, PanelModule.requests)
              ? 'requests'
              : 'dashboard')
        : segments.first;
    final matching = PanelModule.values.where(
      (item) => item.name == moduleName,
    );
    final module = matching.isEmpty ? null : matching.first;
    if (module == null ||
        !PanelAccess.allows(principal, country, module) ||
        segments.length > 2 ||
        (segments.length == 2 && module != PanelModule.requests)) {
      return const PanelModuleScreen(denied: true);
    }
    if (module == PanelModule.requests && widget.repository != null) {
      final scoped = ScopedIntakeRepository(
        widget.repository!,
        principal,
        country,
      );
      return segments.length == 2
          ? IntakeDetailScreen(
              createController: () =>
                  IntakeDetailController(scoped, segments.last),
            )
          : IntakeScreen(createController: () => IntakeController(scoped));
    }
    if (module == PanelModule.users && widget.staffRepository != null) {
      return PanelStaffScreen(
        createController: () =>
            PanelStaffController(widget.staffRepository!, principal, country),
      );
    }
    return PanelModuleScreen(module: module);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) => MaterialApp(
      key: ValueKey(session.epoch),
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildAppTheme(),
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) =>
          PanelSessionScope(session: session, child: child!),
      initialRoute: '/',
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _page(settings.name ?? '/'),
      ),
    ),
  );
}
