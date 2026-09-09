# E2-13 · Recepción y archivos en Firebase de desarrollo

9 de septiembre de 2026. Autorización explícita de Ronel: habilitar el circuito en `segundaopinion-ea0c8`, almacenamiento privado en Santiago, permisos necesarios y pruebas con identidades ficticias temporales, sin modificar sus roles.

## Alcance activado

- Las compilaciones normales de pacientes y panel usan sus adaptadores Firebase de archivos, envío y recepción. Se mantiene la alternativa de emuladores solo en debug y la separación de vistas, controllers, dominio y repositorios. No se crea una API propia.
- Borrador privado → carga explícita de varios documentos → aceptación separada de envío → copia/comprobante inmutable y resumen para operaciones del país. Una recepción por cuenta en esta etapa.
- Operaciones ve código, país, modalidad, fecha, estado y cantidades; nunca texto clínico, nombres, ubicaciones ni bytes de los adjuntos. Las reglas requieren claims y `panelStaff` activo con rol `operations` del país. Ser superadmin no concede este acceso por inferencia.
- Caché persistente de Firestore desactivada en ambas apps; sesión web limitada a la pestaña. El borrador y el comprobante se recuperan desde Firebase, no desde caché clínica local.
- `patientNotices` sigue cerrado remotamente y el repositorio de avisos solo se inyecta en emuladores. No se despliegan Functions, Hosting, pagos ni notificaciones.

## Infraestructura y costos

| Recurso | Configuración de desarrollo |
| --- | --- |
| Proyecto | `segundaopinion-ea0c8` exclusivamente |
| Firestore | `(default)`, `southamerica-west1`; no se crea otra base |
| Bucket predeterminado | `segundaopinion-ea0c8.firebasestorage.app` |
| Ubicación/clase | `SOUTHAMERICA-WEST1`, Standard |
| Privacidad | Uniform bucket-level access y public access prevention `enforced`; sin miembros públicos |
| Versiones/soft delete | Sin versionado; retención soft delete 0 para este entorno ficticio de desarrollo |
| CORS | GET/HEAD desde localhost y 127.0.0.1, puertos 8765 y 8766; no es mecanismo de autorización |
| API habilitada | `firebasestorage.googleapis.com` |
| Permiso entre servicios | `roles/firebaserules.firestoreServiceAgent` para `service-638989286509@gcp-sa-firebasestorage.iam.gserviceaccount.com`, además del rol administrado de agente de Storage |
| Índices | Dos compuestos para `intakeRequests`, verificados READY: país/fecha y país/estado/fecha, con desempate por ID |

No se cambian facturación, tarjetas, roles de Ronel ni PetHostel. No se descargan claves de servicio. El presupuesto de USD 10 es una **alerta, no un tope ni corte garantizado**. Reglas limitan las reservas por cuenta a 20 documentos y un video opcional, 50 MiB combinados; no limitan el gasto global. No se configura borrado automático de archivos por antigüedad. Una política de respaldo/retención clínica de producción requiere una decisión separada.

## Despliegue selectivo reproducible

La fuente única sigue siendo `firebase/firestore.rules`, que también contiene candidatos locales. No desplegar esa fuente completa a desarrollo: incluye avisos todavía no autorizados.

Desde este repositorio, después de revisar cambios y pasar las pruebas:

```sh
node scripts/development-rules.mjs
firebase deploy --only firestore:rules,firestore:indexes,storage \
  --config firebase.development.json \
  --project segundaopinion-ea0c8 --non-interactive
```

El generador escribe `.firebase/development/firestore.rules` (ignorado por Git), excluye únicamente `patientNotices` y falla si cambia la estructura esperada. Ejecutarlo nuevamente antes de cada despliegue; no reutilizar un archivo generado antiguo. `firebase.development.json` solo contiene Firestore y Storage y apunta al bucket exacto. No reemplaza la configuración de emuladores ni autoriza futuros cambios por sí mismo.

Antes de cambios futuros, registrar las versiones desplegadas y comparar fuentes. La activación de E2-13 conserva las reglas anteriores de perfiles y borradores. La versión Firestore previa fue `projects/segundaopinion-ea0c8/rulesets/6c48ec5b-e8b0-4a8a-a9f2-826e759b5a8e`; restaurarla cerraría también el nuevo circuito, no solo una pantalla. No eliminar el bucket como mecanismo de reversión.

## Validación

- 128 pruebas de reglas aprobadas (incluyen exclusión remota de avisos); 26 pruebas Flutter del panel y 151 de pacientes. Análisis y compilación web correctos en ambos repositorios.
- Prueba remota con paciente, tercero y operador CL ficticios: guardar formulario desde navegador, seleccionar dos PDFs a la vez, subir bytes privados y enviar. Nueva sesión/recarga recupera el mismo comprobante y el panel muestra el mismo código con dos documentos vinculados.
- Lectura real de ambos objetos por su propietario; terceros, operador y anónimo rechazados al intentar leer borrador, metadatos o bytes. El operador tampoco accede a la copia clínica ni a consultas de otro país.
- Firebase rechaza texto de más de 4.000 caracteres, tipo numérico donde corresponde texto, fecha imposible y campos desconocidos. Rechaza modificar la copia recibida, borrar sus metadatos y borrar bytes después del envío.
- Revisión visual en Chrome, 320/768/1440 px: comprobante del paciente, listado y detalle del panel, filtro vacío y error. Carga con controles deshabilitados inspeccionada a 768 px. El error se provoca revocando únicamente el estado canónico del operador ficticio; no se amplían permisos reales.
- Evidencia sin contraseñas ni contenido real: `docs/desarrollo/evidencia/E2-13` en la carpeta central del proyecto. No se incluyen credenciales o capturas en estos repositorios.
- Verificación final: reglas remotas idénticas a las fuentes revisadas, ambos índices READY y bucket privado en Santiago. Eliminadas las tres cuentas ficticias, sus registros y los dos objetos de Storage; ausencias verificadas. Eliminado el archivo temporal de credenciales de QA y comprobado que los claims de Ronel permanecen idénticos. Ninguna contraseña de prueba se conserva en el repositorio.

## Límites y siguiente paso

Esta entrega cierra la **activación técnica de desarrollo**, no habilita atención médica ni certifica documentos. El servidor aún no inspecciona malware, firma/formato real, duración real del video ni suficiencia clínica; los conteos representan reservas vinculadas. No hay certificación transaccional de bytes entre Firestore y Storage. La grabación web conserva sus pruebas previas; la prueba remota de esta entrega usa dos PDFs, no cámara/micrófono físicos ni video remoto.

Quedan múltiples solicitudes por paciente, correcciones autorizadas de adjuntos, verificación profesional, asignación médica, revisión confiable, pagos y acceso clínico por caso. Los controles de seguridad de desarrollo no sustituyen App Check, supervisión de costos ni requisitos de producción. Próxima sección recomendada: médicos y verificación profesional, antes de habilitar asignaciones y lecturas clínicas.
