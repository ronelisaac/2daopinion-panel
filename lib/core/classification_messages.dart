import 'package:flutter/widgets.dart';
import '../domain/intake_classification.dart';
import 'localization.dart';

String classificationSourceLabel(
  BuildContext context,
  ClassificationSource source,
) => switch (source) {
  ClassificationSource.unconfirmed => strings(
    context,
  ).classificationUnconfirmed,
  ClassificationSource.patientConfirmed => strings(
    context,
  ).classificationPatient,
  ClassificationSource.medicalReferral => strings(
    context,
  ).classificationMedical,
};
String classificationIssueLabel(
  BuildContext context,
  ClassificationIssue issue,
) => switch (issue) {
  ClassificationIssue.invalid => strings(context).classificationInvalid,
  ClassificationIssue.denied => strings(context).classificationDenied,
  ClassificationIssue.conflict => strings(context).classificationConflict,
  ClassificationIssue.limit => strings(context).classificationLimit,
  ClassificationIssue.unavailable => strings(context).classificationUnavailable,
};
