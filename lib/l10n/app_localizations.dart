import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'2daOpinion · Panel'**
  String get appTitle;

  /// No description provided for @workspace.
  ///
  /// In es, this message translates to:
  /// **'Panel administrativo'**
  String get workspace;

  /// No description provided for @inbox.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get inbox;

  /// No description provided for @inboxSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Organiza la recepción y revisa la documentación disponible.'**
  String get inboxSubtitle;

  /// No description provided for @previewNotice.
  ///
  /// In es, this message translates to:
  /// **'EJEMPLO · Solo datos ficticios. No hay acceso a pacientes ni operaciones reales.'**
  String get previewNotice;

  /// No description provided for @scope.
  ///
  /// In es, this message translates to:
  /// **'Alcance de esta vista previa'**
  String get scope;

  /// No description provided for @scopeBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes explorar solicitudes de ejemplo, filtrar y revisar sus metadatos. No se conecta a Firebase, no valida documentos, no asigna médicos ni envía mensajes. El acceso administrativo real requiere autenticación y permisos por rol/caso, todavía pendientes.'**
  String get scopeBody;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get close;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar por código'**
  String get search;

  /// No description provided for @reference.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get reference;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. DEMO-0001'**
  String get searchHint;

  /// No description provided for @searchAction.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchAction;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @received.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get received;

  /// No description provided for @reviewing.
  ///
  /// In es, this message translates to:
  /// **'En revisión documental'**
  String get reviewing;

  /// No description provided for @needsDocuments.
  ///
  /// In es, this message translates to:
  /// **'Falta documentación'**
  String get needsDocuments;

  /// No description provided for @documentary.
  ///
  /// In es, this message translates to:
  /// **'Revisión documental'**
  String get documentary;

  /// No description provided for @consultation.
  ///
  /// In es, this message translates to:
  /// **'Revisión + consulta'**
  String get consultation;

  /// No description provided for @country.
  ///
  /// In es, this message translates to:
  /// **'País'**
  String get country;

  /// No description provided for @chile.
  ///
  /// In es, this message translates to:
  /// **'Chile'**
  String get chile;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha de recepción'**
  String get date;

  /// No description provided for @modality.
  ///
  /// In es, this message translates to:
  /// **'Modalidad'**
  String get modality;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado de ejemplo'**
  String get status;

  /// No description provided for @documents.
  ///
  /// In es, this message translates to:
  /// **'Documentación disponible'**
  String get documents;

  /// No description provided for @documentCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 archivo de ejemplo} other{{count} archivos de ejemplo}}'**
  String documentCount(int count);

  /// No description provided for @video.
  ///
  /// In es, this message translates to:
  /// **'Video explicativo opcional'**
  String get video;

  /// No description provided for @withVideo.
  ///
  /// In es, this message translates to:
  /// **'Incluido en este ejemplo'**
  String get withVideo;

  /// No description provided for @withoutVideo.
  ///
  /// In es, this message translates to:
  /// **'No incluido · No es requisito'**
  String get withoutVideo;

  /// No description provided for @report.
  ///
  /// In es, this message translates to:
  /// **'Informe médico'**
  String get report;

  /// No description provided for @examination.
  ///
  /// In es, this message translates to:
  /// **'Estudio o examen'**
  String get examination;

  /// No description provided for @prescription.
  ///
  /// In es, this message translates to:
  /// **'Receta aportada por el paciente'**
  String get prescription;

  /// No description provided for @metadataOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo metadatos ficticios: no hay archivos para abrir o descargar. Recibir documentación no significa validarla clínicamente.'**
  String get metadataOnly;

  /// No description provided for @detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de solicitud'**
  String get detail;

  /// No description provided for @view.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get view;

  /// No description provided for @empty.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes que coincidan con los filtros.'**
  String get empty;

  /// No description provided for @failed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la información. Inténtalo nuevamente.'**
  String get failed;

  /// No description provided for @notFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró esta solicitud de ejemplo.'**
  String get notFound;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar solicitudes'**
  String get refresh;

  /// No description provided for @previous.
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @pageSummary.
  ///
  /// In es, this message translates to:
  /// **'Página {page} · {total, plural, =1{1 resultado} other{{total} resultados}}'**
  String pageSummary(int page, int total);

  /// No description provided for @footer.
  ///
  /// In es, this message translates to:
  /// **'2daOpinion · Desarrollo · Sin atención clínica'**
  String get footer;

  /// No description provided for @previewLabel.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get previewLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
