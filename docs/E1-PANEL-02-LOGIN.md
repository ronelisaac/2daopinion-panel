# E1-PANEL-02 · Login Firebase y menú por permisos

8 de septiembre de 2026. Ronel corrige la prioridad: login funcional antes que simuladores. Se elimina el CRUD de usuarios de ejemplo y el selector de rol; no se publican como entrega.

## Implementado

- Firebase Authentication con correo y contraseña en el proyecto dev existente. No hay registro público, Google, autenticación ficticia ni asignación de roles desde Flutter.
- Recuperación de contraseña con mensaje neutro, campos acotados, bloqueo de doble envío y limpieza de contraseña. No se almacenan contraseñas en controllers, archivos ni documentación.
- Restauración de sesión de navegador con persistencia SESSION y escucha de tokens; cierre de sesión. Un error de cierre se muestra, no se promete revocación si el proveedor falla.
- Acceso al panel requiere correo verificado y claims administrativos. Una cuenta de paciente sin membresías administrativas no entra.
- Rol/país se toman de las membresías recibidas, nunca de una selección libre. Una persona puede ser superadmin en CL y finanzas en AR sin obtener superadmin en AR.
- Menú lateral de escritorio y drawer móvil, con logo/tema de pacientes. Usuarios sigue como opción pendiente: no muestra un CRUD falso.
- Módulos clínicos/financieros pendientes, claramente identificados. El arranque normal no inyecta las solicitudes ficticias de la entrega anterior ni lee datos clínicos remotos. Las fixtures de bandeja permanecen para pruebas.

## Contrato administrativo v1

```json
{
  "panelAccess": {
    "version": 1,
    "active": true,
    "memberships": {
      "CL": ["superadmin"]
    }
  }
}
```

Roles: superadmin, operations, medicalDirector, finance, doctor. Cada país tiene su propio conjunto; idioma independiente. Claims ausentes, inactivos, malformados, con roles desconocidos o correo no verificado se rechazan. El parser de dominio no depende de Firebase.

Los claims se asignan desde un entorno confiable. El cliente solo usa su contenido para navegación: no sustituye validación de tokens y autorización en Firestore/Storage/operaciones privilegiadas. Las reglas remotas clínicas/financieras no cambian y no se concede acceso a expedientes. Cambios/revocaciones pueden requerir refresco del token; no se implementó revocación inmediata ni MFA.

## Menú previsto

| Rol | Opciones |
| --- | --- |
| Superadmin | Resumen, catálogo/precios, usuarios, países, pasarelas, auditoría |
| Operación | Resumen, solicitudes, médicos, asignaciones, agenda |
| Dirección médica | Resumen, médicos, revisión clínica, auditoría de su ámbito |
| Finanzas | Resumen, cobros/devoluciones, honorarios/liquidaciones, conciliación, catálogo/precios |
| Médico | Resumen, mis casos, agenda, informes, recetas, honorarios propios |

Superadmin no implica acceso clínico global; médico no implica buscador global de pacientes. La autorización por caso y la separación de tareas financieras están pendientes de implementar antes de conectar módulos reales.

## Bootstrap remoto autorizado

Ronel confirmó expresamente ronellezama@gmail.com como primer superadmin. Se consultó esa cuenta únicamente: no existía en Authentication. Se creó sin fijar contraseña y sin marcar el correo como verificado; se asignó panelAccess v1, activo, CL/superadmin. Se verificó la configuración con una segunda lectura. La solicitud de correo de establecimiento/restablecimiento de contraseña devolvió HTTP 200. No se inspeccionaron contraseñas ni se inició sesión como Ronel.

Ronel completó personalmente el acceso y confirmó «ingrese». Se observó el panel autenticado en Resumen, país CL y opción Usuarios disponible; no se leyó ni introdujo su contraseña. No se habilitaron permisos en otros países, Google, Hosting, Storage ni cambios de facturación. No se desplegaron reglas locales candidatas.

## Verificación

- Análisis estático sin incidencias; 18 pruebas Flutter aprobadas.
- Integración Flutter web con Firebase Auth Emulator y Chrome: cuenta no verificada y paciente sin membresías denegados; login con claims, aislamiento CL/AR, restauración, logout, error de contraseña, correo de recuperación emulado y cuenta suspendida. Una prueba integrada aprobada.
- Pruebas de widgets de login/recuperación/logout a 320 y 1440 px; sin botones de simulación ni registro.
- Compilación web correcta; panel local servido en 127.0.0.1:8766.

```sh
export FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true
flutter analyze
flutter test
firebase emulators:exec --only auth --project demo-2daopinion "flutter test --platform chrome test/integration/panel_auth_emulators.dart --reporter expanded"
flutter build web
```

La integración crea identidades ficticias solo en el emulador; no ejecutar seeds contra proyectos reales. La opción USE_FIREBASE_EMULATORS requiere debug.

## Siguiente entrega

CRUD real de equipo mediante invitaciones y operación privilegiada mínima, sin API general ni claves de administración en Flutter. Antes de habilitarlo: autorización de altas/cambios por país, auditabilidad, protección del último superadmin, bajas reversibles, revocación, MFA y límites. Después, envío paciente–panel y permisos por caso. No volver a construir simuladores para sustituir estas funciones.

Referencia técnica de bootstrap: [API administrativa de creación de cuentas](https://docs.cloud.google.com/identity-platform/docs/reference/rest/v1/projects/accounts). La inicialización SDK usa las versiones ya empleadas por pacientes.
