enum PanelRole { superadmin, operations, medicalDirector, finance, doctor }

enum PanelModule {
  dashboard,
  doctorWorkspace,
  requests,
  doctors,
  specialties,
  clinics,
  clinicalReview,
  assignments,
  myCases,
  agenda,
  reports,
  prescriptions,
  payments,
  payouts,
  reconciliation,
  pricing,
  users,
  countries,
  gateways,
  audit,
}

class PanelPrincipal {
  PanelPrincipal({
    required this.id,
    required Set<PanelRole> roles,
    required Set<String> countries,
    Map<String, Set<PanelRole>>? countryRoles,
    this.active = true,
  }) : roles = Set.unmodifiable(roles),
       countries = Set.unmodifiable(countries),
       countryRoles = countryRoles == null
           ? null
           : Map.unmodifiable(
               countryRoles.map(
                 (country, roles) =>
                     MapEntry(country, Set<PanelRole>.unmodifiable(roles)),
               ),
             );
  final String id;
  final Set<PanelRole> roles;
  final Set<String> countries;
  final bool active;
  final Map<String, Set<PanelRole>>? countryRoles;
  Set<PanelRole> rolesFor(String country) =>
      countryRoles?[country] ?? (countryRoles == null ? roles : {});
}

class PanelAccess {
  static const modules = {
    PanelRole.superadmin: {
      PanelModule.clinics,
      PanelModule.specialties,
      PanelModule.dashboard,
      PanelModule.users,
      PanelModule.countries,
      PanelModule.gateways,
      PanelModule.pricing,
      PanelModule.audit,
    },
    PanelRole.operations: {
      PanelModule.clinics,
      PanelModule.specialties,
      PanelModule.dashboard,
      PanelModule.requests,
      PanelModule.doctors,
      PanelModule.assignments,
      PanelModule.agenda,
    },
    PanelRole.medicalDirector: {
      PanelModule.clinics,
      PanelModule.specialties,
      PanelModule.dashboard,
      PanelModule.doctors,
      PanelModule.clinicalReview,
      PanelModule.audit,
    },
    PanelRole.finance: {
      PanelModule.dashboard,
      PanelModule.payments,
      PanelModule.payouts,
      PanelModule.reconciliation,
      PanelModule.pricing,
    },
    PanelRole.doctor: {
      PanelModule.doctorWorkspace,
      PanelModule.dashboard,
      PanelModule.myCases,
      PanelModule.agenda,
      PanelModule.reports,
      PanelModule.prescriptions,
      PanelModule.payouts,
    },
  };
  static bool allows(
    PanelPrincipal principal,
    String country,
    PanelModule module,
  ) =>
      principal.active &&
      principal.countries.contains(country) &&
      principal
          .rolesFor(country)
          .any((role) => modules[role]!.contains(module));
}

enum PanelAccessIssue {
  denied,
  unavailable,
  invalid,
  invalidCredentials,
  emailNotVerified,
  tooManyRequests,
  signOutFailed,
}

class PanelAccessFailure implements Exception {
  const PanelAccessFailure(this.issue);
  final PanelAccessIssue issue;
}
