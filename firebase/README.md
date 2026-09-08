# Infraestructura Firebase compartida

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
