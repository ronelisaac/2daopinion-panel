# E2-22 · Baja y reactivación administrativa del médico

9 de septiembre de 2026 · Publicado y verificado en Firebase de desarrollo.

## Operación

Médicos y verificación muestra **Administración: activa/pausada**, separada del estado profesional (pendiente, aprobado, rechazado o suspendido). Operaciones puede **Pausar ficha** o **Reactivar ficha**. Dirección médica consulta el estado administrativo, pero no lo modifica. Superadmin no hereda estos accesos.

Cada cambio requiere confirmación y un motivo de 10–500 puntos de código Unicode, sin contar espacios al inicio/final. El formulario es multilínea, indica obligatoriedad y límites, muestra el motivo anterior y los errores junto al campo. No introducir datos clínicos en este motivo. La acción fija el nuevo booleano: no permite editar país, identidad ni revisión profesional.

Pausar no borra la ficha, su historial, la cuenta, el vínculo o casos existentes. Bloquea la disponibilidad efectiva del profesional y la creación de nuevos vínculos. Desvincular una cuenta sigue siendo posible. Reactivar no aprueba al médico, no cambia una suspensión profesional y exige reconfirmar la disponibilidad.

El listado vuelve a consultar Firebase después del diálogo, incluso al cancelar tras un error/conflicto. Una recarga recupera el estado persistido. No hay asignaciones ni agenda automática.

## Arquitectura y datos

- Dominio DoctorAdministration y contrato DoctorAdministrationRepository, independientes de Firebase.
- Controller de listado integra estados por lote de hasta 20 IDs de la página obtenida de Firestore. Sin consultas por tarjeta ni escucha permanente.
- Controller DoctorAdministrationController, widget de formulario y tarjeta separados. Adaptador inyectado en el panel normal.
- Acciones doctorAdminList y doctorAdminSetActive dentro de managePanelUsers existente; ninguna API general o función nueva.
- doctorAdministration/{doctorId}: ID estable de ficha, país, active, revisión administrativa independiente, motivo, actor, fecha UTC de servidor, entorno y versión de esquema.
- doctorAdministration/{doctorId}/events/{requestId}: estado previo/nuevo, actor, motivo, revisión, digest y fecha; creación atómica con el estado.
- doctorAdministrationLimits/{actorUid}: contador diario UTC del operador, máximo 20 cambios exitosos; reintentos idénticos no consumen otro cambio. Es un control de uso, no un techo monetario.
- Ausencia histórica de documento significa administrativamente activa, revisión 0. No infiere aprobación profesional: siguen aplicando todas las comprobaciones previas. No se migran ni sobrescriben fichas existentes.
- Compatibilidad PostgreSQL: registros administrativos por doctorId y eventos con claves explícitas; dominio conserva IDs y DateTime, no rutas o tipos Firestore.

## Seguridad

Auth verificado/habilitado y estado canónico vigente. La transacción vuelve a comprobar país y rol; solo Operaciones escribe, Dirección médica también puede leer. Todas las fichas solicitadas deben existir en desarrollo y pertenecer al país CL. Otros países requieren implementación explícita.

Lista de 1–20 IDs únicos y válidos, sin objetivos arbitrarios ni campos adicionales. Guardar exige booleano real, revisión entera segura no negativa inferior al máximo seguro, ID estable CL_RNPI, motivo válido y requestId hexadecimal de 32 caracteres. Se mantiene límite global de payload de 4096 bytes.

No-op rechazado. Revisión optimista protege contra cambios concurrentes. La misma clave de operación solo puede repetir intención y actor; escritura y evento son atómicos. Ante un resultado incierto, el controller reutiliza clave mientras no cambie el motivo; conflictos, denegación y cuota agotada obligan a cerrar/actualizar.

Las nuevas colecciones y eventos continúan cerrados a lectura/escritura directa del cliente. No se publican motivos administrativos al médico: su espacio recibe únicamente estado general bloqueado cuando corresponde.

E2-20 comprueba la baja en vista previa y transacción de vinculación; no impide desvincular. E2-21 comprueba la baja en la transacción de disponibilidad y agrega la revisión administrativa al token después del primer cambio. Pausa/reactivación invalida confirmaciones anteriores, sin modificar el historial de disponibilidad.

No cambia doctorRecords, revisión profesional, Auth, roles, doctorAccountLinks, pacientes o permisos por caso. Las futuras asignaciones deberán consultar estado administrativo, revisión, especialidad, cuenta y preferencia vigentes en la misma autorización, no solo confiar en el listado.

## Verificación y publicación

- 91 pruebas Flutter aprobadas: motivos vacíos/espacios/límites Unicode, roles/país, reintentos, conflictos, descarte tras dispose, listado seguro y formularios a 320/768/1440 px.
- 37 pruebas Functions aprobadas en emuladores: listado y mutación, pertenencia territorial, permisos, ausencia histórica, auditoría, idempotencia, concurrencia, cuota, bloqueo de vínculo/disponibilidad y conservación de revisión profesional.
- Análisis sin incidencias y build web normal correcto.
- Publicada exclusivamente functions:panel-users:managePanelUsers en segundaopinion-ea0c8. Sin nuevas reglas, índices, IAM, facturación, Storage o Hosting; Google sigue sin activarse.
- Misma identidad de servicio, Node 22, Santiago, mínimo 0/máximo 1 instancia, concurrencia 1 y 256 MiB. USD 10 continúa siendo alerta sin corte garantizado.
- Panel local actualizado. No equivale a publicación de un sitio Hosting.
- QA remoto con la app Flutter real y una ficha ficticia: vacío, carga retardada, motivo requerido, pausa, recuperación tras recarga, reactivación y permiso revocado. Capturas a 320/768/1440 px; corregido y comprobado el ajuste multilínea del error en móvil.
- Verificada en remoto la denegación de lectura/escritura directa del estado y eventos para Operaciones, Dirección médica, superadmin, Médico, externo y anónimo. API permite solo los roles definidos; motivos inválidos, conflictos y cambios de intención se rechazan.
- Después de pausar, la cuenta ficticia queda bloqueada para confirmar disponibilidad y la vista previa de vinculación falla. Al reactivar queda lista pero con recepción pausada, sin alterar revisión profesional, cuenta o vínculo.
- Limpieza remota comprobada: cinco identidades QA, cuatro registros de personal, dos fixtures, estado administrativo/eventos/contador del operador ficticio, disponibilidad/eventos, vínculo y una operación de vinculación eliminados. Ausencia verificada; credenciales temporales borradas. Roles de la cuenta real y del médico ficticio sin cambios; control/cuota compartidos no reiniciados.
- Evidencia visual central: docs/desarrollo/evidencia/E2-22. Se verificó que no hubiera otras fichas antes de capturar; el vacío se obtuvo retirando/restaurando únicamente el fixture controlado. Sin datos reales en las capturas.

## Siguiente

Consulta de disponibilidad por Operaciones y asignación manual por país/especialidad con permisos explícitos por caso. El historial administrativo se conserva, pero todavía no hay visor de auditoría. Gestión de agenda, métricas por rol, recetas y publicación al paciente mantienen sus entregas independientes.
