// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '2daOpinion · Panel';

  @override
  String get workspace => 'Panel administrativo';

  @override
  String get inbox => 'Solicitudes';

  @override
  String get inboxSubtitle =>
      'Organiza la recepción y revisa la documentación disponible.';

  @override
  String get previewNotice =>
      'EJEMPLO · Solo datos ficticios. No hay acceso a pacientes ni operaciones reales.';

  @override
  String get scope => 'Alcance de esta vista previa';

  @override
  String get scopeBody =>
      'Puedes explorar solicitudes de ejemplo, filtrar y revisar sus metadatos. No se conecta a Firebase, no valida documentos, no asigna médicos ni envía mensajes. El acceso administrativo real requiere autenticación y permisos por rol/caso, todavía pendientes.';

  @override
  String get close => 'Entendido';

  @override
  String get search => 'Buscar por código';

  @override
  String get reference => 'Código';

  @override
  String get searchHint => 'Ej. DEMO-0001';

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
  String get status => 'Estado de ejemplo';

  @override
  String get documents => 'Documentación disponible';

  @override
  String documentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos de ejemplo',
      one: '1 archivo de ejemplo',
    );
    return '$_temp0';
  }

  @override
  String get video => 'Video explicativo opcional';

  @override
  String get withVideo => 'Incluido en este ejemplo';

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
      'Solo metadatos ficticios: no hay archivos para abrir o descargar. Recibir documentación no significa validarla clínicamente.';

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
  String get notFound => 'No se encontró esta solicitud de ejemplo.';

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
}
