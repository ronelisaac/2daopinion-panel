# E2-24 · Clasificación administrativa de solicitudes por especialidad

9 de septiembre de 2026 · Función publicada en desarrollo y QA remoto aprobado.

## Entrega

En el detalle de Solicitudes, Operaciones consulta y registra una especialidad por ID del catálogo activo de Chile. Origen requerido: confirmada por el paciente, indicación del equipo médico o sin confirmar. Una confirmación explícita es obligatoria. Sin información suficiente se mantiene pendiente; también puede quitarse una clasificación anterior para volver a pendiente.

Es una constancia administrativa del operador, no diagnóstico, triaje ni validación independiente de una derivación. No se deduce del texto privado, síntomas, archivos o nombres. El contacto para obtener esa confirmación y la validación médica de la derivación todavía no se resuelven con este módulo. No incluir información clínica ni datos personales: el formulario usa selecciones y un booleano, sin texto libre.

La clasificación no modifica la solicitud recibida, no asigna médico, no acredita consentimiento/documentación/pago ni habilita acceso clínico. Solo permite cambios mientras la solicitud está en received. El catálogo del paciente y la selección directa por el paciente quedan pendientes; no se publica el catálogo administrativo.

## Modelo y permisos

- intakeClassifications/{intakeId}: id estable de solicitud, countryCode, specialtyId opcional, specialtyName como instantánea del servidor, source enumerado, revision, updatedBy, updatedAt UTC, environment y schemaVersion.
- events/{requestId}: actor, país, solicitud, especialidad/origen anteriores y posteriores, nombre histórico posterior, revisión, digest y fecha de servidor.
- intakeClassificationLimits/{operatorUid}: máximo 20 cambios exitosos por operador/día UTC. No equivale a límite monetario.
- Todas estas rutas permanecen cerradas a los clientes por las reglas existentes. Acceso exclusivamente mediante intakeClassificationGet/Set en managePanelUsers existente.
- Solo Operaciones canónico vigente del país. Superadmin, Dirección médica, Médico, Finanzas y paciente no heredan este permiso. Auth del actor se comprueba en la entrada existente; estado canónico se revalida dentro de la transacción.
- Se comprueba identidad/país/entorno de la solicitud. Especialidad existente, ID coincidente, mismo país y activa al guardar. No confiar en nombre o estado enviados por Flutter.
- Escritura transaccional, revisión optimista, evento y cuota atómicos. Reintento del mismo comando confirmado devuelve éxito sin duplicar cambios, aun si después cambió la clasificación; se consulta nuevamente el estado actual. Reutilizar ID con otro contenido/actor se rechaza.
- No cambia intakeRequests, consultationSubmissions, documentos, consentimientos, roles, cuentas, asignaciones ni reglas clínicas.

## Validaciones y capas

Solicitud: 20 caracteres alfanuméricos. País CL para este despliegue. Especialidad CL_ más código válido del catálogo; null solo con origen unconfirmed. Source enumerado; confirmed debe ser true booleano. Revisión entera segura no negativa y requestId hexadecimal de 32 caracteres. Payload máximo 4096 bytes y rechazo de campos extras.

El servidor determina el nombre de especialidad, actor y fechas. No existe campo para UID de paciente ni datos clínicos. La baja posterior de especialidad conserva la instantánea y muestra una advertencia; una futura asignación debe volver a comprobar vigencia.

Dominio Dart puro y contrato IntakeClassificationRepository. Adaptador Firebase separado, controller sin BuildContext, widgets propios para tarjeta/formulario/selector, textos localizados. Catálogo paginado sin lectura ilimitada; no hay sondeo continuo. Reintentos de error de comunicación conservan requestId con el mismo contenido. Denegación descarta datos y bloquea escritura; conflicto exige actualizar.

## Verificación

- 104 pruebas Flutter y 50 de Functions aprobadas; análisis y build web correctos.
- Pruebas de tipos/origen/confirmación, pendientes, guardado, corrección, retiro de clasificación, replay, concurrencia, límites, país/roles, revocación, especialidad inactiva y solicitud fuera de recepción.
- Widgets a 320/768/1440 px, carga, pendiente, éxito, denegación y requeridos.
- Función existente publicada en segundaopinion-ea0c8. Sin cambios de IAM, reglas, índices, Storage, facturación ni Hosting. Panel local actualizado.
- Mismos recursos Node 22, Santiago, mínimo 0/máximo 1 instancia, concurrencia 1, 256 MiB e identidad panel-users-runtime. La alerta USD 10 no es corte garantizado.
- App real con Firebase y datos ficticios a 320/768/1440 px: pendiente, carga, formulario, requeridos, guardado, recuperación tras recarga/navegación al detalle, especialidad inactiva, conflicto concurrente, corrección y revocación. Los errores de campo desaparecen al corregir la selección/confirmación. Evidencia local en docs/desarrollo/evidencia/E2-24 de la raíz del proyecto.
- Catálogo vacío probado en widgets; el QA remoto conserva las otras especialidades del proyecto y solo desactiva temporalmente la ficticia. No se borra ni pausa el catálogo real para fabricar un estado vacío.
- QA remoto de seguridad: DTO mínimo, roles/payloads inválidos rechazados, lectura/escritura directa denegadas para seis tipos de sesión, sin modificación de intakeRequests. Guardado/replay/retiro de clasificación, especialidad inactiva y eventos/revisiones verificados con Firebase real.
- Limpieza comprobada: eliminadas cinco cuentas ficticias, cuatro registros de personal, solicitud/especialidad ficticias, clasificación, eventos y cuota propia. Ausencia verificada, credenciales temporales borradas y roles reales idénticos antes/después. No se restablecen cuotas compartidas ni se modifican otros catálogos.

## Siguiente

Asignación manual por país/especialidad, con revisión confiable de cuenta/vínculo y estados profesional/administrativo/disponibilidad. Antes de habilitar atención, definir precondiciones de documentación, consentimiento y pago, aceptación/rechazo, exclusividad y reasignación, junto a permisos específicos por caso. No usar una clasificación administrativa como autorización médica.
