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

  /// No description provided for @pageWithoutTotal.
  ///
  /// In es, this message translates to:
  /// **'Página {page}'**
  String pageWithoutTotal(int page);

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
  /// **'Recepción de solicitudes de desarrollo. Solo código, país, modalidad y fecha; sin acceso al contenido clínico, archivos ni pagos.'**
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
  /// **'El acceso usa Firebase Authentication y requiere permisos administrativos asignados desde un entorno confiable. No hay registro público ni creación automática de roles. Los módulos operativos y las altas internas están pendientes; no se accede a datos clínicos.'**
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
  /// **'Pega el código completo SO-…'**
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
  /// **'Estado'**
  String get status;

  /// No description provided for @documents.
  ///
  /// In es, this message translates to:
  /// **'Documentación disponible'**
  String get documents;

  /// No description provided for @documentCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 archivo} other{{count} archivos}}'**
  String documentCount(int count);

  /// No description provided for @video.
  ///
  /// In es, this message translates to:
  /// **'Video explicativo opcional'**
  String get video;

  /// No description provided for @withVideo.
  ///
  /// In es, this message translates to:
  /// **'Incluido'**
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
  /// **'Esta etapa recibe solo texto privado del paciente y un registro administrativo separado. Los archivos y el video no se envían todavía. El contenido clínico no es accesible desde esta bandeja; no hay revisión ni asignación médica habilitada.'**
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
  /// **'No se encontró esta solicitud.'**
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

  /// No description provided for @roleSuperadmin.
  ///
  /// In es, this message translates to:
  /// **'Superadmin'**
  String get roleSuperadmin;

  /// No description provided for @roleOperations.
  ///
  /// In es, this message translates to:
  /// **'Operación de país'**
  String get roleOperations;

  /// No description provided for @roleMedical.
  ///
  /// In es, this message translates to:
  /// **'Dirección médica'**
  String get roleMedical;

  /// No description provided for @roleFinance.
  ///
  /// In es, this message translates to:
  /// **'Finanzas de país'**
  String get roleFinance;

  /// No description provided for @roleDoctor.
  ///
  /// In es, this message translates to:
  /// **'Médico'**
  String get roleDoctor;

  /// No description provided for @menuDashboard.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get menuDashboard;

  /// No description provided for @menuDoctors.
  ///
  /// In es, this message translates to:
  /// **'Médicos y verificación'**
  String get menuDoctors;

  /// No description provided for @menuClinicalReview.
  ///
  /// In es, this message translates to:
  /// **'Revisión clínica'**
  String get menuClinicalReview;

  /// No description provided for @menuAssignments.
  ///
  /// In es, this message translates to:
  /// **'Asignaciones'**
  String get menuAssignments;

  /// No description provided for @menuMyCases.
  ///
  /// In es, this message translates to:
  /// **'Mis casos'**
  String get menuMyCases;

  /// No description provided for @menuAgenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get menuAgenda;

  /// No description provided for @menuReports.
  ///
  /// In es, this message translates to:
  /// **'Informes'**
  String get menuReports;

  /// No description provided for @menuPrescriptions.
  ///
  /// In es, this message translates to:
  /// **'Recetas'**
  String get menuPrescriptions;

  /// No description provided for @menuPayments.
  ///
  /// In es, this message translates to:
  /// **'Cobros y devoluciones'**
  String get menuPayments;

  /// No description provided for @menuPayouts.
  ///
  /// In es, this message translates to:
  /// **'Honorarios y liquidaciones'**
  String get menuPayouts;

  /// No description provided for @menuReconciliation.
  ///
  /// In es, this message translates to:
  /// **'Conciliación'**
  String get menuReconciliation;

  /// No description provided for @menuPricing.
  ///
  /// In es, this message translates to:
  /// **'Catálogo y precios'**
  String get menuPricing;

  /// No description provided for @menuUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get menuUsers;

  /// No description provided for @menuCountries.
  ///
  /// In es, this message translates to:
  /// **'Países y configuración'**
  String get menuCountries;

  /// No description provided for @menuGateways.
  ///
  /// In es, this message translates to:
  /// **'Pasarelas de pago'**
  String get menuGateways;

  /// No description provided for @menuAudit.
  ///
  /// In es, this message translates to:
  /// **'Auditoría'**
  String get menuAudit;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso al panel'**
  String get loginTitle;

  /// No description provided for @internalAccounts.
  ///
  /// In es, this message translates to:
  /// **'Acceso solo para el equipo autorizado. Las cuentas se crean desde el panel, no hay registro público.'**
  String get internalAccounts;

  /// No description provided for @loginUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con el servicio de acceso. Revisa tu conexión e inténtalo nuevamente.'**
  String get loginUnavailable;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signIn;

  /// No description provided for @accessDenied.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene acceso a este panel o a esta sección.'**
  String get accessDenied;

  /// No description provided for @accessDeniedHint.
  ///
  /// In es, this message translates to:
  /// **'Esta sección no está disponible para el rol y país seleccionados. Utiliza el menú para continuar.'**
  String get accessDeniedHint;

  /// No description provided for @modulePending.
  ///
  /// In es, this message translates to:
  /// **'Sección prevista para una próxima entrega. No realiza operaciones ni muestra datos reales.'**
  String get modulePending;

  /// No description provided for @dashboardHint.
  ///
  /// In es, this message translates to:
  /// **'El menú muestra las opciones de tu rol y país. Los módulos operativos se habilitarán en próximas entregas.'**
  String get dashboardHint;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @invalidLogin.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido y una contraseña (máximo 128 caracteres).'**
  String get invalidLogin;

  /// No description provided for @argentina.
  ///
  /// In es, this message translates to:
  /// **'Argentina'**
  String get argentina;

  /// No description provided for @invalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'No pudimos iniciar sesión con esas credenciales.'**
  String get invalidCredentials;

  /// No description provided for @emailNotVerified.
  ///
  /// In es, this message translates to:
  /// **'Debes verificar tu correo antes de entrar al panel.'**
  String get emailNotVerified;

  /// No description provided for @tooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos minutos antes de volver a intentar.'**
  String get tooManyRequests;

  /// No description provided for @signOutFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el cierre de sesión. Reintenta antes de dejar este equipo.'**
  String get signOutFailed;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'Olvidé mi contraseña'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In es, this message translates to:
  /// **'Si el correo corresponde a una cuenta, recibirás instrucciones para recuperar el acceso.'**
  String get resetSent;

  /// No description provided for @developmentNotice.
  ///
  /// In es, this message translates to:
  /// **'DESARROLLO · Módulos clínicos y financieros todavía no habilitados.'**
  String get developmentNotice;

  /// No description provided for @staffCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get staffCreate;

  /// No description provided for @staffEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar usuario'**
  String get staffEdit;

  /// No description provided for @staffName.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get staffName;

  /// No description provided for @staffSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get staffSave;

  /// No description provided for @staffCreateSend.
  ///
  /// In es, this message translates to:
  /// **'Crear y enviar acceso'**
  String get staffCreateSend;

  /// No description provided for @staffIntro.
  ///
  /// In es, this message translates to:
  /// **'Administra el equipo autorizado de este país. Las cuentas se crean por invitación, sin registro público.'**
  String get staffIntro;

  /// No description provided for @staffInviteHint.
  ///
  /// In es, this message translates to:
  /// **'Se enviará un correo para que la persona defina su contraseña. Asigna únicamente los roles que necesita. No se pueden convertir cuentas existentes de pacientes desde aquí.'**
  String get staffInviteHint;

  /// No description provided for @staffEditHint.
  ///
  /// In es, this message translates to:
  /// **'El correo no se cambia desde aquí. Modificar permisos cierra las sesiones de esta cuenta, incluso si también utiliza la app de pacientes.'**
  String get staffEditHint;

  /// No description provided for @staffSelectRole.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un rol para cada país habilitado.'**
  String get staffSelectRole;

  /// No description provided for @staffDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos vigentes para administrar estos usuarios. Vuelve a iniciar sesión.'**
  String get staffDenied;

  /// No description provided for @staffInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa nombre, correo, países y roles.'**
  String get staffInvalid;

  /// No description provided for @staffDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya pertenece a una cuenta. No se modificó ni se otorgaron permisos a la cuenta existente.'**
  String get staffDuplicate;

  /// No description provided for @staffConflict.
  ///
  /// In es, this message translates to:
  /// **'La información cambió o hay otra operación en curso. Actualiza el listado antes de continuar.'**
  String get staffConflict;

  /// No description provided for @staffProtected.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta está protegida o requiere revisión administrativa.'**
  String get staffProtected;

  /// No description provided for @staffLimit.
  ///
  /// In es, this message translates to:
  /// **'Se alcanzó un límite de seguridad. Espera para reenviar un correo; el máximo de operaciones de desarrollo es 100 al día.'**
  String get staffLimit;

  /// No description provided for @staffUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El servicio de usuarios no está disponible o la operación quedó incompleta. Actualiza el listado: si aparece pendiente, usa Retomar operación. No crees otra cuenta para reemplazarla.'**
  String get staffUnavailable;

  /// No description provided for @staffActive.
  ///
  /// In es, this message translates to:
  /// **'Acceso activo'**
  String get staffActive;

  /// No description provided for @staffInactive.
  ///
  /// In es, this message translates to:
  /// **'Acceso desactivado'**
  String get staffInactive;

  /// No description provided for @staffVerified.
  ///
  /// In es, this message translates to:
  /// **'Correo verificado'**
  String get staffVerified;

  /// No description provided for @staffUnverified.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de verificar correo'**
  String get staffUnverified;

  /// No description provided for @staffPending.
  ///
  /// In es, this message translates to:
  /// **'Operación pendiente'**
  String get staffPending;

  /// No description provided for @staffInviteNotSent.
  ///
  /// In es, this message translates to:
  /// **'Envío de acceso pendiente'**
  String get staffInviteNotSent;

  /// No description provided for @staffReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura: cuenta propia, protegida o con alcance fuera de tus permisos.'**
  String get staffReadOnly;

  /// No description provided for @staffResume.
  ///
  /// In es, this message translates to:
  /// **'Retomar operación'**
  String get staffResume;

  /// No description provided for @staffDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar acceso'**
  String get staffDeactivate;

  /// No description provided for @staffReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar acceso'**
  String get staffReactivate;

  /// No description provided for @staffResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar acceso'**
  String get staffResend;

  /// No description provided for @staffResendConfirm.
  ///
  /// In es, this message translates to:
  /// **'Se enviará otro correo de recuperación a esta persona. No verás su contraseña. Espera al menos un minuto entre envíos.'**
  String get staffResendConfirm;

  /// No description provided for @staffChangeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Se actualizará el acceso al panel y se cerrarán las sesiones de esta cuenta, incluso en pacientes. No se borra la cuenta ni su historial.'**
  String get staffChangeConfirm;

  /// No description provided for @staffMailFailed.
  ///
  /// In es, this message translates to:
  /// **'Cuenta guardada, pero no se pudo confirmar el correo. Puedes reenviar el acceso desde el listado.'**
  String get staffMailFailed;

  /// No description provided for @staffMailSent.
  ///
  /// In es, this message translates to:
  /// **'Cuenta guardada y correo de acceso solicitado.'**
  String get staffMailSent;

  /// No description provided for @staffSaved.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get staffSaved;

  /// No description provided for @staffEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay usuarios en este país.'**
  String get staffEmpty;

  /// No description provided for @staffMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más usuarios'**
  String get staffMore;
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
