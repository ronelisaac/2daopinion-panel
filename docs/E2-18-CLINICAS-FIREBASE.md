# E2-18 · CRUD de clínicas en Firebase de desarrollo

9 de septiembre de 2026. Entrega bajo la política vigente de implementar, validar y publicar secciones operativas en `segundaopinion-ea0c8`.

## Alcance

- Menú «Clínicas», listado por país paginado de 20 registros, alta, edición, desactivación y reactivación confirmadas.
- Superadmin administra; Operaciones y Dirección médica consultan. Claims y personal canónico activos/coincidentes obligatorios; CL habilitado en esta etapa. No se amplían roles reales.
- Baja lógica: mantiene identificador y eventos; no elimina registros ni modifica casos o verificaciones existentes.
- Código único por país, normalizado e inmutable, incluso al desactivar. Conflictos de revisión se rechazan sin sobrescribir silenciosamente.
- Cada modificación guarda documento y evento con snapshot, actor, país, acción, revisión y timestamp de servidor en la misma transacción.
- Capas de dominio, repositorio, controller, vistas y widgets separados; tema compartido y textos localizados. No hay API nueva.

## Campos y validación

| Campo | Tipo y límites |
| --- | --- |
| País | Código de la sesión; no editable desde el formulario |
| Código | String requerido, 2–32 caracteres; letra inicial, letras ASCII/números/guion bajo; minúsculas, inmutable |
| Nombre | String requerido, 2–100 puntos de código Unicode |
| Ciudad | String requerido, 2–100 puntos de código Unicode |
| Dirección | String requerido, 5–200 puntos de código Unicode; campo multilínea |
| Correo de contacto | String opcional, hasta 254 caracteres; formato ASCII habitual con dominio y extensión; teclado de correo |
| Teléfono de contacto | String opcional; `+` seguido de 8–15 dígitos, primero distinto de cero; teclado telefónico |
| Descripción | String opcional, hasta 500 puntos de código Unicode; campo multilínea |
| Activa | Booleano, true al crear; cambios posteriores mediante confirmación |
| Revisión, autores y fechas | Entero consecutivo, UID autenticado, timestamps de servidor; creación inmutable |

El dominio normaliza espacios exteriores y las reglas exigen datos ya normalizados. No se certifica que el correo exista, que el teléfono esté asignado o que la dirección sea real; no se envían mensajes ni se hace geocodificación. La unicidad es por código/país, no por nombre o dirección. Una clínica activa en este catálogo no equivale a una institución habilitada, acreditada, conveniada o publicada al paciente.

Persistencia en `clinics/CL_{code}` y `clinics/{id}/events/{revision}`. Identidad estable independiente del nombre; fechas y tipos Firebase se mapean únicamente en el adaptador. Este esquema puede trasladarse a tablas relacionales conservando IDs y referencias.

## Pruebas

68 pruebas Flutter y 238 reglas aprobadas, análisis sin incidencias y build web correcto. Integración del adaptador Flutter real con emuladores aprobada: persistencia, duplicados, revisión obsoleta, baja/reactivación, lectura desde otra cuenta, cuatro eventos y paginación sin solapamiento.

Formulario real contra Firebase remoto: alta, duplicado rechazado, edición, desactivación, reactivación y lectura por Operaciones/Dirección médica. Los tres roles recuperan sesión y datos después de recargar. Auditoría con cuatro eventos `create`, `edit`, `deactivate`, `reactivate`; snapshot final y fecha coinciden con la revisión 4.

Pruebas de seguridad remotas: aislamiento frente a anónimo/tercero; país y límites de consulta; tipos/campos/límites inválidos; ciudad/dirección/contactos incorrectos; autor falsificado; revisión obsoleta; cambio de código; auditoría obligatoria e inmutable; prohibición de borrado y escritura desde roles lectores; revocación canónica con token previo. Los intentos rechazados no cambian la revisión. Avisos incompletos permanecen cerrados.

Inspección en navegador a 320/768/1440 px: vacío, formulario requerido, guardado, duplicado, confirmación, inactivo/reactivado, lectura por rol y recarga. Evidencia ficticia en `docs/desarrollo/evidencia/E2-18` de la carpeta central. Pruebas separadas de la sesión personal, sin expedientes clínicos.

Carga con latencia controlada del navegador y error por revocación canónica comprobados a los tres tamaños. Fuente remota de reglas idéntica al subconjunto generado. Eliminadas las cuatro cuentas QA, tres documentos de personal, clínica ficticia y cuatro eventos, con ausencia remota verificada. Archivo temporal de credenciales eliminado y claims de Ronel sin cambios; navegadores QA cerrados.

## Despliegue

```sh
node scripts/development-rules.mjs
firebase deploy --only firestore:rules --config firebase.development.json \
  --project segundaopinion-ea0c8 --non-interactive
flutter build web
```

Reglas de clínicas publicadas selectivamente; adaptador normal activo. El generador conserva clínicas, especialidades, médicos y recepción. `--exclude-clinics` solo prepara una reversión deliberada. Se comprobó que excluir clínicas produce exactamente el subconjunto publicado antes de esta entrega.

Sin cambios de IAM, roles reales, facturación, índices, Functions o Storage. Frontend actualizado en la vista previa local; esta entrega no publica Hosting ni decide el dominio. USD 10 continúa siendo alerta, no un corte garantizado.

## Siguiente integración

Conectar médicos con especialidades y clínicas mediante IDs estables, preservando la revisión profesional y el historial. No asignar afiliaciones por nombre ni migrar texto libre automáticamente. Pendientes los selectores del paciente con una proyección pública segura, relaciones médico–clínica, jerarquía de sedes/organizaciones, datos fiscales/legales, convenios B2B y acreditación institucional. Estos últimos no se implementan ni se presumen por registrar una clínica.
