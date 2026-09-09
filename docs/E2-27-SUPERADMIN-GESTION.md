# E2-27 · Superadmin con lectura y escritura

9 de septiembre de 2026.

## Decisión vigente

Ronel confirma que Superadmin puede hacer lectura y escritura. Sustituye la decisión de solo supervisión de E2-26. El rol máximo administrativo puede ejecutar las acciones implementadas en los países autorizados de su cuenta, sin asignarle artificialmente Operaciones o Dirección médica.

## Acciones habilitadas

- Registrar y editar fichas médicas independientes con especialidad activa y RNPI válido.
- Registrar revisión profesional, incluso cuando Superadmin creó administrativamente la ficha. No se aprueba automáticamente: se mantienen referencia, fundamento, comprobaciones y transición válida.
- Pausar/reactivar la ficha con motivo y auditoría.
- Clasificar solicitudes y elegir, asignar, liberar o reasignar un médico cuando se cumplen los requisitos del flujo.
- Gestionar usuarios, vincular/desvincular cuentas médicas, especialidades y clínicas mediante sus controles existentes.

## Cuenta y ficha son entidades distintas

Crear un usuario con rol Médico habilita su cuenta, no crea una ficha ni verifica su profesión. Flujo: Médicos y verificación → Registrar médico → registrar revisión → Usuarios → vincular ficha a la cuenta por RNPI. No se solicitan datos personales que no se tengan ni se inventan RNPI, especialidades o evidencia para completar el vínculo.

## Invariantes

El permiso máximo no omite tipos, campos requeridos, auditoría atómica, revisiones/idempotencia, cuotas, estados válidos, protección de cuentas o aislamiento por país. Los demás roles mantienen sus límites. No hay eliminación física de fichas desde el producto: se usa baja/reactivación conservando trazabilidad.

Esta entrega no habilita módulos todavía pendientes ni convierte al administrador en un profesional: disponibilidad personal requiere una cuenta/ficha médica válida; expedientes y archivos privados siguen sujetos al circuito clínico por caso. No se agrega una regla universal de lectura/escritura a Firestore o Storage.

## Implementación y validación

PanelAccess.hasRole permite a Superadmin ejecutar capacidades administrativas de Operaciones y Dirección médica; los controllers conservan validaciones de negocio. Firestore reconoce doctorWriter y revisión por Superadmin, siempre con evento y estado correcto. managePanelUsers revalida autoridad canónica también en escrituras de administración, clasificación y asignación.

122 pruebas Flutter y 309 pruebas combinadas de reglas/Functions aprobadas. Incluyen registro y revisión por el mismo Superadmin, campos/checklist y auditoría obligatorios, revocación, país y permisos de otros roles. Análisis y compilación web aprobados.

Reglas selectivas y función existente publicadas en Firebase dev, sin modificar roles reales, IAM, Storage, índices, facturación ni Hosting. Flutter del panel reiniciado. Recorrido remoto aprobado con cuenta Superadmin ficticia: clasificación, pausa/reactivación, formulario de alta con requeridos, edición, revisión explícita de ficha propia administrativa, eventos y persistencia tras recarga. Inspección visual en 320/768/1440 px; evidencia en docs/desarrollo/evidencia/E2-27 de la raíz del proyecto. Eliminados cuenta, fichas/catálogos/solicitud ficticios, eventos y cuotas propias; ausencia verificada y claims reales intactos. App de pacientes sin cambios.
