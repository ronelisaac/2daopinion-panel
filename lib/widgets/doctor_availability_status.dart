import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/localization.dart';
import '../domain/doctor_operational_availability.dart';

class DoctorAvailabilityStatus extends StatelessWidget {
  const DoctorAvailabilityStatus({super.key, required this.availability});
  final DoctorOperationalAvailability availability;
  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    final available = availability.state == DoctorAvailabilityState.available;
    final label = switch (availability.state) {
      DoctorAvailabilityState.available => text.doctorAvailabilityAvailable,
      DoctorAvailabilityState.paused => text.doctorAvailabilityPaused,
      DoctorAvailabilityState.needsConfirmation =>
        text.doctorAvailabilityConfirmation,
      DoctorAvailabilityState.unlinked => text.doctorAvailabilityUnlinked,
      DoctorAvailabilityState.blockedAdministration =>
        text.doctorAvailabilityAdministration,
      DoctorAvailabilityState.blockedReview => text.doctorAvailabilityReview,
      DoctorAvailabilityState.blockedSpecialty =>
        text.doctorAvailabilitySpecialty,
      DoctorAvailabilityState.blockedAccount => text.doctorAvailabilityAccount,
      DoctorAvailabilityState.linkMismatch => text.doctorAvailabilityLink,
      DoctorAvailabilityState.unavailable => text.doctorAvailabilityUnknown,
    };
    final date = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                available ? Icons.check_circle_outline : Icons.info_outline,
                color: available ? Theme.of(context).colorScheme.primary : null,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text.doctorAvailabilityChecked(
              date.format(availability.checkedAt.toLocal()),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (availability.confirmedAt != null)
            Text(
              text.doctorAvailabilityConfirmed(
                date.format(availability.confirmedAt!.toLocal()),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
