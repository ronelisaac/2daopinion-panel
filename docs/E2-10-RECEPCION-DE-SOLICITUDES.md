# E2-10 · Primer circuito paciente → recepción

8 de septiembre de 2026 · Implementación para Firebase emulado. Activación remota pendiente; no es una entrega completa de casos clínicos.

## Qué incluye

- Paciente autenticado, verificado y con perfil: guardar y revisar su borrador, aceptar una política de envío independiente y confirmar recepción.
- Copia privada e inmutable de la revisión guardada, aceptación versionada y fecha del servidor. Comprobante SO-{id} recuperable al volver a entrar.
- Escritura atómica de copia privada y resumen administrativo; ninguna se puede crear sola. Reintentos recuperan la recepción existente, sin duplicarla ni afirmar éxito antes de confirmación del servidor.
- Panel con adaptador Firestore real: bandeja por país, búsqueda por código completo, filtros, detalle administrativo y paginación por cursor de ocho filas más una de anticipación. Sin recorrer toda la colección, listeners permanentes ni inventar un total.
- Separación de vistas/widgets, controllers, dominio y repositorios. País independiente de idioma y textos localizados.

## Datos y permisos candidatos

| Colección | Identidad y datos | Acceso |
| --- | --- | --- |
| consultationSubmissions/{uid} | id de dominio igual al borrador, propietario, país, revisión, estado received, entorno development, política dev-submission-2026-09-08, aceptación, fecha y copia íntegra del borrador | Propietario verificado con perfil: creación única y lectura individual. Sin edición, borrado ni listado |
| intakeRequests/{id} | Solo id, país, modalidad, fecha, estado y entorno; sin nombre, UID, motivo, diagnóstico ni documentos | Lectura acotada por operaciones de país; propietario puede leer su resumen individual. Sin cambios de estado ni borrado desde clientes |

La copia preserva IDs y valores escalares/mapas exportables; referencias Firebase no entran en el dominio. Se reutiliza uid como clave de almacenamiento de esta primera entrega, no como identidad portable del caso. Una futura migración usa el id de dominio.

Operaciones requiere cuenta con correo verificado y registro canónico panelStaff activo y ready con operations en el país solicitado. Claims antiguos no sustituyen el estado canónico. Superadmin, dirección médica, finanzas y médico no obtienen este permiso por inferencia; no se cambiaron los roles de Ronel. Ni siquiera operaciones puede leer el texto clínico, los borradores o las copias de otros pacientes. Acceso por asignación y verificación profesional corresponde a la siguiente entrega.

Reglas e índices están en firebase/ de este repositorio, **solo candidatos locales**. No desplegar el archivo completo: contiene también candidatos anteriores de archivos/avisos. Los índices requieren comprobación remota al activarse porque el emulador no exige índices compuestos como producción.

## Límites explícitos

- Una recepción por cuenta/borrador en esta fase; nuevas solicitudes y múltiples casos quedan pendientes, no fuera del MVP. Editar el borrador después no modifica la copia recibida.
- Solo texto en esta primera etapa. Una selección de archivos/video bloquea el envío; no se descarta en silencio. Reservas previas de adjuntos bloquean también en servidor, incluso si sus bytes fueron borrados, hasta integrar documentos con casos.
- No hay cobro, consulta contratada, médico asignado, cambio de estado, informe, receta, notificación automática ni revisión clínica. Estado received representa recepción técnica, no admisión médica ni caso pagado.
- La política visible es de pruebas con datos ficticios, independiente del registro/guardado. No se presenta como consentimiento clínico legal definitivo. Antes de uso real resolver textos aprobados, responsabilidades y permisos por caso.
- No se habilitó lectura/escritura nueva en Firebase remoto, no se crearon identidades remotas, no se alteraron IAM ni roles. El login/CRUD remoto existente continúa sin cambios.
- Adaptadores nuevos se inyectan únicamente con USE_FIREBASE_EMULATORS=true en debug y demo-2daopinion. El build normal no permite estos envíos ni conecta la bandeja nueva; no hay datos de ejemplo en el arranque de producto.

## Pruebas y reproducción

Resultado: 144 pruebas Flutter de pacientes, 26 del panel, 120 de reglas Firestore/Storage y dos integraciones web secuenciales aprobadas. Análisis sin incidencias y compilación web correcta en ambos repositorios. La suite de reglas terminó con 120/120; una ejecución sin escalación mostró además una advertencia del comprobador de actualizaciones de Firebase CLI por permisos locales, independiente de las pruebas. El recorrido conjunto final terminó con salida 0.

Reglas: integridad atómica, aceptación, copia exacta, límites heredados del borrador, aislamiento por paciente/país/rol, metadatos sin clínica, baja canónica, consultas acotadas, inmutabilidad, archivos excluidos y concurrencia. Flutter: validaciones, errores, no doble envío, restauración de comprobante y formulario a 320/1440 px. La prueba de navegador ejecuta primero el adaptador de pacientes y luego el de panel contra la misma recepción en Firebase emulado; agrega registros exclusivamente locales para comprobar paginación.

Desde el repositorio del panel, con Node, Firebase CLI, Java compatible, Flutter y Chrome disponibles:

```sh
firebase emulators:exec --only firestore,storage --project demo-2daopinion 'node --test --test-concurrency=1 firebase/test/*.test.mjs'
firebase emulators:exec --only auth,firestore --project demo-2daopinion 'bash scripts/test-reception.sh'
flutter analyze
flutter test
flutter build web
```

Ejecutar también analyze/test/build en pacientes. Los repos deben ser hermanos como en Documents/2daOpinion/repos. FLUTTER_BIN permite indicar el ejecutable en el script. Emuladores nuevos, sin importar datos, porque la prueba conjunta espera exactamente una recepción al iniciar el panel. Las identidades ficticias y su verificación forzada solo existen en emuladores; nunca exportarlas a desarrollo remoto.

Las transacciones web devuelven fallos de negocio como valores y los convierten a excepciones fuera del callback para evitar perder el tipo al cruzar la interoperabilidad JavaScript. Si dos envíos compiten y las reglas rechazan la segunda creación por inmutabilidad, el adaptador recupera el recibo ya confirmado del mismo propietario/id; no flexibiliza reglas ni reescribe la fecha.

## Próxima activación

1. Acordar múltiples casos y traslado de adjuntos antes de declarar completa la solicitud.
2. Definir equipo operativo autorizado y permisos por caso para acceso clínico; no convertir superadmin en lector clínico automático.
3. Preparar y probar un despliegue mínimo de reglas/índices comparado con lo publicado, sin activar candidatos ajenos. Autorizar acceso remoto y política de pruebas antes de inyectar los adaptadores remotos.
4. Probar una recepción ficticia remota con autorización específica y verificar consumo, denegaciones y recuperación.

El dashboard DEV-045 permanece pendiente y no desplaza este circuito.
