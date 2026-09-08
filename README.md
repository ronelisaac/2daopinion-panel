# 2daOpinion · Panel

Repositorio reservado para administración y portal médico, según el plan maestro.

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

Requisitos: Node, Java 21+ y Firebase CLI. `npm ci` y `npm run test:rules` ejecutan 21 pruebas en Firestore emulado con `demo-2daopinion`, sin datos remotos. La suite comprueba aislamiento entre pacientes, anonimato, creación atómica de perfil/aceptación y prohibición de modificar campos sensibles o consentimientos.

Para probar la app completa: `firebase emulators:start --only auth,firestore --project demo-2daopinion` aquí; iniciar pacientes en debug con `--web-hostname localhost --dart-define=USE_FIREBASE_EMULATORS=true`. Puertos locales 9099/8080. No exportar identidades de prueba ni usar datos clínicos. El SDK Auth web requiere debug/localhost para restaurar el emulador antes de recuperar sesión.

Las reglas solo admiten CL/es y la versión de desarrollo `dev-access-2026-09-08`. Países, nuevas versiones y roles requieren una entrega explícita con pruebas. El perfil usa un ID de dominio independiente del UID de Authentication. Un usuario no verificado puede completar su propio perfil, pero no tiene acceso clínico. Este repositorio aún no implementa la app administrativa.
