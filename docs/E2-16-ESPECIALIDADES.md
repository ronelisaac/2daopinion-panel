# E2-16 · CRUD de especialidades

9 de septiembre de 2026. **Entrega parcial: CRUD y adaptador Firebase implementados y verificados con emuladores; activación y QA remoto pendientes de respuesta a la autorización solicitada.** No se declara terminada la sección conectada al proyecto real. Médicos E2-15 sigue activo y no se modifica su alcance.

## Implementación

- Menú «Especialidades» y listado por país, páginas de 20, alta, edición y confirmación de desactivación/reactivación.
- Baja lógica: conserva el código y el historial. No hay borrado físico desde clientes, tampoco de eventos.
- Propuesta de permisos pendiente de confirmar: superadmin administra; Operaciones y Dirección médica consultan. Reglas exigen correo verificado, claims y personal canónico activos y coincidentes para CL. Finanzas, médicos, pacientes y anónimos no acceden.
- Cada cambio guarda documento y snapshot de auditoría en la misma transacción. Creación, edición, desactivación y reactivación son acciones distintas. No se puede cambiar estado y antecedentes en una misma operación.
- Bloqueo de código duplicado incluso inactivo; detección de revisión obsoleta sin sobrescribir silenciosamente. Error recuperable y paginación; se limpian registros de la vista al fallar una lectura o cambiar sesión/país.
- Vistas/widgets, controller, dominio y repositorio separados. Textos localizados y diseño compartido; sin dependencia Firebase en las entidades de dominio ni API nueva.

## Campos y contrato

| Campo | Tipo y restricciones |
| --- | --- |
| País | Código de país obtenido de la sesión; CL habilitado en esta etapa |
| Código | String requerido, 2–32 caracteres; comienza con letra; ASCII minúsculas, números o guion bajo; normalizado e inmutable |
| Nombre | String requerido, 2–100 puntos de código Unicode, sin espacios en extremos |
| Descripción | String opcional, hasta 500 puntos de código Unicode, sin espacios en extremos |
| Activa | Booleano; true al crear; cambios posteriores mediante acción confirmada |
| Revisión | Entero consecutivo, desde 1; controla concurrencia |
| Autor y fechas | UID autenticado y timestamps de servidor; creación inmutable |

Identidad: `specialties/CL_{code}`. Unicidad garantizada por país/código; el nombre es editable y no tiene una restricción de unicidad implementada. El código es administrativo, no se presenta como clasificación clínica oficial. La misma especialidad en otro país requiere definir su habilitación y relación; no se presume un código global certificado.

Auditoría: `specialties/{id}/events/{revision}`, con actor, país, acción, hora y snapshot exacto. No se exponen enlaces públicos ni datos de pacientes. IDs y fechas se mapean en el adaptador; el modelo permite una futura tabla de especialidades y otra de eventos en una base relacional.

## Pruebas y evidencia

53 pruebas Flutter aprobadas, incluidas 14 nuevas de dominio/controller/widgets. Integración Flutter web con el adaptador real y emuladores aprobada: alta, duplicado, corrección, conflicto obsoleto, baja/reactivación, lectura desde otra cuenta, cuatro eventos y paginación sin solapamiento. Análisis y builds web debug/release verificados.

190 pruebas de reglas aprobadas: validaciones de tipo, vacíos/espacios, límites exactos, código, inmutabilidad, revisión, país, roles, estado canónico, revocación, consultas sin límite, aislamiento, auditoría atómica y prohibición de borrado. Las reglas de especialidades solo se incluyen explícitamente para estas pruebas; el subconjunto normal conserva exactamente E2-15.

Navegador emulado a 320/768/1440 px: vacío, requeridos, éxito, duplicado, confirmación, inactivo/reactivado, persistencia al cerrar sesión y volver a entrar, carga con latencia controlada, error por revocación y lectura sin controles de escritura para ambos roles lectores. Evidencia ficticia en `docs/desarrollo/evidencia/E2-16` de la carpeta central. No equivale a persistencia o restauración de sesión verificadas contra el proyecto remoto.

Los emuladores y el servidor temporal de QA se detienen sin exportar identidades. Credenciales temporales eliminadas. No se modifican las vistas previas habituales 8765/8766 ni los roles de Ronel, IAM, facturación, Functions, Storage o Hosting.

## Reproducción y activación pendiente

```sh
flutter test
flutter analyze
npm run test:rules
firebase emulators:exec --only auth,firestore --project demo-2daopinion \
  'flutter test --platform chrome test/integration/specialties_emulators.dart --reporter expanded'
flutter build web --debug --dart-define=USE_FIREBASE_EMULATORS=true
```

La compilación normal no inyecta especialidades hasta activar `ENABLE_SPECIALTY_CATALOG`; los emuladores sí. El generador de desarrollo excluye especialidades y avisos por defecto. Después de confirmar permisos, baja lógica y QA ficticio remoto, revisar el subconjunto preparado con `node scripts/development-rules.mjs --include-specialties` y publicar exclusivamente `firestore:rules` con `firebase.development.json` y proyecto explícito `segundaopinion-ea0c8`. No publicar todos los candidatos de `firebase.json`.

Antes de cerrar: repetir el recorrido remoto, verificar auditoría y aislamiento, retirar únicamente los datos QA, comprobar roles reales sin cambios y actualizar el valor normal del generador/adaptador para conservar la activación en futuras entregas. La alerta de USD 10 no garantiza un corte de gasto.

## Dependencias pendientes

- Conectar selectores de médicos y solicitudes a especialidades por ID; el texto libre de E2-15 permanece transitorio y sin migración automática.
- Definir una proyección pública segura para pacientes, distinta del catálogo administrativo privado, que preserve la navegación sin login.
- Resolver mapeo revisado de datos anteriores y múltiples especialidades por médico; estar activo en el catálogo no verifica al profesional.
- CRUD de clínicas y sus relaciones, publicación y asignaciones clínicas fuera de esta entrega.

El módulo almacena auditoría; no entrega todavía un explorador global del historial. No se habilita atención clínica ni se publica una oferta médica real.
