import 'package:flutter/widgets.dart';
import '../domain/doctor_record.dart';
import 'localization.dart';

String doctorStatusLabel(BuildContext context, DoctorStatus status) =>
    switch (status) {
      DoctorStatus.pending => strings(context).doctorPending,
      DoctorStatus.verified => strings(context).doctorVerified,
      DoctorStatus.rejected => strings(context).doctorRejected,
      DoctorStatus.suspended => strings(context).doctorSuspended,
    };

String doctorIssueLabel(BuildContext context, DoctorIssue issue) =>
    switch (issue) {
      DoctorIssue.invalid => strings(context).doctorInvalid,
      DoctorIssue.denied => strings(context).doctorDenied,
      DoctorIssue.duplicate => strings(context).doctorDuplicate,
      DoctorIssue.conflict => strings(context).doctorConflict,
      DoctorIssue.unavailable => strings(context).doctorUnavailable,
    };
