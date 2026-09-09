# E2-26 · Visibilidad y supervisión de Superadmin

9 de septiembre de 2026.

## Decisión

Ronel confirma: «el super admin puede ver todo». Todos los módulos aparecen en el menú de Superadmin para los países de su cuenta activa. Médicos y verificación deja de estar oculto; no se agrega Operaciones a la cuenta real para resolver una limitación del menú. Esta decisión sustituye la exclusión histórica de Superadmin de Médicos y Solicitudes.

## Alcance

- Navegación: todos los módulos, con cierre de sesión fijo al pie y lista desplazable.
- Médicos: registro y revisión existentes en lectura, estado administrativo y disponibilidad mínima confiable.
- Solicitudes: recepción administrativa mínima, clasificación y asignación en lectura.
- Usuarios, especialidades y clínicas: mantienen su gestión ya existente.
- Los módulos no implementados siguen indicándolo. Mi espacio médico es personal y requiere rol Médico; mostrar su enlace no permite suplantar al profesional.
- No cambian expedientes clínicos, archivos, datos privados de pacientes, reglas Storage ni permisos por caso.

Visibilidad, lectura y acciones se separan. Registro y baja/reactivación médica, clasificación y asignación continúan reservados a Operaciones; revisión profesional a Dirección médica; disponibilidad propia a Médico. Superadmin no adquiere estas acciones por esta entrega.

## Corrección de integración

Al probar Solicitudes en Flutter debug se detectaron claves idénticas en las tarjetas de clasificación y asignación. Se identifican ahora con prefijos distintos para que ambas puedan coexistir y actualizarse de forma independiente. Se añaden seis regresiones de integración para Superadmin/Operaciones a 320, 768 y 1440 px; las pruebas unitarias aisladas de tarjetas no detectaban ese error.

## Protección

PanelAccess.visible gobierna menú/rutas; allows conserva las capacidades específicas. Lecturas de doctorRecords y eventos requieren país, cuenta canónica activa y claims vigentes. intakeRequests mantiene país, verificación, cuenta canónica y consultas acotadas. No se permiten escrituras a partir del nuevo permiso de lectura: los eventos médicos conservan su guardia de Operaciones/Dirección médica.

managePanelUsers amplía únicamente doctorAdminList, intakeClassificationGet e intakeAssignmentGet. Revalida roles canónicos en transacción y devuelve editable/canAssign/canRelease falsos para supervisión. Candidatos y mutaciones siguen restringidos. Colecciones internas y documentos clínicos continúan cerrados.

## Validación y entrega

121 pruebas Flutter aprobadas; análisis sin incidencias. Suite combinada de Functions y reglas: 306 pruebas aprobadas, más 15 pruebas específicas de clasificación/asignación que incluyen dos casos nuevos de supervisión de registros guardados y revocación.

Despliegue selectivo: generar reglas de desarrollo y publicar solo firestore:rules mediante firebase.development.json; luego functions:panel-users:managePanelUsers. patientNotices sigue cerrado. Misma función, región, identidad y límites; sin nueva infraestructura o cambios de facturación.

Validación remota aprobada: lecturas reales con Superadmin temporal, denegación de escritura y datos clínicos, menú móvil con navegación y cierre de sesión fijo, detalle de solicitud, vacío, carga, revocación, recuperación y sesión/lectura tras recarga. Inspección visual en 320/768/1440 px; evidencia local en docs/desarrollo/evidencia/E2-26 de la raíz del proyecto.

Eliminados la cuenta y los cinco documentos ficticios, con ausencia comprobada. Claims de Ronel intactos; ninguna cuenta real recibe Operaciones. No queda contenido de QA en el producto. Análisis y compilación web de producción aprobados; Flutter del panel reiniciado en 8766. App de pacientes sin modificaciones. Backend de desarrollo publicado; no se configura ni publica Hosting en esta entrega.
