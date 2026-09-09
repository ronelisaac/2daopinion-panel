import 'package:flutter/widgets.dart';
import '../domain/clinic.dart';
import 'localization.dart';

String clinicIssueLabel(BuildContext context, ClinicIssue issue) =>
    switch (issue) {
      ClinicIssue.invalid => strings(context).clinicInvalid,
      ClinicIssue.denied => strings(context).clinicDenied,
      ClinicIssue.duplicate => strings(context).clinicDuplicate,
      ClinicIssue.conflict => strings(context).clinicConflict,
      ClinicIssue.unavailable => strings(context).clinicUnavailable,
    };
