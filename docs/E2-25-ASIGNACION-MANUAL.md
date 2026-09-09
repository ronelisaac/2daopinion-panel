# E2-25 · Asignación manual administrativa

9 de septiembre de 2026 · Función publicada en Firebase dev; circuito administrativo probado.

## Entrega y acceso

Solicitudes → detalle → Asignación manual, para Operaciones CL. Elegir médico disponible de la especialidad confirmada, confirmar y guardar. Estado pendingAcceptance: pendiente de aceptación. Se puede liberar con motivo enumerado y luego corregir la clasificación o reasignar; historial conservado.

Esto completa la asignación administrativa en desarrollo, no el circuito clínico: no hay aceptación/rechazo del médico, bandeja médica de casos, notificación ni apertura del expediente todavía. No acreditar pago, revisión de documentos, consentimiento o habilitación profesional real por este estado. La revisión profesional existente sigue siendo de desarrollo. No se amplían roles reales de Ronel ni se da acceso a Solicitudes al superadmin por herencia.

## Comprobaciones confiables

- Solo Operaciones con Auth vigente y personal canónico activo/listo en CL, revalidado dentro de la transacción.
- Solicitud conocida, mismo país, entorno development y estado received.
- Clasificación schemaVersion 1 confirmada, ID de especialidad activo y revisión igual a la consultada.
- Ficha médica del país/especialidad, revisión aprobada dev schemaVersion 2, administración activa, vínculo bilateral, cuenta canónica y Auth habilitados/verificados, disponibilidad propia confirmada con token vigente.
- El selector es consultivo; al guardar se repiten todas las comprobaciones. No se recibe doctorUid, nombre, aprobación clínica ni pago desde Flutter.
- Una sola asignación pendiente por solicitud, revisión optimista e idempotencia. Liberar requiere motivo wrongSelection, availabilityChanged o routingChanged y confirmación. No equivale a cancelar atención ya iniciada.
- Mientras exista asignación pendiente, E2-24 bloquea reclasificación. Ambos procesos leen documentos compartidos dentro de transacciones: una carrera entre reclasificar y asignar no puede dejar una asignación nueva con clasificación obsoleta.
- Auth no participa en la atomicidad Firestore. Cambios posteriores pueden invalidar al médico: la futura aceptación y autorización clínica deben repetir las comprobaciones, no confiar en este registro histórico.

## Datos, capas y límites

intakeAssignments/{intakeId}: país, doctorId, doctorUid privado, doctorName histórico, specialtyId, classificationRevision, status, releaseReason, revision, updatedBy, updatedAt UTC, environment y schemaVersion. Eventos inmutables por requestId con actor, revisión, transición, médico/vínculo y digest. Cuota propia intakeAssignmentLimits/{operatorUid}: 20 cambios exitosos por día UTC, incluidas liberaciones; replay no duplica eventos/cuota.

Estado actual mínimo para Operaciones; no se exponen doctorUid, pacientes ni expedientes. Servidor actualiza únicamente asignación, evento y contador. intakeRequests queda intacta. Ninguna lectura/escritura directa de estas rutas desde Flutter, tampoco para el médico seleccionado.

Acciones intakeAssignmentGet/Candidates/Set/Release en managePanelUsers existente. Sin API general, nuevas reglas, índices o IAM. Selector por páginas de hasta 20 fichas del país (consulta límite 21), con filtrado por especialidad y disponibilidad del lado servidor; una página puede no tener elegibles y aún ofrecer más. Sin barrido ilimitado, sondeo automático ni reserva de agenda/capacidad exclusiva del médico. Se conserva un médico por solicitud, no una única solicitud por médico.

IDs, tipos, país, revisiones enteras seguras, booleano de confirmación, motivo enumerado y claves permitidas validados en servidor. Payload máximo 4096 bytes. Contrato/domain Dart puro, controller inyectado y widgets separados, textos localizados. Tarjetas de clasificación/asignación se actualizan mutuamente después de cambios; reintentos con mismo contenido conservan requestId.

## Verificación

111 pruebas Flutter y 57 de Functions aprobadas, análisis/build correctos. Tipos, rol/país, candidatos, disponibilidad obsoleta, cuenta revocada, especialidad y vínculo, exclusividad, replay, límites, concurrencia y bloqueo cruzado de clasificación probados.

App real contra Firebase dev a 320/768/1440 px: carga, vacío, formulario, selección/confirmación requeridas, error al pausar al médico antes de guardar, asignación, clasificación bloqueada, recarga, liberación/reasignación y revocación del operador. Evidencia ficticia en docs/desarrollo/evidencia/E2-25 de la raíz del proyecto.

QA remoto: seis tipos de sesión sin acceso directo al registro, médico seleccionado sin acceso a intakeRequests, DTO mínimo, Auth deshabilitado bloqueando nueva asignación, auditoría/revisión/replay e intake sin modificaciones. Mismos recursos efectivos: Node 22, Santiago, mínimo 0/máximo 1, concurrencia 1, 256 MiB y panel-users-runtime. USD 10 continúa como alerta, no corte garantizado.

Limpieza comprobada: cinco identidades ficticias y su personal, médico/especialidad/solicitud, vínculo, disponibilidad, clasificación, asignación, eventos y cuotas propias eliminados. Ausencia verificada, credenciales temporales borradas, roles reales sin cambios y cuotas compartidas intactas.

Por pedido de Ronel se reiniciaron ambos productos con Flutter web-server: panel en http://127.0.0.1:8766 y pacientes en http://127.0.0.1:8765. Sustituyen los servidores estáticos Python anteriores; ambos responden HTTP 200. Pacientes no tiene cambios de código en esta entrega. Para ver la función, entrar al panel con Operaciones y abrir el detalle de una solicitud; no usar la cuenta superadmin como si heredara este rol.

## Siguiente

Aceptación/rechazo por el médico con proyección administrativa mínima, vencimiento/reasignación y validación de cambios de cuenta/vínculo desde la asignación. Después, resolver precondiciones de consentimiento, documentación y pago y probar permisos específicos de expediente. No abrir historias clínicas para hacer visible esta asignación.
