import 'package:flutter/widgets.dart';
import '../domain/intake_assignment.dart';
import 'localization.dart';

String assignmentIssueLabel(BuildContext context, AssignmentIssue issue) =>
    switch (issue) {
      AssignmentIssue.invalid => strings(context).assignmentInvalid,
      AssignmentIssue.denied => strings(context).assignmentDenied,
      AssignmentIssue.conflict => strings(context).assignmentConflict,
      AssignmentIssue.limit => strings(context).assignmentLimit,
      AssignmentIssue.unavailable => strings(context).assignmentUnavailable,
    };
String assignmentReasonLabel(BuildContext context, AssignmentReason reason) =>
    switch (reason) {
      AssignmentReason.wrongSelection => strings(context).assignmentWrong,
      AssignmentReason.availabilityChanged => strings(
        context,
      ).assignmentAvailability,
      AssignmentReason.routingChanged => strings(context).assignmentRouting,
    };
