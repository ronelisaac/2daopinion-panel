# Infraestructura Firebase compartida

## Estado vigente · E2-18 clínicas

`clinics` y auditoría publicados y verificados en Firebase dev; datos tipados y acotados, baja lógica, superadmin administra y operations/medicalDirector leen por país/estado canónico. Generador incluye clínicas por defecto; `--exclude-clinics` solo para reversión deliberada. Conserva los módulos activos y avisos incompletos cerrados. [Contrato, despliegue y pruebas](../docs/E2-18-CLINICAS-FIREBASE.md).

## Estado vigente · E2-17 especialidades

Reglas de `specialties` y auditoría transaccional publicadas y comprobadas en Firebase dev: superadmin administra; operations/medicalDirector leen; país y personal canónico obligatorios. Desactivar/reactivar sin borrar registros ni historial. El generador incluye especialidades por defecto, conserva E2-15 y mantiene avisos cerrados. `--exclude-specialties` es una reversión deliberada. [Activación, pruebas y alcance](../docs/E2-17-ESPECIALIDADES-FIREBASE.md). Secciones verificadas se publican bajo la política vigente, no todos los candidatos incompletos.

## Estado vigente · E2-15

Médicos y revisión manual activos en Firestore de desarrollo tras autorización y QA remoto ficticio. Generar con `node scripts/development-rules.mjs`: incluye médicos y recepción/adjuntos E2-13, excluye avisos. Desplegar solo los servicios autorizados con `firebase.development.json`, nunca todos los candidatos de `firebase.json`. `--exclude-doctors` es una reversión deliberada, no el valor normal. [Pruebas y límites](../docs/E2-15-MEDICOS-FIREBASE.md). Este estado sustituye las restricciones históricas de E2-11 siguientes.

## E2-11: recepción con reservas vinculadas, candidato local

La copia privada del envío conserva attachmentBatch, idéntico al contador de reservas antes y después de la transacción. intakeRequests agrega solo documentCount/hasVideo. Firestore bloquea reservas nuevas en el mismo envío o después; Storage bloquea creación y borrado después de la recepción y conserva lectura del propietario. No certifica existencia ni validez de bytes desde Firestore. 126 pruebas de reglas y dos integraciones web aprobadas; sin despliegue ni cambios IAM. [Contrato, límites y reproducción](../docs/E2-11-ADJUNTOS-EN-RECEPCION.md). Este estado prevalece sobre el historial de candidatos siguiente; nunca desplegar todo por inercia.

## E2-08: avisos privados, candidato local

`patientNotices/{uid}/items/{noticeId}` permite lectura al destinatario verificado con perfil y cambio exclusivo de `readAt` a hora del servidor o null. Clientes no pueden crear/borrar avisos ni cambiar su contenido. Consultas limitadas hasta 100. 102 pruebas de reglas aprobadas; integración con Flutter web/Auth/Firestore local verifica paginación, persistencia e aislamiento. No hay productor de eventos, push/email ni cambios remotos. **No desplegado**. [Alcance y pendientes](../../2daopinion-app/docs/E2-08-CENTRO-DE-AVISOS.md).

## E2-07: video opcional y formatos, solo local

Las reglas candidatas ahora aceptan JPG/JPEG, PNG, DOC, XLS y PDF por extensión y MIME concordantes; un video MP4/MOV opcional con duración declarada entre 1 y 30000 ms y hasta 20 MiB. Documentos hasta 5 MiB. Cuota acumulada: 20 documentos más una reserva de video, 50 MiB entre todos; listado hasta 21. Compatibilidad con contadores anteriores sin `videoCount`. Las reglas no verifican duración ni formato binario real; hace falta inspección confiable antes del uso clínico. 95 pruebas de reglas aprobadas. **No desplegado**, ni bucket nuevo ni cambio de facturación. [E2-07](../../2daopinion-app/docs/E2-07-VIDEO-OPCIONAL-Y-FORMATOS.md) prevalece sobre los límites históricos siguientes.

## E2-06: candidato local, NO desplegar todavía

08/09/2026: se incorporan reservas privadas de documentos en Firestore, reglas de Storage y emulador Storage en `127.0.0.1:9199`. **Las nuevas reglas de este checkout no están publicadas.** La última entrega remota sigue siendo E2-05. No ejecutar el comando de despliegue histórico siguiente sin revisar y aprobar este cambio pendiente.

`npm run test:rules` ejecuta 87 pruebas de Firestore/Storage. Comprueban propiedad, correo verificado, reserva transaccional, metadatos cerrados, cuota, ausencia de sobreescritura y denegación de listado Storage/acceso cruzado. Las reservas acumulan hasta 20 documentos/50 MiB por cuenta; cada archivo hasta 5 MiB. No se devuelve cuota al borrar bytes y los metadatos no son borrables por clientes. Es un límite conservador de pruebas, no una política comercial ni un máximo de facturación.

