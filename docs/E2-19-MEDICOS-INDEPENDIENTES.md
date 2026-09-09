# E2-19 · Médicos independientes y especialidad del catálogo

9 de septiembre de 2026 · Firebase de desarrollo: segundaopinion-ea0c8.

## Decisión y alcance

El médico es un profesional independiente. La existencia del CRUD de clínicas no implica pertenencia, convenio ni requisito de afiliación. Se prioriza su gestión individual; ninguna clínica es obligatoria para esta ficha. No se agregan cuentas, asignaciones clínicas ni publicación al paciente en esta entrega.

La especialidad principal deja de ser texto libre en altas y correcciones: selector de especialidades activas del país, desde el repositorio real, paginado en bloques de 20 con actualización/reintento. Incluye código para distinguir nombres duplicados. País operativo y locale permanecen separados.

## Modelo y compatibilidad

- doctorRecords/CL_{registryNumber} mantiene ID estable.
- Nuevas altas/correcciones: schemaVersion 2, specialtyId obligatorio y specialty como nombre histórico seleccionado.
- No clinicId obligatorio, listas de negocio hardcodeadas ni tipos Firebase en dominio.
- Lectura de schemaVersion 1 preservada. Operaciones debe elegir explícitamente una especialidad al corregir; no hay migración por nombre ni modificación masiva.
- Fichas históricas pendientes/rechazadas se vinculan con una edición, quedan pendientes y requieren revisión independiente.
- Una ficha histórica aprobada puede suspenderse; no se permite nueva aprobación sin referencia válida. Puede rechazarse desde suspensión y luego corregirse mediante el circuito existente.
- Renombrar/desactivar el catálogo no reescribe antecedentes ni auditoría. Desactivación bloquea nuevas altas/ediciones/aprobaciones con esa referencia, pero no borra ni revoca silenciosamente fichas anteriores.

## Validación y permisos

Nombre requerido, 3–120 puntos de código Unicode; RNPI string de 1–10 dígitos sin cero inicial; especialidad principal requerida con ID CL y código de 2–32 caracteres del catálogo. Nombre histórico de 2–120 caracteres; el catálogo limita nombres a 100.

Interfaz y controller rechazan ausencia de selección y referencias mal formadas. Adaptador verifica existencia, país, estado activo y nombre dentro de la transacción. Reglas vuelven a comprobarlo, además de forma exacta, revisión, actor y fechas de servidor. Para aprobar se exige referencia activa del mismo país; un renombre no invalida la instantánea histórica.

Operaciones registra/corrige; Dirección médica revisa sin auto-revisión del creador; superadmin administra especialidades, sin heredar acceso a médicos. No cambian roles de usuarios reales. Cada mutación médica conserva evento inmutable y snapshot atómico.

## Verificación y despliegue

- 70 pruebas Flutter: dominio, permisos, migración explícita, selector, paginación/fallos y formularios a 320/768/1440 px.
- 247 pruebas de reglas Firestore/Storage aprobadas: referencias inexistentes, inactivas, otro país, nombre falsificado, datos legacy, auditoría y restricciones previas.
- Integración del adaptador Flutter con Auth/Firestore emulados aprobada: alta, edición, duplicado/conflicto, revisión independiente e historial.
- Análisis sin incidencias y build web normal correcto.
- Reglas publicadas únicamente con firebase.development.json y el subconjunto generado; patientNotices sigue cerrado. Sin Functions, índices, Storage, IAM, facturación ni Hosting nuevos.
- QA remoto ficticio desde formularios reales: catálogo creado por superadmin de prueba, alta/edición médica por Operaciones y revisión por otra identidad. Sesión y datos recuperados tras recarga.
- Pruebas remotas de rechazo de referencias inexistentes/inactivas/de otro país, nombre falsificado y campos ajenos; aislamiento de anónimo/externo/superadmin, auditoría y revocación canónica. La desactivación del catálogo conserva la ficha ya revisada y su nombre histórico.
- Inspección visual móvil/tablet/escritorio: formulario requerido, listado vacío, carga, éxito/revisión y error de permisos. Evidencia sin pacientes ni información clínica real.
- Limpieza final verificada: cuatro identidades QA, tres documentos de personal, médico, especialidad y cinco eventos eliminados; credenciales temporales borradas. Roles reales intactos. Fuente publicada comparada exactamente con el subconjunto generado.
- Evidencia visual: carpeta central docs/desarrollo/evidencia/E2-19. No sustituye autorización para atención clínica.

El servidor local del panel usa el build actualizado. Esto no equivale a publicar un nuevo sitio de Hosting. Reglas remotas y código deben evolucionar juntos: clientes antiguos no pueden crear fichas sin specialtyId. Revertir lectura del catálogo de especialidades también bloquea el selector médico; no ejecutar esa reversión aisladamente como despliegue normal.

## Próximo incremento

Completar la gestión del profesional independiente: política de baja administrativa y vínculo con su cuenta, antes de asignaciones clínicas. Conservar la separación entre registro, habilitación profesional, acceso por caso y perfil público. Afiliaciones opcionales a clínicas quedan para después.
