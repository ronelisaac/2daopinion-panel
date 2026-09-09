# E2-23 · Disponibilidad visible para Operaciones

9 de septiembre de 2026 · Función desplegada en desarrollo y QA remoto aprobado.

## Recorrido

Médicos y verificación muestra a Operaciones la disponibilidad efectiva del médico junto a su estado administrativo/profesional. Es una consulta, no un turno, reserva, presencia en línea ni asignación.

Estados: disponible con confirmación vigente, pausado por el médico, pendiente de confirmación, sin cuenta vinculada, bloqueado por administración/revisión/especialidad/cuenta o vínculo inconsistente. Se muestra la primera causa de bloqueo; puede haber otras que aparezcan después de resolverla.

Cada tarjeta incluye la hora local de consulta y, cuando corresponde, la última confirmación del médico. Actualizar médicos vuelve a consultar Firebase. Al cargar más páginas, las anteriores conservan su fecha de consulta: no se presentan como recién verificadas. No hay sondeo automático ni métricas globales inventadas.

Operaciones no recibe un interruptor para cambiar preferencias ajenas. La confirmación/pausa de recepción sigue perteneciendo al médico. Dirección médica conserva el estado administrativo, pero no recibe esta nueva proyección de disponibilidad; superadmin, médico y externos no acceden a doctorAdminList.

## Implementación

- Se amplía la respuesta existente doctorAdminList; no hay otra API, función o colección.
- DTO DoctorOperationalAvailability y estado enumerado en dominio Dart puro; fechas UTC convertidas por el adaptador y widget DoctorAvailabilityStatus separado.
- El listado conserva lotes de hasta 20 IDs únicos del mismo país, obtiene estados por lote y mantiene las capas controller/vista/repositorio/dominio.
- Servidor comprueba revisión schemaVersion 2 aprobada en desarrollo, administración habilitada y especialidad activa en CL.
- Verifica vínculo inverso/directo, cuenta canónica activa/lista con rol Médico y Auth existente, habilitado, con correo verificado y coincidente con el registro canónico.
- Preferencia propia con uid/doctorId/país/entorno/versionado correctos, booleano y fecha de servidor. El token debe coincidir con cuenta, generación del vínculo, revisión profesional y administrativa.
- workspaceTokenFor se comparte con Mi espacio médico para evitar divergencias. Mantiene el token histórico cuando no hubo cambios administrativos: esta entrega no invalida preferencias existentes por un cambio de fórmula.
- Ausencia o token obsoleto exige reconfirmación; una pausa del médico nunca se presenta como disponible. Campos desconocidos se muestran como disponibilidad sin confirmar, no como disponible.
- La proyección nueva contiene únicamente state, checkedAt y confirmedAt. No añade correo, UID, token, eventos, documentos o datos de pacientes.
- No se escriben preferencias ni eventos al consultar. Identificadores y fechas explícitos conservan la posibilidad de migración futura a PostgreSQL.

## Seguridad y consumo

La acción mantiene país CL, lista de 1–20 IDs válidos únicos y rechazo de claves extras. Rol de Operaciones vigente, verificación Auth del actor y revalidación canónica dentro de la transacción. Dirección médica no dispara la lectura adicional de disponibilidad.

Lecturas Firestore de referencias conocidas, agrupadas y con duplicados eliminados; una consulta agrupada de Auth para hasta 20 identidades por intento de transacción. No hay búsqueda global de usuarios, llamada por cada tarjeta ni cambios de IAM. Un lote lleno puede requerir hasta aproximadamente 121 lecturas Firestore dentro de la transacción, más la comprobación previa del actor; los reintentos pueden aumentar ese consumo.

Firestore usa una transacción de lectura; Auth es un servicio externo y no forma parte de esa atomicidad. El resultado es una instantánea consultiva: la futura asignación debe repetir todas las comprobaciones confiables y gestionar cambios concurrentes. No autorizar casos con esta respuesta, su fecha o una selección antigua del cliente.

Los datos fuente continúan cerrados a lectura/escritura directa. Sin nuevas reglas, índices, Storage o permisos clínicos. Misma callable/identidad Node 22, Santiago, mínimo 0/máximo 1 instancia, concurrencia 1 y 256 MiB. La alerta USD 10 no garantiza corte de gasto. Sin Hosting nuevo; panel local actualizado.

## Verificación

- 95 pruebas Flutter y 44 de Functions aprobadas; análisis/build correctos.
- Todos los estados del widget comprobados a 320/768/1440 px; lectura sin controles de mutación, actualización y descarte de información obsoleta tras denegación.
- Servidor: token compatible con E2-21/22, confirmación/pausa, roles, vínculos, cuenta canónica/Auth, especialidad/revisión/administración, lista ordenada y error de Auth que falla cerrado.
- Publicada exclusivamente functions:panel-users:managePanelUsers en segundaopinion-ea0c8.
- Recorrido de la app real con Firebase a 320/768/1440 px: vacío, carga, sin vínculo, pendiente, disponible, recarga, pausa propia, bloqueo de cuenta/administrativo, reconfirmación y denegación tras revocar al operador ficticio. Evidencia local en docs/desarrollo/evidencia/E2-23 de la raíz del proyecto.
- QA remoto: proyección mínima, roles y consultas inválidas rechazados; lectura/escritura directa de preferencias denegada incluso al médico. Auth deshabilitado o sin correo verificado, cuenta canónica inactiva y especialidad inactiva bloquean disponibilidad sin modificar la preferencia. Recursos efectivos de la función comprobados.
- Limpieza verificada: cinco cuentas ficticias, cuatro registros de personal, médico/especialidad ficticios, vínculo, preferencia, estado administrativo, eventos y operación QA eliminados. Credenciales temporales borradas; roles reales idénticos antes/después y sin restablecer cuotas compartidas.

## Preparación de asignación manual: siguiente entrega

La recepción actual intakeRequests contiene país, modalidad, estado y conteos; no contiene specialtyId ni una clasificación autorizada. Sus reglas de creación rechazan claves adicionales y no habilitan actualización operativa. La especialidad del borrador clínico es texto privado, no una relación validada.

Antes de asignar:
1. Incorporar clasificación por ID del catálogo y una fuente/actor autorizados, con revisión y auditoría; no inferir especialidad por coincidencia de texto ni dar acceso clínico a Operaciones para completar ese dato.
2. Definir precondiciones de caso, modalidad, documentación y consentimiento, y cómo el pago confirmado condiciona el inicio de atención; E2-23 no acredita pagos ni habilita atención real.
3. Implementar asignación manual idempotente y auditable, con exclusividad/revisión y comprobación confiable de país, especialidad, cuenta, estado profesional/administrativo y disponibilidad.
4. Definir aceptación/rechazo/reasignación y permisos por caso. Asignar metadatos no debe abrir automáticamente expedientes; desplegar las reglas clínicas solo después de sus pruebas específicas.

Esta entrega cierra la consulta operativa de disponibilidad, no la asignación ni la atención médica.
