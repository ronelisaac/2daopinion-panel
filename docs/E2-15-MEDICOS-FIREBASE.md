# E2-15 · Médicos conectados a Firebase de desarrollo

9 de septiembre de 2026. Activación autorizada expresamente por Ronel para reglas y pruebas remotas con identidades ficticias. Sustituye el bloqueo de activación de [E2-14](E2-14-MEDICOS-Y-REVISION.md), cuyo modelo y restricciones funcionales se mantienen.

## Cambio entregado

- El panel normal inyecta `FirebaseDoctorRepository`, conservando vistas/widgets, controller, dominio y repositorio separados. Ya no requiere `ENABLE_DOCTOR_REGISTRY`.
- `scripts/development-rules.mjs` incluye médicos por defecto para evitar cerrarlos accidentalmente en el próximo despliegue. Avisos continúan excluidos. `--exclude-doctors` permite preparar una reversión deliberada; no despliega por sí mismo ni elimina datos.
- Se publicaron exclusivamente Firestore Rules en `segundaopinion-ea0c8`. Sin cambios de Storage, índices, Functions, Hosting, IAM o facturación. El presupuesto de USD 10 continúa siendo una alerta, no un corte garantizado.
- Operaciones CL registra/corrige; Dirección médica CL revisa sin auto-revisión. La habilitación requiere claims y estado canónico de personal vigentes. Ser superadmin no concede estos permisos implícitamente; los roles existentes de Ronel no se modifican.

## Despliegue reproducible

Desde la raíz del panel, después de revisar cambios y ejecutar pruebas:

```sh
node scripts/development-rules.mjs
firebase deploy --only firestore:rules --config firebase.development.json \
  --project segundaopinion-ea0c8 --non-interactive
flutter build web
```

No usar `firebase.json` para publicar todos los candidatos. La compilación web se sirve en la vista previa local del panel; esta entrega no publica Hosting.

## Verificación

| Área | Resultado comprobado |
| --- | --- |
| Flutter | 39 pruebas aprobadas; análisis sin incidencias y build web correcto |
| Reglas | 157 pruebas aprobadas; incluye generación normal y reversión explícita sin médicos |
| Registro remoto | Alta y corrección desde el formulario Flutter con Operaciones ficticio |
| Revisión remota | Dirección médica ficticia independiente aprueba con las tres comprobaciones y fundamento |
| Persistencia | Ambos roles recuperan sesión y registro después de recargar; revisión final 3 |
| Auditoría | Tres eventos inmutables: create, edit, review; snapshot y timestamps finales coinciden |
| Aislamiento | Anónimo/tercero no leen registro ni eventos; país ajeno y consulta sin límite rechazados |
| Mutaciones inválidas | Revisión obsoleta, RNPI de tipo incorrecto, campo desconocido, nota corta, revisor falsificado y cambio sin evento rechazados |
| Roles | Operaciones no decide revisión; revocar estado canónico bloquea al director aun conservando su token |
| Conservación | Borrado de registro/evento y sustitución de evento rechazados a clientes; los intentos fallidos no alteran revisión 3 |
| Avisos | Continúan denegados remotamente |

La integración Flutter emulada de E2-14 ya había comprobado el adaptador. En esta entrega se repitió el recorrido contra Firebase real desde contextos de navegador independientes, sin utilizar la sesión personal ni datos clínicos. La restauración de sesión remota funcionó en ambos roles. La incidencia anterior de recarga en emulador no se reprodujo remotamente; no se cambió autenticación ni se declara corregida aquella incidencia local.

## Evidencia visual y limpieza

Inspección en navegador a 320, 768 y 1440 px: vacío, validación de campos requeridos/comprobaciones, guardado, datos recuperados tras recarga, error por revocación y error al interrumpir la conexión. Capturas ficticias en `docs/desarrollo/evidencia/E2-15` de la carpeta central. La captura de carga se conserva de la validación emulada E2-14; la interrupción de red de E2-15 mostró el error recuperable, no un indicador de carga, y se documenta como tal.

La fuente publicada se comparó con `.firebase/development/firestore.rules`: coincidencia exacta. Al finalizar se eliminaron únicamente las tres cuentas QA, sus dos documentos de personal, el registro ficticio y sus tres eventos, verificando ausencia remota. Archivo temporal de credenciales eliminado; claims de Ronel idénticos antes/después. Sin archivos clínicos ni objetos de Storage creados en estas pruebas. Navegadores de QA cerrados; vista previa habitual conservada.

## Límites y siguiente paso

Solo desarrollo con datos ficticios. No hay integración automática ni certificación RNPI, cuenta médica vinculada, especialidades múltiples estructuradas, revalidación, asignación de casos, acceso clínico, recetas ni perfil público verificado. Los eventos están almacenados, no existe todavía un explorador global de auditoría.

La próxima definición debe cerrar la vinculación de identidad profesional con cuenta médica y la asignación manual por caso, antes de habilitar atención. La autorización de esta entrega no amplía automáticamente esos permisos.
