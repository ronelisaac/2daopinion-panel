# E2-11 · Adjuntos vinculados a recepción

9 de septiembre de 2026 · Candidato local, no desplegado. Amplía E2-10 sin nueva API ni función.

## Contrato

- consultationSubmissions/{uid} conserva opcionalmente attachmentBatch: copia exacta del contador privado draftAttachments/{uid}, con count, bytes, videoCount cuando existe, lastDocumentId y updatedAt. Las reservas individuales son inmutables y no pueden agregarse al enviar ni después. Se vincula el lote entero, no una selección parcial.
- Los objetos permanecen en su ubicación privada original. No se copian bytes ni se generan URLs públicas; documentId, storageBackendId y objectKey conservan la separación portable del dominio.
- Política nueva dev-submission-2026-09-09, con aceptación independiente del registro/guardado. La política anterior admite únicamente texto sin reservas, por compatibilidad. Comprobantes anteriores se leen con cero documentos y sin video.
- intakeRequests incorpora documentCount y hasVideo, calculados desde la reserva. No incorpora nombres, títulos, IDs de archivo, rutas, propietarios ni texto clínico. El panel presenta documentos vinculados, pendientes de validación, sin descarga.
- Permisos de lectura administrativa sin cambios: operations canónico activo/ready del país. Superadmin, finanzas y otros roles no adquieren acceso por inferencia. No se modificaron roles de Ronel.

## Protección y límites

El adaptador de pacientes inspecciona todos los adjuntos con el contrato PrivateDocumentRepository antes de crear la recepción. Storage getMetadata comprueba existencia, tamaño, MIME y checksum declarado contra la reserva; el lector existente comprueba SHA256 cuando descarga bytes. El lote inspeccionado debe coincidir en cantidad y último ID con la reserva leída dentro de la transacción. Un archivo faltante o una reserva concurrente detienen el flujo normal. Los reintentos recuperan primero el comprobante existente sin exigir una nueva inspección.

Firestore valida el lote contra el contador antes y después del commit, y exige la creación conjunta del resumen y copia privada. Impide reservas nuevas junto con el envío o posteriores. Storage niega creación, sustitución y borrado desde clientes después de existir la recepción; mantiene lectura individual del propietario verificado. La reserva inmutable acredita propietario, borrador y ubicación: se elimina la consulta redundante al borrador actual para usar como máximo dos documentos Firestore por escritura de Storage (reserva y recepción).

**No hay una transacción distribuida entre Firestore y Storage ni certificación de bytes.** Las reglas Firestore no verifican existencia del objeto. Un cliente manipulado puede enviar una reserva sin completar su carga; la suite documenta expresamente este límite y verifica que no pueda rellenarla después. También puede haber una operación Storage concurrente entre inspección y envío. No tratar received o los conteos como admisión, integridad binaria certificada o validación médica. Se requiere verificación confiable, cuarentena y un flujo autorizado de corrección antes de uso clínico real; no habilitarlo remotamente por considerar suficientes estas pruebas locales.

La cuota sigue siendo acumulativa: hasta 20 documentos y un video, 50 MiB totales; borrar bytes antes de enviar no libera la reserva. Sigue siendo posible restaurar exactamente el archivo antes del envío. Después no hay borrado/corrección de cliente ni liberación automática de cuota. Una recepción por cuenta en esta fase; múltiples casos, retención, supresión autorizada y revisión profesional siguen pendientes dentro del plan.

## Verificación

- 146 pruebas Flutter pacientes y 26 panel; ambos análisis sin incidencias y builds web correctos.
- 126 pruebas de reglas Firestore/Storage aprobadas, incluyendo lote alterado/omitido, política incorrecta, conteos falsificados, permisos cruzados, reservas bloqueadas, lectura propia y borrado/carga posterior denegados.
- Dos integraciones Chrome con los adaptadores reales contra emuladores: dos PDF y video, archivo faltante/restaurado, reserva concurrente, doble envío idempotente, recuperación y panel limitado a cantidades. Datos y bytes ficticios: la prueba MP4 no certifica decodificación ni duración real.
- Widgets prueban ausencia de acciones de carga/borrado tras recepción y nueva aceptación al cambiar adjuntos; se mantienen las pruebas responsive existentes.

Desde panel, con Node, Java, Firebase CLI, Flutter y Chrome disponibles:

```sh
firebase emulators:exec --only firestore,storage --project demo-2daopinion 'node --test --test-concurrency=1 firebase/test/*.test.mjs'
firebase emulators:exec --only auth,firestore,storage --project demo-2daopinion 'bash scripts/test-reception.sh'
flutter analyze
flutter test
flutter build web
```

Ejecutar analyze/test/build también en pacientes. Los repos son hermanos; usar emuladores nuevos sin datos importados. FLUTTER_BIN permite configurar el ejecutable en el script. No exportar identidades ficticias ni reutilizar las pruebas contra datos remotos.

## Siguiente entrega

Resolver múltiples solicitudes y validación confiable/correcciones del lote, después asignación/verificación profesional y permisos por caso. Antes de activar remoto: autorización específica, revisar diferencias de reglas/índices, IAM cruzado Storage–Firestore, costos y pruebas de aislamiento. No se desplegaron Rules, Storage, Hosting ni Functions, no se creó bucket y no se tocó facturación. USD 10 continúa siendo una alerta, no un corte. El dashboard DEV-045 sigue pendiente después del circuito de solicitudes.
