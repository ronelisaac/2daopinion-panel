# 2daOpinion · Panel

Base Flutter web para administración y portal médico. Login Firebase conectado; módulos clínicos y financieros aún no operativos.

## Adjuntos vinculados · E2-11

La recepción local incluye cantidad de documentos y presencia de video; no expone títulos, ubicaciones ni contenido clínico a operaciones. El envío vincula el lote privado de reservas y bloquea nuevas cargas/borrados desde clientes. **Conteos no certificados; solo emuladores, sin despliegue remoto.** [Entrega, límites y reproducción](docs/E2-11-ADJUNTOS-EN-RECEPCION.md). Sustituye la restricción de texto sin adjuntos de E2-10.

## Recepción local · E2-10

Envío paciente→panel implementado y probado con Firebase emulado. Bandeja Firestore por país, búsqueda exacta, paginación acotada y detalle administrativo sin datos clínicos; solo operations activo del país. Copia/aceptación privada del paciente y comprobante idempotente. **Adaptadores, reglas e índices nuevos no activados remotamente**; una recepción por cuenta, solo texto, integración documental pendiente. [Alcance, pruebas y activación](docs/E2-10-RECEPCION-DE-SOLICITUDES.md).

## Estado vigente · E1-PANEL-03

CRUD real implementado con una función Firebase y pruebas completas en emuladores: altas por correo, roles por país, edición, baja reversible y reenvío. **Función desplegada en desarrollo tras autorización IAM específica; sin simulador.** Mínimo cero/máximo una instancia y limpieza de imágenes de compilación a un día; USD 10 sigue siendo una alerta, no un corte. [Entrega, seguridad y verificación](docs/E1-PANEL-03-USUARIOS.md).

## Login · E1-PANEL-02

Login Firebase con email/contraseña, recuperación, restauración/cierre de sesión y menú según roles por país. Sin registro público ni selector de rol simulado. El primer superadmin CL fue provisionado con autorización expresa de Ronel; debe definir personalmente su contraseña mediante el correo solicitado. Usuarios y los demás módulos siguen pendientes de conexión operativa. [Entrega, pruebas y límites](docs/E1-PANEL-02-LOGIN.md). Este estado prevalece sobre el historial siguiente.

## Base · E1-PANEL-01

Bandeja con búsqueda por código, filtros, paginación y detalle de metadatos. Tabla en escritorio y tarjetas en móvil, con el mismo logo, tema y tipografía de pacientes. No conecta a Firebase ni concede acceso administrativo. [Entrega, pruebas y pendientes](docs/E1-PANEL-01-BANDEJA.md). Este estado prevalece sobre las referencias históricas siguientes.

```sh
flutter pub get
flutter analyze
flutter test
flutter build web
```

Después de agregar plugins, ejecutar flutter pub get. Si persiste un registro de plugins antiguo, ejecutar flutter clean y flutter build web: una compilación incremental puede finalizar correctamente sin incluir el plugin nuevo. Para desplegar únicamente la función y preparar su parámetro público, ver la entrega E1-PANEL-03.

Requiere Flutter 3.41.7 / Dart 3.11.5 compatibles con la app de pacientes. `flutter run -d chrome` inicia la vista previa. Para evitar telemetría en este equipo: `FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true`. Las pruebas de reglas siguen separadas con `npm run test:rules`; los candidatos locales y su historial se describen en [firebase/README.md](firebase/README.md), sin autorizar su despliegue.

## Historial previo a la base Flutter

08/09/2026 · E1-04/E2-03: reglas de borradores ampliadas con contexto clínico versionado y compatibilidad de registros anteriores. Mantienen acceso exclusivo del propietario verificado, aceptación y revisión. El formulario público usa solo memoria de Flutter, no permisos anónimos. 61 pruebas de reglas aprobadas y publicadas en dev, únicamente Firestore Rules. Google permanece desactivado. Detalle en [la entrega de pacientes](../2daopinion-app/docs/E1-04-ACCESO-Y-FORMULARIO.md).

Diseño confirmado: el mismo sistema visual de la app de pacientes (logo, colores, tipografía, botones e inputs), con widgets reutilizables y distribución responsiva adaptada al trabajo administrativo. Referencia central: `/Users/ronel/Documents/2daOpinion/docs/arquitectura/ADR-003-DISENO-COMPARTIDO.md`. El mecanismo de distribución del código visual compartido está pendiente.

La app web «2daOpinion Panel Web» está registrada en el proyecto Firebase `segundaopinion-ea0c8`, con App ID `1:638989286509:web:057061662b7467cdec5364`.

- Configuración pública: `config/firebase.web.json`.
- Selector de proyecto: `.firebaserc`.
- Firestore de desarrollo creado en Santiago (southamerica-west1), edición Standard/Native; permisos privados para perfil básico propio y aceptación de condiciones de desarrollo. Las colecciones clínicas/financieras siguen denegadas a clientes.
- Configuración compartida versionada en firebase.json y firebase/. Aún no hay Flutter del panel ni permisos funcionales por rol/caso.
- Blaze activo con presupuesto de alertas USD 10/mes, sin corte automático. No hay API propia, Hosting público ni usuarios administrativos provisionados.

Convención obligatoria: vistas/widgets separados, controllers, contratos en dominio e implementaciones de repositorios. Firebase no entra en dominio ni se invoca desde vistas.

Documentación central: `/Users/ronel/Documents/2daOpinion/docs`. No duplicar el plan maestro dentro de este repositorio.

## Pruebas de permisos

E2-01 agrega borradores privados: propietario con correo verificado/perfil, uno por cuenta, revisión incremental, aceptación de almacenamiento de desarrollo independiente e inmutable y creación atómica. Solo estado `draft`, país CL y campos de hasta 4.000 caracteres. Sin envío clínico ni permisos médicos. Suite actual: 50 pruebas (21 perfiles + 29 borradores), ejecutadas en serie porque comparten el emulador. `consultationDrafts` no es una colección de casos clínicos operativos.

Requisitos: Node, Java 21+ y Firebase CLI. `npm ci` y `npm run test:rules` ejecutan 21 pruebas en Firestore emulado con `demo-2daopinion`, sin datos remotos. La suite comprueba aislamiento entre pacientes, anonimato, creación atómica de perfil/aceptación y prohibición de modificar campos sensibles o consentimientos.

Para probar la app completa: `firebase emulators:start --only auth,firestore --project demo-2daopinion` aquí; iniciar pacientes en debug con `--web-hostname localhost --dart-define=USE_FIREBASE_EMULATORS=true`. Puertos locales 9099/8080. No exportar identidades de prueba ni usar datos clínicos. El SDK Auth web requiere debug/localhost para restaurar el emulador antes de recuperar sesión.

Las reglas solo admiten CL/es y la versión de desarrollo `dev-access-2026-09-08`. Países, nuevas versiones y roles requieren una entrega explícita con pruebas. El perfil usa un ID de dominio independiente del UID de Authentication. Un usuario no verificado puede completar su propio perfil, pero no tiene acceso clínico. Este repositorio aún no implementa la app administrativa.
