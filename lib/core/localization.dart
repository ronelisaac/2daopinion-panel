import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';
import '../domain/intake_request.dart';
import '../domain/panel_access.dart';

String roleLabel(BuildContext context, PanelRole role) => switch (role) {
  PanelRole.superadmin => strings(context).roleSuperadmin,
  PanelRole.operations => strings(context).roleOperations,
  PanelRole.medicalDirector => strings(context).roleMedical,
  PanelRole.finance => strings(context).roleFinance,
  PanelRole.doctor => strings(context).roleDoctor,
};

String moduleLabel(BuildContext context, PanelModule module) =>
    switch (module) {
      PanelModule.dashboard => strings(context).menuDashboard,
      PanelModule.requests => strings(context).inbox,
      PanelModule.doctors => strings(context).menuDoctors,
      PanelModule.specialties => strings(context).menuSpecialties,
      PanelModule.clinics => strings(context).menuClinics,
      PanelModule.clinicalReview => strings(context).menuClinicalReview,
      PanelModule.assignments => strings(context).menuAssignments,
      PanelModule.myCases => strings(context).menuMyCases,
      PanelModule.agenda => strings(context).menuAgenda,
      PanelModule.reports => strings(context).menuReports,
      PanelModule.prescriptions => strings(context).menuPrescriptions,
      PanelModule.payments => strings(context).menuPayments,
      PanelModule.payouts => strings(context).menuPayouts,
      PanelModule.reconciliation => strings(context).menuReconciliation,
      PanelModule.pricing => strings(context).menuPricing,
      PanelModule.users => strings(context).menuUsers,
      PanelModule.countries => strings(context).menuCountries,
      PanelModule.gateways => strings(context).menuGateways,
      PanelModule.audit => strings(context).menuAudit,
    };

String accessMessage(BuildContext context, PanelAccessIssue issue) =>
    switch (issue) {
      PanelAccessIssue.denied => strings(context).accessDenied,
      PanelAccessIssue.unavailable => strings(context).loginUnavailable,
      PanelAccessIssue.invalid => strings(context).invalidLogin,
      PanelAccessIssue.invalidCredentials => strings(
        context,
      ).invalidCredentials,
      PanelAccessIssue.emailNotVerified => strings(context).emailNotVerified,
      PanelAccessIssue.tooManyRequests => strings(context).tooManyRequests,
      PanelAccessIssue.signOutFailed => strings(context).signOutFailed,
    };

AppLocalizations strings(BuildContext context) => AppLocalizations.of(context)!;

String statusLabel(BuildContext context, IntakeStatus status) =>
    switch (status) {
      IntakeStatus.received => strings(context).received,
      IntakeStatus.reviewing => strings(context).reviewing,
      IntakeStatus.needsDocuments => strings(context).needsDocuments,
    };

String modeLabel(BuildContext context, ServiceMode mode) => switch (mode) {
  ServiceMode.documentary => strings(context).documentary,
  ServiceMode.consultation => strings(context).consultation,
};

String documentLabel(BuildContext context, DocumentCategory category) =>
    switch (category) {
      DocumentCategory.report => strings(context).report,
      DocumentCategory.examination => strings(context).examination,
      DocumentCategory.prescription => strings(context).prescription,
    };
