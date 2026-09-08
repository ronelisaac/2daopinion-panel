# E1-PANEL-03 · Usuarios reales

8 de septiembre de 2026 · Implementado y probado con Firebase emulado. Activación remota pendiente de autorización IAM específica.

## Alcance

- Usuarios del equipo: listado paginado de 20, alta por correo, nombre, roles por país, edición, desactivación/reactivación y reenvío de acceso.
- No hay usuarios simulados en el producto ni contraseñas visibles al administrador.
- Crear una cuenta envía una solicitud de recuperación de contraseña de Firebase para que el destinatario establezca su clave. “Enviado” significa solicitud aceptada por el proveedor, no recepción garantizada.
- El email es inmutable en este módulo. No se convierte una cuenta de paciente existente en personal: email ocupado se rechaza sin asignarle roles.
- El primer superadmin queda protegido y no puede modificarse desde este CRUD. Tampoco puede un operador cambiar su propia cuenta.
- Asignar rol Médico no equivale a verificar RNPI, habilitación profesional ni autorizar acceso a expedientes.

## Arquitectura

Widgets separados StaffEditor/StaffMemberCard, vista PanelStaffScreen, controller PanelStaffController, entidades/contrato Dart puros y FirebasePanelStaffRepository inyectado.

Una única callable managePanelUsers implementa list/create/update/setActive/invite/resume. No se construyó una API general ni se agregaron credenciales administrativas al cliente. La función verifica la identidad recibida por el protocolo callable, la cuenta actual de Authentication y la membresía vigente en Firestore; ocultar un menú no es autorización.

Datos nuevos, privados para clientes:

| Colección | Propósito |
| --- | --- |
| panelStaff | UID vinculado a Auth, nombre/email, membresías por país, estado, revisión y progreso de provisión |
| panelUserOperations | Actor, acción, plan antes/después, identificador idempotente, resultado y timestamps del servidor |
| panelControl | Primer superadmin protegido, exclusión de operaciones concurrentes y límite diario |

Las reglas Firestore existentes niegan acceso directo a estas colecciones. No se modifican ni despliegan reglas. La función usa una identidad técnica de servidor; ese privilegio no se transfiere a Flutter.

## Permisos y seguridad

- Solo superadmin vigente en el país puede administrar Usuarios. Las funciones de operación, médico, finanzas y dirección médica no tienen acceso al CRUD.
- Los roles son independientes por territorio. Para modificar una persona se requiere control de todos sus países actuales y de destino. El listado no revela roles de territorios fuera del alcance del operador.
- El estado canónico bloquea acciones de usuarios desactivados aunque conserven tokens antiguos. Claims se sincronizan y se revocan refresh tokens al cambiar permisos/estado.
- La revocación puede cerrar también sesiones de pacientes de la misma identidad: la interfaz lo advierte antes de confirmar. No se deshabilita globalmente la cuenta de Authentication ni se borran sus datos.
- No se proporciona borrado de usuarios ni de auditoría. El registro de operaciones no puede editarse desde el cliente; un administrador con IAM de Firestore sigue teniendo privilegios superiores, por lo que no se presenta como almacenamiento WORM.
- Una operación parcial queda visible como pendiente y se puede retomar por su actor original. UID determinista y requestId evitan duplicar cuentas al reintentar. No hay rollback destructivo automático; errores permanentes de proveedor/IAM necesitan revisión operativa.
- No se devuelven tokens, enlaces de recuperación, hashes de contraseña ni registros completos de Authentication. El alta no marca emailVerified.
- App Check y MFA siguen pendientes. La endpoint callable recibe tráfico HTTP pero exige autenticación/autorización para acciones; no es una función privada a nivel de red.

## Consumo

Configuración declarada: southamerica-west1, Node 22, 256 MiB, CPU fraccional gcf_gen1, concurrency 1, minInstances 0, maxInstances 1, timeout 60 s. Límite de 100 operaciones nuevas de mutación por día para el proyecto y 60 s entre reenvíos. Paginación acotada.

Estos controles no garantizan un gasto máximo de USD 10 ni cubren todos los costos de tráfico, registros, compilación o almacenamiento de artefactos. El presupuesto sigue siendo una alerta, no un corte.

## Verificación

- 24 pruebas Flutter aprobadas: login/regresiones, rutas, validaciones, envío del formulario a 320/1440 px, confirmación de baja, cuentas protegidas y reintento con requestId estable.
- 12 pruebas Node con Auth y Firestore emulados: aislamiento territorial, denegación de pacientes, altas/edición/baja/reactivación, idempotencia, auditoría, entrega fallida, recuperación parcial, paginación, acceso directo denegado, concurrencia y límite diario.
- 1 integración Flutter web → callable real en emuladores → Auth/Firestore: listado, alta, edición, baja y denegación sin sesión.
- Análisis sin incidencias y build web correcto. No se crearon cuentas ficticias remotas.
- Pruebas ejecutadas con Node 26 disponible localmente; runtime de despliegue declarado Node 22.
- npm audit reportó siete advertencias moderadas transitivas ligadas a uuid, cero altas/críticas. Se mantienen SDK oficiales actuales; no se forzó el downgrade incompatible propuesto por audit. Seguimiento antes de producción.

## Activación y bloqueo actual

Ronel autorizó habilitar la función de desarrollo con minInstances 0/maxInstances 1. El control de seguridad rechazó crear la cuenta técnica y modificar IAM porque esa autorización no era suficientemente específica para privilegios de proyecto.

Se solicitó autorización adicional para crear panel-users-runtime@segundaopinion-ea0c8.iam.gserviceaccount.com y asignar roles/firebaseauth.admin y roles/datastore.user. No Owner/Editor, no claves descargadas. Son permisos de alcance proyecto, aunque el código opere solo sobre las colecciones de personal. **Mientras esa autorización esté pendiente no se crea la cuenta técnica, no se cambia IAM ni se despliega usando otra identidad como sustituto.**

Despliegue, después de resolver IAM y comprobar pruebas:

```sh
firebase deploy --only functions:panel-users:managePanelUsers --project segundaopinion-ea0c8
```

No incluir Firestore Rules, Storage ni Hosting en ese comando. Verificar luego configuración efectiva, denegación sin sesión y listado con el superadmin existente. El primer listado inicializa su registro canónico protegido con los claims autorizados previamente. Las invitaciones reales las inicia Ronel desde el formulario.

## Pruebas reproducibles

```sh
export FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true
flutter analyze
flutter test
firebase emulators:exec --only auth,firestore --project demo-2daopinion "node --test --test-concurrency=1 functions/test/users.test.js"
firebase emulators:exec --only auth,firestore,functions --project demo-2daopinion "flutter test --platform chrome test/integration/panel_staff_emulators.dart --reporter expanded"
flutter build web
```

Requiere Java compatible con el emulador. functions/.env.local y registros de emulador se excluyen de Git/despliegue. La configuración de API key web es pública; no sustituye autenticación.

Referencias oficiales: [callables](https://firebase.google.com/docs/functions/callable), [administración de usuarios](https://firebase.google.com/docs/auth/admin/manage-users), [opciones de ejecución](https://firebase.google.com/docs/functions/manage-functions).
