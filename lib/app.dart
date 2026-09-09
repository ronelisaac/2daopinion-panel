import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/panel_session_scope.dart';
import 'controllers/intake_controller.dart';
import 'controllers/intake_detail_controller.dart';
import 'controllers/intake_classification_controller.dart';
import 'controllers/intake_assignment_controller.dart';
import 'domain/repositories/intake_assignment_repository.dart';
import 'domain/repositories/intake_classification_repository.dart';
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
import 'controllers/doctor_controller.dart';
import 'domain/repositories/doctor_repository.dart';
import 'views/doctors_screen.dart';
import 'controllers/specialty_controller.dart';
import 'domain/repositories/specialty_repository.dart';
import 'views/specialties_screen.dart';
import 'controllers/clinic_controller.dart';
import 'domain/repositories/clinic_repository.dart';
import 'views/clinics_screen.dart';
import 'domain/repositories/doctor_workspace_repository.dart';
import 'domain/repositories/doctor_administration_repository.dart';
import 'controllers/doctor_workspace_controller.dart';
import 'views/doctor_workspace_screen.dart';

class PanelApp extends StatefulWidget {
  const PanelApp({
    super.key,
    required this.identity,
    this.repository,
    this.staffRepository,
    this.doctorRepository,
    this.specialtyRepository,
    this.clinicRepository,
    this.workspaceRepository,
    this.administrationRepository,
    this.classificationRepository,
    this.assignmentRepository,
  });
  final PanelIdentityRepository identity;
  final IntakeRepository? repository;
  final IntakeClassificationRepository? classificationRepository;
  final IntakeAssignmentRepository? assignmentRepository;
  final PanelStaffRepository? staffRepository;
  final DoctorRepository? doctorRepository;
  final SpecialtyRepository? specialtyRepository;
  final ClinicRepository? clinicRepository;
  final DoctorWorkspaceRepository? workspaceRepository;
  final DoctorAdministrationRepository? administrationRepository;
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
    final doctorOnly =
        principal.rolesFor(country).length == 1 &&
        principal.rolesFor(country).contains(PanelRole.doctor);
    final moduleName = segments.isEmpty
        ? (doctorOnly && widget.workspaceRepository != null
              ? 'doctorWorkspace'
              : widget.repository != null &&
                    principal.rolesFor(country).contains(PanelRole.operations)
              ? 'requests'
              : 'dashboard')
        : segments.first;
    final matching = PanelModule.values.where(
      (item) => item.name == moduleName,
    );
    final module = matching.isEmpty ? null : matching.first;
    if (module == null ||
        !PanelAccess.visible(principal, country, module) ||
        segments.length > 2 ||
        (segments.length == 2 && module != PanelModule.requests)) {
      return const PanelModuleScreen(denied: true);
    }
    if (module == PanelModule.doctorWorkspace &&
        !PanelAccess.allows(principal, country, module)) {
      return PanelModuleScreen(module: module, roleRequired: true);
    }
    if ((module == PanelModule.doctorWorkspace ||
            (module == PanelModule.dashboard && doctorOnly)) &&
        widget.workspaceRepository != null) {
      return DoctorWorkspaceScreen(
        createController: () => DoctorWorkspaceController(
          widget.workspaceRepository!,
          principal,
          country,
        ),
      );
    }
    if (module == PanelModule.requests && widget.repository != null) {
      final scoped = ScopedIntakeRepository(
        widget.repository!,
        principal,
        country,
      );
      return segments.length == 2
          ? IntakeDetailScreen(
              createAssignmentController: widget.assignmentRepository == null
                  ? null
                  : () => IntakeAssignmentController(
                      widget.assignmentRepository!,
                      principal,
                      country,
                      segments.last,
                    ),
              createClassificationController:
                  widget.classificationRepository != null &&
                      widget.specialtyRepository != null
                  ? () => IntakeClassificationController(
                      widget.classificationRepository!,
                      widget.specialtyRepository!,
                      principal,
                      country,
                      segments.last,
                    )
                  : null,
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
    if (module == PanelModule.doctors && widget.doctorRepository != null) {
      return DoctorsScreen(
        createController: () => DoctorController(
          widget.doctorRepository!,
          principal,
          country,
          specialtyRepository: widget.specialtyRepository,
          administrationRepository: widget.administrationRepository,
        ),
      );
    }
    if (module == PanelModule.specialties &&
        widget.specialtyRepository != null) {
      return SpecialtiesScreen(
        createController: () => SpecialtyController(
          widget.specialtyRepository!,
          principal,
          country,
        ),
      );
    }
    if (module == PanelModule.clinics && widget.clinicRepository != null) {
      return ClinicsScreen(
        createController: () =>
            ClinicController(widget.clinicRepository!, principal, country),
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
