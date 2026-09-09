# E2-21 · Espacio propio del médico y disponibilidad

9 de septiembre de 2026 · Publicado y verificado en Firebase de desarrollo.

## Recorrido

El rol Médico dispone de **Mi espacio médico** en el menú; una cuenta exclusivamente médica inicia allí. Resumen conserva el acceso a esta misma vista. Una cuenta con varios roles puede entrar desde su opción específica. El superadmin no hereda el rol Médico ni accede a esta ficha propia.

La vista muestra únicamente nombre, RNPI y especialidad de su ficha vinculada, y el estado de revisión interna en desarrollo. Sin vínculo, indica al profesional que contacte al administrador. Una ficha no aprobada, de versión antigua o con especialidad inactiva mantiene la recepción pausada.

Un interruptor booleano permite declarar disponibilidad; **Guardar disponibilidad** confirma el cambio en Firebase. No se guarda al tocar el interruptor y no se envían cambios sin modificar el valor. La pantalla consulta nuevamente el estado del servidor tras guardar y permite actualizarlo manualmente; una recarga recupera la preferencia.

Es una preferencia para futuras asignaciones manuales, no agenda, turnos, cupo, atención ni recepción automática. Pausar no modifica casos existentes. No se muestran pacientes, documentos, métricas ficticias, evidencia privada de revisión ni otros profesionales. No se requiere clínica.

## Capas y almacenamiento

- Dominio Dart puro: DoctorWorkspace, WorkspaceState y contrato DoctorWorkspaceRepository.
- DoctorWorkspaceController administra carga, cambio, reintentos y errores; no depende de Firebase ni de vistas.
- Adaptador FirebaseDoctorWorkspaceRepository utiliza managePanelUsers existente. Sin nueva API general o función adicional.
- Vista DoctorWorkspaceScreen; widgets separados DoctorWorkspaceSummary y DoctorAvailabilityEditor. Estilos compartidos, textos localizados y diseño adaptable.
- doctorAvailability/{uid}/countries/{country}: uid, doctorId y countryCode explícitos, accepting booleano, revisión entera, fecha UTC del servidor, token de versión, cuota diaria, environment y schemaVersion.
- Subcolección events/{requestId}: actor, país, doctorId, revisión, digest, estado anterior/posterior y fecha de servidor. Preferencia y auditoría se escriben atómicamente.
- IDs y fechas se convierten en el adaptador, sin referencias Firestore en dominio. Una futura migración puede separar preferencias y eventos en tablas con claves uid/country/doctorId; no depender del nombre o de URLs como identidad.

## Seguridad, validaciones y concurrencia

Acciones myWorkspace y setAvailability dentro de la callable existente. Ambas derivan el UID de la sesión, no aceptan un UID objetivo. Por ahora país CL; ampliación territorial explícita antes de admitir otros países.

Payload máximo existente de 4096 bytes, claves adicionales rechazadas. Guardar requiere accepting booleano, revision entera segura no negativa, workspaceToken de 64 caracteres hexadecimales y requestId de 32. El formulario no ofrece campos libres ni valores numéricos para esta preferencia.

En cada petición se comprueba Auth habilitado/correo verificado y sesión no revocada. En la transacción se verifica personal canónico activo/listo con rol Médico del país, vínculo directo e inverso del mismo usuario, ficha schemaVersion 2 aprobada en desarrollo y especialidad activa del país. No se confía solo en claims del cliente.

El token identifica la cuenta, país, ficha, generación del vínculo y revisión profesional. Cambiar el vínculo o la revisión invalida la confirmación anterior: se presenta pausado y exige confirmación explícita. Una especialidad inactiva bloquea la disponibilidad efectiva; reactivarla puede recuperar la preferencia previa si vínculo/revisión no cambiaron. El servidor debe volver a comprobar elegibilidad al implementar cada asignación.

Revisión optimista rechaza cambios concurrentes. Reintentar una operación incierta conserva requestId mientras no cambie su intención; el servidor evita duplicar evento/consumo. Una clave repetida con contenido distinto falla. Conflictos/revocación descartan la ficha local y exigen actualizar.

Máximo 20 cambios exitosos por cuenta/país y día UTC, independiente del cupo del CRUD administrativo. No equivale a límite de dinero ni limita consultas de lectura. No hay escucha permanente ni sondeo automático.

doctorAvailability y sus eventos permanecen cerrados a lectura/escritura directa por las reglas existentes, incluso para su propietario y superadmin. La función devuelve solo una proyección propia mínima; no abre doctorRecords, pacientes ni permisos por caso.

## Publicación y verificación

- 82 pruebas Flutter aprobadas; incluye acceso por rol/país, cambio requerido, idempotencia, errores, descarte tras revocación/dispose y widgets a 320/768/1440 px.
- 29 pruebas de Functions aprobadas en emuladores aislados: tipos y límites, vínculo, revisión, bloqueo, unicidad de operación, concurrencia, cuota diaria, permisos y regresiones de Usuarios.
- Análisis sin incidencias y build web normal correcto.
- Despliegue selectivo únicamente functions:panel-users:managePanelUsers en segundaopinion-ea0c8.
- Conserva Node 22, Santiago, mínimo 0/máximo 1 instancia, concurrencia 1, 256 MiB e identidad de servicio existente.
- Sin cambios de IAM, facturación, reglas, índices, Storage, Hosting, Google login, roles reales ni pacientes.
- El panel local utiliza el build actualizado. Esta entrega no publica un sitio Hosting.
- Recorrido remoto con la app Flutter real: cuenta médica ficticia, vínculo desde la función administrativa, guardado, pausa y recuperación tras recargar. Estados sin vínculo, ficha bloqueada, carga y permiso revocado capturados a 320/768/1440 px.
- Inspección visual de las capturas: tarjetas adaptables, editor legible, controles deshabilitados según estado y footer al final. Evidencia sin datos reales en la carpeta central docs/desarrollo/evidencia/E2-21.
- Pruebas remotas adicionales: proyección propia mínima; denegación a superadmin, Operaciones, Dirección médica, externo y anónimo; lectura/escritura directa de preferencia e historial cerradas; tipos inválidos, conflicto, idempotencia, revocación y reconfirmación tras desvincular/vincular.
- Limpieza verificada: cinco cuentas ficticias, cuatro registros de personal, dos fixtures, vínculo, preferencia/eventos y siete operaciones QA eliminados. Claims del médico ficticio y cuenta real sin cambios; credenciales temporales borradas, cuota/control compartidos intactos.

La alerta USD 10 no garantiza corte de gasto. Los límites de instancia y cambios reducen exposición, no sustituyen control de consumo.

## Pendiente

Cerrar la gestión administrativa de la ficha (baja/reactivación separada de revisión profesional), consulta de disponibilidad por Operaciones y asignación manual con permisos por caso. No convertir esta preferencia ni el vínculo de cuenta en autorización clínica. Agenda, estadísticas por rol, recetas y publicación de perfiles siguen sus entregas específicas.
