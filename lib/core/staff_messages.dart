import 'package:flutter/widgets.dart';
import '../domain/panel_staff.dart';
import 'localization.dart';

String staffMessage(BuildContext context, StaffIssue issue) => switch (issue) {
  StaffIssue.denied => strings(context).staffDenied,
  StaffIssue.invalid => strings(context).staffInvalid,
  StaffIssue.duplicate => strings(context).staffDuplicate,
  StaffIssue.conflict => strings(context).staffConflict,
  StaffIssue.protectedAccount => strings(context).staffProtected,
  StaffIssue.limit => strings(context).staffLimit,
  StaffIssue.unavailable => strings(context).staffUnavailable,
};
