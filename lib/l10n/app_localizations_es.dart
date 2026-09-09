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
  String get doctorsIntro =>
      'Registro profesional privado de desarrollo. Usa solo datos ficticios. Registrar antecedentes no crea una cuenta ni habilita atención, recetas o acceso a pacientes. La revisión RNPI es manual; no existe conexión automática con el registro.';

  @override
  String get doctorCreate => 'Registrar médico';

  @override
  String get doctorEdit => 'Editar antecedentes';

  @override
  String get doctorReview => 'Registrar revisión';

  @override
  String get doctorEmpty =>
      'Todavía no hay médicos registrados para este país.';

  @override
  String get doctorRefresh => 'Actualizar médicos';

  @override
  String get doctorMore => 'Ver más médicos';

  @override
  String get doctorName => 'Nombre completo *';

  @override
  String get doctorRegistry => 'Inscripción RNPI *';

  @override
  String get doctorRegistryHelp =>
      'Entre 1 y 10 dígitos, sin puntos ni ceros iniciales. No es el RUT. No se modifica después de registrar.';

  @override
  String get doctorSpecialty => 'Especialidad principal *';

  @override
  String get doctorRequiredHint =>
      'Los campos con * son obligatorios. La especialidad se registra como declarada, pendiente de revisión.';

  @override
  String get doctorNameInvalid =>
      'Escribe entre 3 y 120 caracteres, sin dejar el nombre vacío.';

  @override
  String get doctorRegistryInvalid =>
      'Introduce de 1 a 10 dígitos, sin ceros iniciales.';

  @override
  String get doctorSpecialtyInvalid => 'Escribe entre 2 y 120 caracteres.';

  @override
  String get doctorSaved =>
      'Registro y evento de auditoría guardados en Firebase de desarrollo.';

  @override
  String get doctorPending => 'Pendiente de revisión';

  @override
  String get doctorVerified => 'Revisión aprobada · Desarrollo';

  @override
  String get doctorRejected => 'Requiere corrección';

  @override
  String get doctorSuspended => 'Revisión suspendida';

  @override
  String get doctorReviewIntro =>
      'Consulta la fuente oficial y contrasta identidad, título y especialidad. Guarda la referencia consultada y el resultado. Esta revisión de desarrollo no habilita atención ni publica un perfil verificado al paciente.';

  @override
  String get doctorSource => 'Fuente Chile: RNPI · Superintendencia de Salud';

  @override
  String get doctorSourceUrl => 'https://rnpi.superdesalud.gob.cl/';

  @override
  String get doctorEvidence => 'Referencia de consulta *';

  @override
  String get doctorEvidenceHelp =>
      'Código de certificado o referencia de consulta. Solo evidencia ficticia en desarrollo; no contraseñas ni datos de pacientes.';

  @override
  String get doctorEvidenceInvalid => 'Escribe entre 3 y 200 caracteres.';

  @override
  String get doctorReviewNote => 'Resultado y fundamento *';

  @override
  String get doctorNoteInvalid =>
      'Explica el resultado con entre 10 y 2.000 caracteres.';

  @override
  String get doctorIdentityCheck => 'Identidad contrastada';

  @override
  String get doctorTitleCheck => 'Título profesional contrastado';

  @override
  String get doctorSpecialtyCheck => 'Especialidad y su vigencia contrastadas';

  @override
  String get doctorChecksRequired =>
      'Para aprobar, confirma las tres comprobaciones.';

  @override
  String get doctorDecision => 'Resultado de la revisión';

  @override
  String get doctorSave => 'Guardar registro';

  @override
  String get doctorSaveReview => 'Guardar revisión';

  @override
  String doctorReviewTrace(String date, String actor) {
    return 'Última revisión: $date · Revisor: $actor';
  }

  @override
  String doctorRevision(int revision, String date) {
    return 'Revisión $revision · Actualizado $date';
  }

  @override
  String doctorRegistrySummary(String country, String number) {
    return '$country · RNPI $number';
  }

  @override
  String get doctorNoSelfReview =>
      'La revisión debe realizarla otra persona con rol de Dirección médica.';

  @override
  String get doctorInvalid =>
      'Revisa los campos obligatorios y el estado del registro.';

  @override
  String get doctorDenied =>
      'No tienes permisos vigentes para esta operación en el país seleccionado.';

  @override
  String get doctorDuplicate =>
      'Ese número RNPI ya está registrado en Chile. Actualiza el listado antes de continuar.';

  @override
  String get doctorConflict =>
      'El registro cambió desde que lo abriste. Cierra el formulario, actualiza y revisa los cambios.';

  @override
  String get doctorUnavailable =>
      'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.';

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

  @override
  String get menuSpecialties => 'Especialidades';

  @override
  String get specialtiesIntro =>
      'Catálogo administrativo por país. Usa solo datos ficticios en desarrollo. Activar una especialidad no verifica médicos ni publica servicios al paciente.';

  @override
  String get specialtyReadOnly =>
      'Tu rol puede consultar el catálogo. Solo superadmin administra las especialidades.';

  @override
  String get specialtyCreate => 'Crear especialidad';

  @override
  String get specialtyEdit => 'Editar especialidad';

  @override
  String get specialtyRefresh => 'Actualizar especialidades';

  @override
  String get specialtySave => 'Guardar especialidad';

  @override
  String get specialtySaved =>
      'Especialidad e historial guardados en Firebase de desarrollo.';

  @override
  String get specialtyRequired =>
      'Los campos con * son obligatorios. El código identifica la especialidad dentro del país y no podrá cambiarse.';

  @override
  String get specialtyCode => 'Código *';

  @override
  String get specialtyCodeHelp =>
      'De 2 a 32 caracteres: letras sin tildes, números o guion bajo. Empieza con una letra. Se guarda en minúsculas.';

  @override
  String get specialtyCodeInvalid =>
      'Usa de 2 a 32 letras, números o guion bajo, empezando con una letra sin tilde.';

  @override
  String get specialtyName => 'Nombre *';

  @override
  String get specialtyNameInvalid => 'Escribe entre 2 y 100 caracteres.';

  @override
  String get specialtyDescription => 'Descripción (opcional)';

  @override
  String get specialtyDescriptionInvalid =>
      'La descripción admite hasta 500 caracteres.';

  @override
  String get specialtyActive => 'Activa';

  @override
  String get specialtyInactive => 'Inactiva';

  @override
  String get specialtyDeactivate => 'Desactivar especialidad';

  @override
  String get specialtyReactivate => 'Reactivar especialidad';

  @override
  String specialtyToggleConfirm(String name) {
    return '¿Cambiar el estado de «$name»? Se conserva su código e historial. No modifica casos ni verificaciones existentes.';
  }

  @override
  String get specialtyConfirm => 'Confirmar cambio';

  @override
  String specialtyRevision(int revision, String date) {
    return 'Revisión $revision · Actualizada $date';
  }

  @override
  String get specialtyLoading => 'Cargando especialidades';

  @override
  String get specialtySaving => 'Guardando especialidad';

  @override
  String get specialtyEmpty =>
      'Todavía no hay especialidades registradas para este país.';

  @override
  String get specialtyMore => 'Cargar más especialidades';

  @override
  String get specialtyInvalid =>
      'Revisa los datos y el estado de la especialidad.';

  @override
  String get specialtyDenied =>
      'No tienes permisos vigentes para esta operación en el país seleccionado.';

  @override
  String get specialtyDuplicate =>
      'Ya existe ese código en el país, incluso si está inactivo. Consulta el registro existente.';

  @override
  String get specialtyConflict =>
      'La especialidad cambió en otra sesión. Actualiza el listado antes de reintentar.';

  @override
  String get specialtyUnavailable =>
      'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.';

  @override
  String get menuClinics => 'Clínicas';

  @override
  String get clinicsIntro =>
      'Registro administrativo de clínicas por país. Usa solo datos ficticios en desarrollo. Registrar o activar una clínica no acredita habilitación sanitaria ni crea convenios o acceso a pacientes.';

  @override
  String get clinicReadOnly =>
      'Tu rol puede consultar el catálogo. Solo superadmin administra las clínicas.';

  @override
  String get clinicCreate => 'Crear clínica';

  @override
  String get clinicEdit => 'Editar clínica';

  @override
  String get clinicRefresh => 'Actualizar clínicas';

  @override
  String get clinicSave => 'Guardar clínica';

  @override
  String get clinicSaved =>
      'Clínica e historial guardados en Firebase de desarrollo.';

  @override
  String get clinicRequired =>
      'Los campos con * son obligatorios. El código identifica la clínica dentro del país y no podrá cambiarse.';

  @override
  String get clinicCode => 'Código *';

  @override
  String get clinicCodeHelp =>
      'De 2 a 32 caracteres: letras sin tildes, números o guion bajo. Empieza con una letra. Se guarda en minúsculas.';

  @override
  String get clinicCodeInvalid =>
      'Usa de 2 a 32 letras, números o guion bajo, empezando con una letra sin tilde.';

  @override
  String get clinicName => 'Nombre *';

  @override
  String get clinicNameInvalid => 'Escribe entre 2 y 100 caracteres.';

  @override
  String get clinicDescription => 'Descripción (opcional)';

  @override
  String get clinicDescriptionInvalid =>
      'La descripción admite hasta 500 caracteres.';

  @override
  String get clinicActive => 'Activa';

  @override
  String get clinicInactive => 'Inactiva';

  @override
  String get clinicDeactivate => 'Desactivar clínica';

  @override
  String get clinicReactivate => 'Reactivar clínica';

  @override
  String clinicToggleConfirm(String name) {
    return '¿Cambiar el estado de «$name»? Se conserva su código e historial. No modifica casos ni verificaciones existentes.';
  }

  @override
  String get clinicConfirm => 'Confirmar cambio';

  @override
  String clinicRevision(int revision, String date) {
    return 'Revisión $revision · Actualizada $date';
  }

  @override
  String get clinicLoading => 'Cargando clínicas';

  @override
  String get clinicSaving => 'Guardando clínica';

  @override
  String get clinicEmpty =>
      'Todavía no hay clínicas registradas para este país.';

  @override
  String get clinicMore => 'Cargar más clínicas';

  @override
  String get clinicInvalid => 'Revisa los datos y el estado de la clínica.';

  @override
  String get clinicDenied =>
      'No tienes permisos vigentes para esta operación en el país seleccionado.';

  @override
  String get clinicDuplicate =>
      'Ya existe ese código en el país, incluso si está inactivo. Consulta el registro existente.';

  @override
  String get clinicConflict =>
      'La clínica cambió en otra sesión. Actualiza el listado antes de reintentar.';

  @override
  String get clinicUnavailable =>
      'No pudimos confirmar la operación. Actualiza el listado antes de reintentar.';

  @override
  String get clinicCity => 'Ciudad *';

  @override
  String get clinicCityInvalid =>
      'Escribe una ciudad de entre 2 y 100 caracteres.';

  @override
  String get clinicAddress => 'Dirección *';

  @override
  String get clinicAddressInvalid =>
      'Escribe una dirección de entre 5 y 200 caracteres.';

  @override
  String get clinicEmail => 'Correo de contacto (opcional)';

  @override
  String get clinicEmailInvalid =>
      'Introduce un correo válido, de hasta 254 caracteres.';

  @override
  String get clinicPhone => 'Teléfono de contacto (opcional)';

  @override
  String get clinicPhoneHelp =>
      'Usa + y el código de país, sin espacios ni guiones. Entre 8 y 15 dígitos.';

  @override
  String get clinicPhoneInvalid =>
      'Usa + seguido de 8 a 15 dígitos; el primero no puede ser cero.';

  @override
  String clinicLocation(String city, String address) {
    return '$city · $address';
  }

  @override
  String clinicEmailValue(String email) {
    return 'Correo: $email';
  }

  @override
  String clinicPhoneValue(String phone) {
    return 'Teléfono: $phone';
  }
}
