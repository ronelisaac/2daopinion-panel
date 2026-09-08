import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';
import '../domain/intake_request.dart';

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
