enum DoctorAvailabilityState {
  available,
  paused,
  needsConfirmation,
  unlinked,
  blockedAdministration,
  blockedReview,
  blockedSpecialty,
  blockedAccount,
  linkMismatch,
  unavailable,
}

class DoctorOperationalAvailability {
  const DoctorOperationalAvailability({
    required this.state,
    required this.checkedAt,
    this.confirmedAt,
  });
  final DoctorAvailabilityState state;
  final DateTime checkedAt;
  final DateTime? confirmedAt;
}
