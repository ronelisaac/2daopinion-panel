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
  /// **'Recepción de solicitudes de desarrollo: código, país, modalidad, fecha y cantidad de adjuntos vinculados. Sin acceso al contenido clínico, nombres de archivos ni pagos.'**
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
  /// **'{count, plural, =1{1 documento vinculado} other{{count} documentos vinculados}}'**
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
  /// **'Los adjuntos vinculados permanecen privados. Las cantidades describen registros aportados, no archivos validados. El contenido clínico no es accesible desde esta bandeja; no hay descarga, revisión clínica ni asignación médica habilitada.'**
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

  /// No description provided for @doctorsIntro.
  ///
  /// In es, this message translates to:
  /// **'Gestiona médicos independientes por país. No se exige una clínica. El registro no otorga acceso clínico ni acredita al profesional.'**
  String get doctorsIntro;

  /// No description provided for @doctorCreate.
  ///
  /// In es, this message translates to:
  /// **'Registrar médico'**
  String get doctorCreate;

  /// No description provided for @doctorEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar antecedentes'**
  String get doctorEdit;

  /// No description provided for @doctorReview.
  ///
  /// In es, this message translates to:
  /// **'Registrar revisión'**
  String get doctorReview;

  /// No description provided for @doctorEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay médicos registrados para este país.'**
  String get doctorEmpty;

  /// No description provided for @doctorRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar médicos'**
  String get doctorRefresh;

  /// No description provided for @doctorMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más médicos'**
  String get doctorMore;

  /// No description provided for @doctorName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo *'**
  String get doctorName;

  /// No description provided for @doctorRegistry.
  ///
  /// In es, this message translates to:
  /// **'Inscripción RNPI *'**
  String get doctorRegistry;

  /// No description provided for @doctorRegistryHelp.
  ///
  /// In es, this message translates to:
  /// **'Entre 1 y 10 dígitos, sin puntos ni ceros iniciales. No es el RUT. No se modifica después de registrar.'**
  String get doctorRegistryHelp;

  /// No description provided for @doctorSpecialty.
  ///
  /// In es, this message translates to:
  /// **'Especialidad principal *'**
  String get doctorSpecialty;

  /// No description provided for @doctorRequiredHint.
  ///
  /// In es, this message translates to:
  /// **'Los campos con * son obligatorios. La especialidad se registra como declarada, pendiente de revisión.'**
  String get doctorRequiredHint;

  /// No description provided for @doctorNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe entre 3 y 120 caracteres, sin dejar el nombre vacío.'**
  String get doctorNameInvalid;

  /// No description provided for @doctorRegistryInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce de 1 a 10 dígitos, sin ceros iniciales.'**
  String get doctorRegistryInvalid;

  /// No description provided for @doctorSpecialtyInvalid.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una especialidad activa del catálogo.'**
  String get doctorSpecialtyInvalid;

  /// No description provided for @doctorSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro y evento de auditoría guardados en Firebase de desarrollo.'**
  String get doctorSaved;

  /// No description provided for @doctorPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de revisión'**
  String get doctorPending;

  /// No description provided for @doctorVerified.
  ///
  /// In es, this message translates to:
  /// **'Revisión aprobada · Desarrollo'**
  String get doctorVerified;

  /// No description provided for @doctorRejected.
  ///
  /// In es, this message translates to:
  /// **'Requiere corrección'**
  String get doctorRejected;

  /// No description provided for @doctorSuspended.
  ///
  /// In es, this message translates to:
  /// **'Revisión suspendida'**
  String get doctorSuspended;

  /// No description provided for @doctorReviewIntro.
  ///
  /// In es, this message translates to:
  /// **'Consulta la fuente oficial y contrasta identidad, título y especialidad. Guarda la referencia consultada y el resultado. Esta revisión de desarrollo no habilita atención ni publica un perfil verificado al paciente.'**
  String get doctorReviewIntro;

  /// No description provided for @doctorSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente Chile: RNPI · Superintendencia de Salud'**
  String get doctorSource;

  /// No description provided for @doctorSourceUrl.
  ///
  /// In es, this message translates to:
  /// **'https://rnpi.superdesalud.gob.cl/'**
  String get doctorSourceUrl;

  /// No description provided for @doctorEvidence.
  ///
  /// In es, this message translates to:
  /// **'Referencia de consulta *'**
  String get doctorEvidence;

  /// No description provided for @doctorEvidenceHelp.
  ///
  /// In es, this message translates to:
  /// **'Código de certificado o referencia de consulta. Solo evidencia ficticia en desarrollo; no contraseñas ni datos de pacientes.'**
  String get doctorEvidenceHelp;

  /// No description provided for @doctorEvidenceInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe entre 3 y 200 caracteres.'**
  String get doctorEvidenceInvalid;

  /// No description provided for @doctorReviewNote.
  ///
  /// In es, this message translates to:
  /// **'Resultado y fundamento *'**
  String get doctorReviewNote;

  /// No description provided for @doctorNoteInvalid.
  ///
  /// In es, this message translates to:
  /// **'Explica el resultado con entre 10 y 2.000 caracteres.'**
  String get doctorNoteInvalid;

  /// No description provided for @doctorIdentityCheck.
  ///
  /// In es, this message translates to:
  /// **'Identidad contrastada'**
  String get doctorIdentityCheck;

  /// No description provided for @doctorTitleCheck.
  ///
  /// In es, this message translates to:
  /// **'Título profesional contrastado'**
  String get doctorTitleCheck;

  /// No description provided for @doctorSpecialtyCheck.
  ///
  /// In es, this message translates to:
  /// **'Especialidad y su vigencia contrastadas'**
  String get doctorSpecialtyCheck;

  /// No description provided for @doctorChecksRequired.
  ///
  /// In es, this message translates to:
  /// **'Para aprobar, confirma las tres comprobaciones.'**
  String get doctorChecksRequired;

  /// No description provided for @doctorDecision.
  ///
  /// In es, this message translates to:
  /// **'Resultado de la revisión'**
  String get doctorDecision;

  /// No description provided for @doctorSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar registro'**
  String get doctorSave;

  /// No description provided for @doctorSaveReview.
  ///
  /// In es, this message translates to:
  /// **'Guardar revisión'**
  String get doctorSaveReview;

  /// No description provided for @doctorReviewTrace.
  ///
  /// In es, this message translates to:
  /// **'Última revisión: {date} · Revisor: {actor}'**
  String doctorReviewTrace(String date, String actor);

  /// No description provided for @doctorRevision.
  ///
  /// In es, this message translates to:
  /// **'Revisión {revision} · Actualizado {date}'**
  String doctorRevision(int revision, String date);

  /// No description provided for @doctorRegistrySummary.
  ///
  /// In es, this message translates to:
  /// **'{country} · RNPI {number}'**
  String doctorRegistrySummary(String country, String number);

  /// No description provided for @doctorNoSelfReview.
  ///
  /// In es, this message translates to:
  /// **'La revisión debe realizarla otra persona con rol de Dirección médica.'**
  String get doctorNoSelfReview;

  /// No description provided for @doctorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa los campos obligatorios y el estado del registro.'**
  String get doctorInvalid;

  /// No description provided for @doctorDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos vigentes para esta operación en el país seleccionado.'**
  String get doctorDenied;

  /// No description provided for @doctorDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ese número RNPI ya está registrado en Chile. Actualiza el listado antes de continuar.'**
  String get doctorDuplicate;

  /// No description provided for @doctorConflict.
  ///
  /// In es, this message translates to:
  /// **'El registro cambió desde que lo abriste. Cierra el formulario, actualiza y revisa los cambios.'**
  String get doctorConflict;

  /// No description provided for @doctorUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.'**
  String get doctorUnavailable;

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

  /// No description provided for @menuSpecialties.
  ///
  /// In es, this message translates to:
  /// **'Especialidades'**
  String get menuSpecialties;

  /// No description provided for @specialtiesIntro.
  ///
  /// In es, this message translates to:
  /// **'Catálogo administrativo por país. Usa solo datos ficticios en desarrollo. Activar una especialidad no verifica médicos ni publica servicios al paciente.'**
  String get specialtiesIntro;

  /// No description provided for @specialtyReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Tu rol puede consultar el catálogo. Solo superadmin administra las especialidades.'**
  String get specialtyReadOnly;

  /// No description provided for @specialtyCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear especialidad'**
  String get specialtyCreate;

  /// No description provided for @specialtyEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar especialidad'**
  String get specialtyEdit;

  /// No description provided for @specialtyRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar especialidades'**
  String get specialtyRefresh;

  /// No description provided for @specialtySave.
  ///
  /// In es, this message translates to:
  /// **'Guardar especialidad'**
  String get specialtySave;

  /// No description provided for @specialtySaved.
  ///
  /// In es, this message translates to:
  /// **'Especialidad e historial guardados en Firebase de desarrollo.'**
  String get specialtySaved;

  /// No description provided for @specialtyRequired.
  ///
  /// In es, this message translates to:
  /// **'Los campos con * son obligatorios. El código identifica la especialidad dentro del país y no podrá cambiarse.'**
  String get specialtyRequired;

  /// No description provided for @specialtyCode.
  ///
  /// In es, this message translates to:
  /// **'Código *'**
  String get specialtyCode;

  /// No description provided for @specialtyCodeHelp.
  ///
  /// In es, this message translates to:
  /// **'De 2 a 32 caracteres: letras sin tildes, números o guion bajo. Empieza con una letra. Se guarda en minúsculas.'**
  String get specialtyCodeHelp;

  /// No description provided for @specialtyCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Usa de 2 a 32 letras, números o guion bajo, empezando con una letra sin tilde.'**
  String get specialtyCodeInvalid;

  /// No description provided for @specialtyName.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get specialtyName;

  /// No description provided for @specialtyNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe entre 2 y 100 caracteres.'**
  String get specialtyNameInvalid;

  /// No description provided for @specialtyDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get specialtyDescription;

  /// No description provided for @specialtyDescriptionInvalid.
  ///
  /// In es, this message translates to:
  /// **'La descripción admite hasta 500 caracteres.'**
  String get specialtyDescriptionInvalid;

  /// No description provided for @specialtyActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get specialtyActive;

  /// No description provided for @specialtyInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get specialtyInactive;

  /// No description provided for @specialtyDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar especialidad'**
  String get specialtyDeactivate;

  /// No description provided for @specialtyReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar especialidad'**
  String get specialtyReactivate;

  /// No description provided for @specialtyToggleConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cambiar el estado de «{name}»? Se conserva su código e historial. No modifica casos ni verificaciones existentes.'**
  String specialtyToggleConfirm(String name);

  /// No description provided for @specialtyConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambio'**
  String get specialtyConfirm;

  /// No description provided for @specialtyRevision.
  ///
  /// In es, this message translates to:
  /// **'Revisión {revision} · Actualizada {date}'**
  String specialtyRevision(int revision, String date);

  /// No description provided for @specialtyLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando especialidades'**
  String get specialtyLoading;

  /// No description provided for @specialtySaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando especialidad'**
  String get specialtySaving;

  /// No description provided for @specialtyEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay especialidades registradas para este país.'**
  String get specialtyEmpty;

  /// No description provided for @specialtyMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más especialidades'**
  String get specialtyMore;

  /// No description provided for @specialtyInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos y el estado de la especialidad.'**
  String get specialtyInvalid;

  /// No description provided for @specialtyDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos vigentes para esta operación en el país seleccionado.'**
  String get specialtyDenied;

  /// No description provided for @specialtyDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya existe ese código en el país, incluso si está inactivo. Consulta el registro existente.'**
  String get specialtyDuplicate;

  /// No description provided for @specialtyConflict.
  ///
  /// In es, this message translates to:
  /// **'La especialidad cambió en otra sesión. Actualiza el listado antes de reintentar.'**
  String get specialtyConflict;

  /// No description provided for @specialtyUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.'**
  String get specialtyUnavailable;

  /// No description provided for @menuClinics.
  ///
  /// In es, this message translates to:
  /// **'Clínicas'**
  String get menuClinics;

  /// No description provided for @clinicsIntro.
  ///
  /// In es, this message translates to:
  /// **'Registro administrativo de clínicas por país. Usa solo datos ficticios en desarrollo. Registrar o activar una clínica no acredita habilitación sanitaria ni crea convenios o acceso a pacientes.'**
  String get clinicsIntro;

  /// No description provided for @clinicReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Tu rol puede consultar el catálogo. Solo superadmin administra las clínicas.'**
  String get clinicReadOnly;

  /// No description provided for @clinicCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear clínica'**
  String get clinicCreate;

  /// No description provided for @clinicEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar clínica'**
  String get clinicEdit;

  /// No description provided for @clinicRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar clínicas'**
  String get clinicRefresh;

  /// No description provided for @clinicSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar clínica'**
  String get clinicSave;

  /// No description provided for @clinicSaved.
  ///
  /// In es, this message translates to:
  /// **'Clínica e historial guardados en Firebase de desarrollo.'**
  String get clinicSaved;

  /// No description provided for @clinicRequired.
  ///
  /// In es, this message translates to:
  /// **'Los campos con * son obligatorios. El código identifica la clínica dentro del país y no podrá cambiarse.'**
  String get clinicRequired;

  /// No description provided for @clinicCode.
  ///
  /// In es, this message translates to:
  /// **'Código *'**
  String get clinicCode;

  /// No description provided for @clinicCodeHelp.
  ///
  /// In es, this message translates to:
  /// **'De 2 a 32 caracteres: letras sin tildes, números o guion bajo. Empieza con una letra. Se guarda en minúsculas.'**
  String get clinicCodeHelp;

  /// No description provided for @clinicCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Usa de 2 a 32 letras, números o guion bajo, empezando con una letra sin tilde.'**
  String get clinicCodeInvalid;

  /// No description provided for @clinicName.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get clinicName;

  /// No description provided for @clinicNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe entre 2 y 100 caracteres.'**
  String get clinicNameInvalid;

  /// No description provided for @clinicDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get clinicDescription;

  /// No description provided for @clinicDescriptionInvalid.
  ///
  /// In es, this message translates to:
  /// **'La descripción admite hasta 500 caracteres.'**
  String get clinicDescriptionInvalid;

  /// No description provided for @clinicActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get clinicActive;

  /// No description provided for @clinicInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get clinicInactive;

  /// No description provided for @clinicDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar clínica'**
  String get clinicDeactivate;

  /// No description provided for @clinicReactivate.
  ///
  /// In es, this message translates to:
  /// **'Reactivar clínica'**
  String get clinicReactivate;

  /// No description provided for @clinicToggleConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cambiar el estado de «{name}»? Se conserva su código e historial. No modifica casos ni verificaciones existentes.'**
  String clinicToggleConfirm(String name);

  /// No description provided for @clinicConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambio'**
  String get clinicConfirm;

  /// No description provided for @clinicRevision.
  ///
  /// In es, this message translates to:
  /// **'Revisión {revision} · Actualizada {date}'**
  String clinicRevision(int revision, String date);

  /// No description provided for @clinicLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando clínicas'**
  String get clinicLoading;

  /// No description provided for @clinicSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando clínica'**
  String get clinicSaving;

  /// No description provided for @clinicEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay clínicas registradas para este país.'**
  String get clinicEmpty;

  /// No description provided for @clinicMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más clínicas'**
  String get clinicMore;

  /// No description provided for @clinicInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos y el estado de la clínica.'**
  String get clinicInvalid;

  /// No description provided for @clinicDenied.
  ///
  /// In es, this message translates to:
  /// **'No tienes permisos vigentes para esta operación en el país seleccionado.'**
  String get clinicDenied;

  /// No description provided for @clinicDuplicate.
  ///
  /// In es, this message translates to:
  /// **'Ya existe ese código en el país, incluso si está inactivo. Consulta el registro existente.'**
  String get clinicDuplicate;

  /// No description provided for @clinicConflict.
  ///
  /// In es, this message translates to:
  /// **'La clínica cambió en otra sesión. Actualiza el listado antes de reintentar.'**
  String get clinicConflict;

  /// No description provided for @clinicUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.'**
  String get clinicUnavailable;

  /// No description provided for @clinicCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad *'**
  String get clinicCity;

  /// No description provided for @clinicCityInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe una ciudad de entre 2 y 100 caracteres.'**
  String get clinicCityInvalid;

  /// No description provided for @clinicAddress.
  ///
  /// In es, this message translates to:
  /// **'Dirección *'**
  String get clinicAddress;

  /// No description provided for @clinicAddressInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe una dirección de entre 5 y 200 caracteres.'**
  String get clinicAddressInvalid;

  /// No description provided for @clinicEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo de contacto (opcional)'**
  String get clinicEmail;

  /// No description provided for @clinicEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido, de hasta 254 caracteres.'**
  String get clinicEmailInvalid;

  /// No description provided for @clinicPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de contacto (opcional)'**
  String get clinicPhone;

  /// No description provided for @clinicPhoneHelp.
  ///
  /// In es, this message translates to:
  /// **'Usa + y el código de país, sin espacios ni guiones. Entre 8 y 15 dígitos.'**
  String get clinicPhoneHelp;

  /// No description provided for @clinicPhoneInvalid.
  ///
  /// In es, this message translates to:
  /// **'Usa + seguido de 8 a 15 dígitos; el primero no puede ser cero.'**
  String get clinicPhoneInvalid;

  /// No description provided for @clinicLocation.
  ///
  /// In es, this message translates to:
  /// **'{city} · {address}'**
  String clinicLocation(String city, String address);

  /// No description provided for @clinicEmailValue.
  ///
  /// In es, this message translates to:
  /// **'Correo: {email}'**
  String clinicEmailValue(String email);

  /// No description provided for @clinicPhoneValue.
  ///
  /// In es, this message translates to:
  /// **'Teléfono: {phone}'**
  String clinicPhoneValue(String phone);

  /// No description provided for @doctorCatalogHelp.
  ///
  /// In es, this message translates to:
  /// **'Elige una especialidad del país. Su selección no reemplaza la verificación profesional.'**
  String get doctorCatalogHelp;

  /// No description provided for @doctorCatalogEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay especialidades activas en esta página. Carga más o solicita al administrador que registre una.'**
  String get doctorCatalogEmpty;

  /// No description provided for @doctorCatalogLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando especialidades…'**
  String get doctorCatalogLoading;

  /// No description provided for @doctorCatalogError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las especialidades. Vuelve a intentarlo.'**
  String get doctorCatalogError;

  /// No description provided for @doctorCatalogRetry.
  ///
  /// In es, this message translates to:
  /// **'Actualizar especialidades'**
  String get doctorCatalogRetry;

  /// No description provided for @doctorCatalogMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más especialidades'**
  String get doctorCatalogMore;

  /// No description provided for @doctorCatalogInvalid.
  ///
  /// In es, this message translates to:
  /// **'La especialidad ya no está disponible. Actualiza el catálogo y selecciona una especialidad activa.'**
  String get doctorCatalogInvalid;

  /// No description provided for @doctorLegacySpecialty.
  ///
  /// In es, this message translates to:
  /// **'Ficha histórica: Operaciones debe vincular explícitamente una especialidad del catálogo antes de aprobar. No se asignará por coincidencia de nombre.'**
  String get doctorLegacySpecialty;
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
