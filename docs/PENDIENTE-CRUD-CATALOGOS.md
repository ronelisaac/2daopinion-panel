# Médicos, especialidades y clínicas · CRUD administrativos

Decisión confirmada por Ronel el 9 de septiembre de 2026: todos los médicos, especialidades y clínicas se administran desde sus respectivos CRUD en el panel. Es una definición de producto, no una declaración de que los tres módulos estén terminados.

## Alcance acordado

- Médicos: alta, consulta/listado, edición y baja administrativa, manteniendo separado el proceso de verificación profesional por país.
- Especialidades: catálogo administrable que alimente los selectores de médicos y solicitudes; no mantener listas de negocio fijas en el código.
- Clínicas: catálogo administrable y relaciones explícitas con los médicos cuando correspondan; no confundirlo con convenios B2B, facturación de clínicas ni cuentas de acceso.
- Los tres módulos deben conectarse a Firebase, mantener capas y widgets separados, permisos por rol/país, validaciones de tipos/requeridos/límites, auditoría y validación visual responsiva.
- La app de pacientes consume únicamente los datos autorizados para publicación; no recibe acceso al expediente administrativo privado por usar el mismo catálogo.

## Criterios de implementación

IDs estables y relaciones mediante identificadores, independientes de nombres editables y de tipos Firebase en el dominio. Separar el país operativo del locale; definir habilitación territorial antes de ampliar países.

La baja debe preservar registros referenciados por casos, verificaciones o historial. Propuesta: desactivación reversible en lugar de borrado físico de registros con referencias; resolver qué puede eliminarse definitivamente antes de implementar esa acción. Una baja del catálogo no debe borrar expedientes ni modificar silenciosamente casos existentes.

Las especialidades se seleccionarán por ID desde el catálogo. El texto libre de especialidad principal existente en E2-15 es transitorio: su migración requiere mapeo revisado, sin inventar equivalencias ni certificar especialidades automáticamente. Definir relaciones médico–especialidad y médico–clínica sin asumir exclusividad ni pertenencia obligatoria a una clínica.

## Prioridad vigente · 9 de septiembre · E2-19

Ronel prioriza médicos como profesionales independientes aunque el CRUD de clínicas ya exista. No exigir clínica para registrar al médico ni inferir afiliaciones. E2-19 conecta la especialidad principal al catálogo privado por ID y conserva el nombre como instantánea; no publica perfiles ni acredita automáticamente profesionales.

## Estado y siguiente orden propuesto

1. Especialidad principal del médico vinculada al catálogo activo: E2-19; fichas antiguas se actualizan explícitamente, nunca por coincidencia de nombre.
2. E2-20 vincula/desvincula la cuenta desde Usuarios con confirmación explícita, unicidad y auditoría. E2-21 añade espacio propio y preferencia de disponibilidad con Firebase; E2-22 entrega baja/reactivación administrativa con motivo y auditoría, conservando la revisión profesional separada. E2-23 permite a Operaciones consultar disponibilidad efectiva con fechas y bloqueos, sin modificar preferencias del médico.
3. Siguiente: clasificación autorizada de solicitudes por specialtyId y luego asignación manual por país/especialidad con permisos por caso; no depende de una clínica. No inferir especialidad del texto privado ni tratar disponibilidad como autorización clínica. Definir precondiciones de documentación, consentimiento y pago, exclusividad, aceptación/rechazo y reasignación.
4. Afiliaciones opcionales a clínicas más adelante; sin forzar exclusividad ni convenios.

E2-15 entrega registro/corrección/revisión manual de médicos en desarrollo; no un CRUD completo con eliminación. [E2-17](E2-17-ESPECIALIDADES-FIREBASE.md) y [E2-18](E2-18-CLINICAS-FIREBASE.md) activan especialidades y clínicas con baja lógica, validaciones y auditoría en Firebase remoto; superadmin administra y Operaciones/Dirección médica consultan por país. E2-20 añade vínculo administrativo de cuenta, sin acceso clínico automático. E2-19 conecta médicos con especialidades por ID; la relación con clínicas no es prioritaria ni obligatoria. Selectores del paciente y proyección pública segura pendientes. La política vigente autoriza publicar secciones verificadas de desarrollo sin nueva confirmación rutinaria; no ampliar roles reales ni habilitar atención clínica por inferencia.
