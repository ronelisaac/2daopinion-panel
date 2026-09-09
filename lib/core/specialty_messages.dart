import 'package:flutter/widgets.dart';
import '../domain/specialty.dart';
import 'localization.dart';

String specialtyIssueLabel(BuildContext context, SpecialtyIssue issue) =>
    switch (issue) {
      SpecialtyIssue.invalid => strings(context).specialtyInvalid,
      SpecialtyIssue.denied => strings(context).specialtyDenied,
      SpecialtyIssue.duplicate => strings(context).specialtyDuplicate,
      SpecialtyIssue.conflict => strings(context).specialtyConflict,
      SpecialtyIssue.unavailable => strings(context).specialtyUnavailable,
    };