La prueba integrada de Flutter requiere los tres emuladores; desde este repositorio, con Java y Chrome disponibles:

```sh
firebase emulators:exec --only auth,firestore,storage --project demo-2daopinion "cd ../2daopinion-app && flutter test --platform chrome test/integration/private_document_emulators.dart --reporter expanded"
```

Se verificó el recorrido con SDK Flutter real y datos ficticios. No se creó bucket remoto, no se modificó facturación ni se desplegaron servicios. Antes de habilitar remoto: aprobación de costos/ubicación, IAM de consultas cruzadas Storage–Firestore y prueba aislada de permisos. La alerta USD 10 no corta consumo. [Entrega y limitaciones](../../2daopinion-app/docs/E2-06-ARCHIVOS-PRIVADOS-LOCALES.md).

## Historial remoto

Actualización E2-05 (08/09/2026): `clinicalContext.birthDate` opcional, mapa cerrado de año/mes/día enteros. Fecha real entre 1900 y el día actual UTC, con rechazo de fechas futuras/imposibles. Mantiene compatibilidad con borradores anteriores y límites de 4000 por cadena. 71 pruebas de reglas aprobadas; despliegue exclusivo de reglas Firestore en `segundaopinion-ea0c8`. No se habilita Storage: la selección múltiple de archivos del paciente es solo en memoria. [Entrega de pacientes](../../2daopinion-app/docs/E2-05-CAMPOS-Y-DOCUMENTOS.md).

Esta carpeta es la fuente de reglas e índices Firestore para pacientes y panel. No duplicarlos en el repositorio de pacientes. No contiene secretos ni datos de usuarios.

## Desarrollo

- Proyecto: segundaopinion-ea0c8; base creada: (default), Standard, Native, southamerica-west1 (Santiago), el 08/09/2026 a las 11:43:41 UTC.
- Protección contra borrado habilitada. PITR deshabilitado; no se configuraron backups programados. La API informa freeTier=true: elegibilidad de cuota sin costo, no gratuidad ilimitada.
- Elección autorizada por Ronel el 08/09/2026 para una base de desarrollo compartida entre países. La ubicación no cambia el perfil de pagos ni las tarjetas de la cuenta de facturación existente.
- La configuración regional comercial y los permisos por usuario/caso se implementarán en los modelos y reglas. Una base compartida no concede acceso entre usuarios ni limita la app a Chile.
- Estado inicial de las reglas: denegar toda lectura y escritura desde SDK cliente y REST sujeto a reglas, incluso a usuarios autenticados. El acceso de administración mediante IAM es independiente; estas reglas no revocan permisos de operadores o service accounts.
- No abrir modo de prueba temporal ni una regla general para cualquier usuario autenticado. Antes de habilitar perfiles y consentimientos, implementar y probar únicamente los permisos necesarios.

## Despliegue acotado

Desde la raíz del repositorio, comprobar siempre el proyecto explícito:

```sh
firebase firestore:databases:list --project segundaopinion-ea0c8
firebase deploy --only firestore:rules --project segundaopinion-ea0c8
```

Los índices todavía están vacíos; no desplegarlos sobre índices existentes sin revisar diferencias. No incluir Hosting, Storage ni Functions en un despliegue de reglas Firestore.

## Evidencia de esta entrega

- Creación confirmada por Firebase CLI y listado posterior con ubicación southamerica-west1, tipo FIRESTORE_NATIVE y edición STANDARD.
- Reglas compiladas y publicadas correctamente mediante un despliegue exclusivo firestore:rules.
- Comprobación REST sin autenticación: lectura de documento, listado y escritura de un objeto ficticio denegados con HTTP 403 PERMISSION_DENIED, mensaje «Missing or insufficient permissions». No se guardó el objeto de prueba.
- La denegación a usuarios autenticados se deriva de la regla incondicional false; no se crearon usuarios para probar sesiones autenticadas. Las pruebas detalladas por rol/caso quedan para sus reglas funcionales.

## Costos y producción

La cuenta Blaze existente tiene un presupuesto de alertas USD 10/mes para SegundaOpinion, sin corte automático. Las tarifas dependen del uso y la ubicación; no se afirma gratuidad ilimitada. No activar backups programados o PITR de pago por anticipado.

Producción tendrá un proyecto separado; la ubicación y los requisitos de residencia se revisarán antes de usar datos reales. No copiar datos de desarrollo. La creación de esta base no habilita persistencia funcional en Flutter, que sigue pendiente.

## Flujo de entrega

Ronel autorizó commit y push de cada bloque terminado y verificado. No publicar secretos, datos clínicos, logs, builds ni tareas incompletas como terminadas. La documentación general sigue centralizada en /Users/ronel/Documents/2daOpinion/docs; este registro describe la infraestructura versionada aquí.
