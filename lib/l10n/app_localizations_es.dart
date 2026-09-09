// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String pageWithoutTotal(int page) {
    return 'Página $page';
  }

  @override
  String get appTitle => '2daOpinion · Panel';

  @override
  String get workspace => 'Panel administrativo';

  @override
  String get inbox => 'Solicitudes';

  @override
  String get inboxSubtitle =>
      'Recepción de solicitudes de desarrollo: código, país, modalidad, fecha y cantidad de adjuntos vinculados. Sin acceso al contenido clínico, nombres de archivos ni pagos.';

  @override
  String get previewNotice =>
      'EJEMPLO · Solo datos ficticios. No hay acceso a pacientes ni operaciones reales.';

  @override
  String get scope => 'Alcance de esta vista previa';

  @override
  String get scopeBody =>
      'El acceso usa Firebase Authentication y requiere permisos administrativos asignados desde un entorno confiable. No hay registro público ni creación automática de roles. Los módulos operativos y las altas internas están pendientes; no se accede a datos clínicos.';

  @override
  String get close => 'Entendido';

  @override
  String get search => 'Buscar por código';

  @override
  String get reference => 'Código';

  @override
  String get searchHint => 'Pega el código completo SO-…';

  @override
  String get searchAction => 'Buscar';

  @override
  String get all => 'Todas';

  @override
  String get received => 'Recibida';

  @override
  String get reviewing => 'En revisión documental';

  @override
  String get needsDocuments => 'Falta documentación';

  @override
  String get documentary => 'Revisión documental';

  @override
  String get consultation => 'Revisión + consulta';

  @override
  String get country => 'País';

  @override
  String get chile => 'Chile';

  @override
  String get date => 'Fecha de recepción';

  @override
  String get modality => 'Modalidad';

  @override
  String get status => 'Estado';

  @override
  String get documents => 'Documentación disponible';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos vinculados',
      one: '1 documento vinculado',
    );
    return '$_temp0';
  }

  @override
  String get video => 'Video explicativo opcional';

  @override
  String get withVideo => 'Incluido';

  @override
  String get withoutVideo => 'No incluido · No es requisito';

  @override
  String get report => 'Informe médico';

  @override
  String get examination => 'Estudio o examen';

  @override
  String get prescription => 'Receta aportada por el paciente';

  @override
  String get metadataOnly =>
      'Los adjuntos vinculados permanecen privados. Las cantidades describen registros aportados, no archivos validados. El contenido clínico no es accesible desde esta bandeja; no hay descarga, revisión clínica ni asignación médica habilitada.';

  @override
  String get detail => 'Detalle de solicitud';

  @override
  String get view => 'Ver detalle';

  @override
  String get empty => 'No hay solicitudes que coincidan con los filtros.';

  @override
  String get failed =>
      'No pudimos cargar la información. Inténtalo nuevamente.';

  @override
  String get notFound => 'No se encontró esta solicitud.';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar solicitudes';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String pageSummary(int page, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total resultados',
      one: '1 resultado',
    );
    return 'Página $page · $_temp0';
  }

  @override
  String get footer => '2daOpinion · Desarrollo · Sin atención clínica';

  @override
  String get previewLabel => 'Vista previa';

  @override
  String get roleSuperadmin => 'Superadmin';

  @override
  String get roleOperations => 'Operación de país';

  @override
  String get roleMedical => 'Dirección médica';

  @override
  String get roleFinance => 'Finanzas de país';

  @override
  String get roleDoctor => 'Médico';

  @override
  String get menuDashboard => 'Resumen';

  @override
  String get menuDoctors => 'Médicos y verificación';

  @override
  String get menuClinicalReview => 'Revisión clínica';

  @override
  String get menuAssignments => 'Asignaciones';

  @override
  String get menuMyCases => 'Mis casos';

  @override
  String get menuAgenda => 'Agenda';

  @override
  String get menuReports => 'Informes';

  @override
  String get menuPrescriptions => 'Recetas';

  @override
  String get menuPayments => 'Cobros y devoluciones';

  @override
  String get menuPayouts => 'Honorarios y liquidaciones';

  @override
  String get menuReconciliation => 'Conciliación';

  @override
  String get menuPricing => 'Catálogo y precios';

  @override
  String get menuUsers => 'Usuarios';

  @override
  String get menuCountries => 'Países y configuración';

  @override
  String get menuGateways => 'Pasarelas de pago';

  @override
  String get menuAudit => 'Auditoría';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get loginTitle => 'Acceso al panel';

  @override
  String get internalAccounts =>
      'Acceso solo para el equipo autorizado. Las cuentas se crean desde el panel, no hay registro público.';

  @override
  String get loginUnavailable =>
      'No pudimos conectar con el servicio de acceso. Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Ingresar';

  @override
  String get accessDenied =>
      'Tu cuenta no tiene acceso a este panel o a esta sección.';

  @override
  String get accessDeniedHint =>
      'Esta sección no está disponible para el rol y país seleccionados. Utiliza el menú para continuar.';

  @override
  String get modulePending =>
      'Sección prevista para una próxima entrega. No realiza operaciones ni muestra datos reales.';

  @override
  String get dashboardHint =>
      'El menú muestra las opciones de tu rol y país. Los módulos operativos se habilitarán en próximas entregas.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get invalidLogin =>
      'Introduce un correo válido y una contraseña (máximo 128 caracteres).';

  @override
  String get argentina => 'Argentina';

  @override
  String get invalidCredentials =>
      'No pudimos iniciar sesión con esas credenciales.';

  @override
  String get emailNotVerified =>
      'Debes verificar tu correo antes de entrar al panel.';

  @override
  String get tooManyRequests =>
      'Demasiados intentos. Espera unos minutos antes de volver a intentar.';

  @override
  String get signOutFailed =>
      'No pudimos confirmar el cierre de sesión. Reintenta antes de dejar este equipo.';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get resetSent =>
      'Si el correo corresponde a una cuenta, recibirás instrucciones para recuperar el acceso.';

  @override
  String get developmentNotice =>
      'DESARROLLO · Módulos clínicos y financieros todavía no habilitados.';

  @override
  String get staffCreate => 'Crear usuario';

  @override
  String get staffEdit => 'Editar usuario';

  @override
  String get staffName => 'Nombre y apellido';

  @override
  String get staffSave => 'Guardar cambios';

  @override
  String get staffCreateSend => 'Crear y enviar acceso';

  @override
  String get staffIntro =>
      'Administra el equipo autorizado de este país. Las cuentas se crean por invitación, sin registro público.';

  @override
  String get staffInviteHint =>
      'Se enviará un correo para que la persona defina su contraseña. Asigna únicamente los roles que necesita. No se pueden convertir cuentas existentes de pacientes desde aquí.';

  @override
  String get staffEditHint =>
      'El correo no se cambia desde aquí. Modificar permisos cierra las sesiones de esta cuenta, incluso si también utiliza la app de pacientes.';

  @override
  String get staffSelectRole =>
      'Selecciona al menos un rol para cada país habilitado.';

  @override
  String get staffDenied =>
      'No tienes permisos vigentes para administrar estos usuarios. Vuelve a iniciar sesión.';

  @override
  String get staffInvalid => 'Revisa nombre, correo, países y roles.';

  @override
  String get staffDuplicate =>
      'Ese correo ya pertenece a una cuenta. No se modificó ni se otorgaron permisos a la cuenta existente.';

  @override
  String get staffConflict =>
      'La información cambió o hay otra operación en curso. Actualiza el listado antes de continuar.';

  @override
  String get staffProtected =>
      'Esta cuenta está protegida o requiere revisión administrativa.';

  @override
  String get staffLimit =>
      'Se alcanzó un límite de seguridad. Espera para reenviar un correo; el máximo de operaciones de desarrollo es 100 al día.';

  @override
  String get staffUnavailable =>
      'El servicio de usuarios no está disponible o la operación quedó incompleta. Actualiza el listado: si aparece pendiente, usa Retomar operación. No crees otra cuenta para reemplazarla.';

  @override
  String get staffActive => 'Acceso activo';

  @override
  String get staffInactive => 'Acceso desactivado';

  @override
  String get staffVerified => 'Correo verificado';

  @override
  String get staffUnverified => 'Pendiente de verificar correo';

  @override
  String get staffPending => 'Operación pendiente';

  @override
  String get staffInviteNotSent => 'Envío de acceso pendiente';

  @override
  String get staffReadOnly =>
      'Solo lectura: cuenta propia, protegida o con alcance fuera de tus permisos.';

  @override
  String get staffResume => 'Retomar operación';

  @override
  String get staffDeactivate => 'Desactivar acceso';

  @override
  String get staffReactivate => 'Reactivar acceso';

  @override
  String get staffResend => 'Reenviar acceso';

  @override
  String get staffResendConfirm =>
      'Se enviará otro correo de recuperación a esta persona. No verás su contraseña. Espera al menos un minuto entre envíos.';

  @override
  String get staffChangeConfirm =>
      'Se actualizará el acceso al panel y se cerrarán las sesiones de esta cuenta, incluso en pacientes. No se borra la cuenta ni su historial.';

  @override
  String get staffMailFailed =>
      'Cuenta guardada, pero no se pudo confirmar el correo. Puedes reenviar el acceso desde el listado.';

  @override
  String get staffMailSent => 'Cuenta guardada y correo de acceso solicitado.';

  @override
  String get staffSaved => 'Cambios guardados.';

  @override
  String get staffEmpty => 'Todavía no hay usuarios en este país.';

  @override
  String get staffMore => 'Cargar más usuarios';
}
