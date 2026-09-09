# E2-14 · Registro de médicos y revisión profesional

9 de septiembre de 2026. **Entrega parcial: implementación y pruebas locales; activación remota pendiente de la confirmación solicitada a Ronel.** No se considera cerrada la sección conectada hasta publicar las reglas autorizadas y repetir la verificación en Firebase de desarrollo con cuentas ficticias temporales.

## Alcance implementado

- Módulo «Médicos y verificación» con listado por país, páginas de 20 registros, alta y corrección de antecedentes, revisión manual y estados persistidos.
- Operaciones CL registra antecedentes; Dirección médica CL revisa. Claims y `panelStaff` canónico deben coincidir y estar activos. No se cambian los roles existentes ni se da acceso al superadmin, finanzas, pacientes o médicos por inferencia.
- La persona que creó el registro no puede aprobarlo, incluso si tiene ambos roles. El revisor documenta evidencia, fundamento e identidad/título/especialidad contrastados.
- Estados: pendiente → aprobada o requiere corrección; aprobada → suspendida; suspendida → aprobada o requiere corrección. Operaciones puede corregir un pendiente/rechazado y reiniciar la revisión, conservando el evento histórico. No puede cambiar antecedentes ya aprobados ni borrar registros/eventos.
- Cada cambio escribe el registro y un evento inmutable con snapshot, actor, país, acción, revisión y timestamp de servidor en la misma transacción. No basta escribir el estado sin auditoría. Conflictos entre pestañas y duplicados se muestran sin sobrescribir silenciosamente.
- No crea usuarios Auth, no vincula todavía cuentas de médicos, no asigna casos, no entrega acceso clínico ni publica un distintivo de verificación al paciente. Tampoco sustituye el futuro módulo global de auditoría: esta entrega almacena los eventos y muestra la última revisión, no un explorador completo del historial.

## Formularios y datos

| Campo | Tipo y validación |
| --- | --- |
| Nombre completo | String normalizado, requerido, 3–120 caracteres |
| Número de inscripción RNPI | String numérico de 1–10 dígitos, sin ceros iniciales; no es el RUT; inmutable |
| Especialidad principal | String declarado, requerido, 2–120 caracteres; no implica certificación |
| Resultado de revisión | Enum y transiciones permitidas; no admite estados arbitrarios |
| Referencia consultada | String requerido, 3–200 caracteres; solo referencia ficticia, no archivo ni datos de pacientes |
| Fundamento | Textarea requerido, 10–2.000 caracteres |
| Comprobaciones | Tres booleanos; todos verdaderos para aprobar |
| Autor/fechas/revisión | UID actual, timestamps de servidor, entero consecutivo; no editables desde el formulario |

Las validaciones se repiten en dominio/controller y reglas. El teclado numérico no es la única protección. Etiquetas requeridas y errores multilínea adaptados a móviles. El número RNPI tiene un límite de captura interno de esta etapa, no una afirmación sobre todos los identificadores que puedan existir en el registro oficial.

Modelo `doctorRecords/CL_{numero}`: identidad estable única por país/número, sin `DocumentReference` en dominio; campos planos y revisión separada como valor. Auditoría en `doctorRecords/{id}/events/{revision}`. Una migración futura puede separar profesional, habilitación nacional y eventos en tablas sin trasladar dependencias Flutter/Firebase al dominio. El registro RNPI equivocado no se cambia silenciosamente: corrección de identidad requiere un procedimiento futuro supervisado.

## Revisión profesional: alcance real

La [Superintendencia de Salud](https://www.superdesalud.gob.cl/tramites/registro-nacional-de-prestadores-individuales-de-salud/) informa los antecedentes profesionales y las especialidades/subespecialidades certificadas disponibles en el RNPI. Se muestra la fuente [RNPI oficial](https://rnpi.superdesalud.gob.cl/) para consulta humana; no se implementa scraping ni se afirma una integración automática.

Solo contenido ficticio en desarrollo. «Revisión aprobada · Desarrollo» es una decisión interna de prueba, no una certificación oficial ni autorización de atención. Antes del uso clínico faltan evidencia verificable, vinculación de identidad con la cuenta, especialidades múltiples estructuradas, vigencias/revalidación, documentos de respaldo y definición del proceso de publicación del perfil.

## Activación controlada

- El adaptador real existe, pero `main.dart` solo lo inyecta en emuladores o con `ENABLE_DOCTOR_REGISTRY=true`.
- Las reglas canónicas contienen el candidato. El generador de desarrollo **excluye médicos y avisos por defecto**, manteniendo el circuito E2-13. No habilitarlo remotamente por inercia.
- Tras autorización, revisar el diff generado, ejecutar las pruebas y preparar con `node scripts/development-rules.mjs --include-doctors`. Desplegar exclusivamente `firestore:rules` con `firebase.development.json` y proyecto explícito `segundaopinion-ea0c8`; no necesita nuevas Functions, buckets, IAM, facturación ni reglas de Storage.
- Compilar el panel con `--dart-define=ENABLE_DOCTOR_REGISTRY=true` solo después de verificar reglas y acceso por país. No publicar una versión que invite a operar sobre permisos todavía cerrados.
- Probar remoto con Operaciones, Dirección médica y tercero ficticios: registro → corrección → revisión independiente → nueva sesión; revisar tres eventos, permisos, revocación, duplicados y conflictos. Limpiar únicamente esas identidades y registros al finalizar y comprobar los roles de Ronel sin cambios.
- Al activar, actualizar este documento y la política del generador para no excluir médicos en un despliegue posterior. No habilitar avisos junto con médicos.

## Reproducción local

```sh
npm run test:rules
flutter test
flutter analyze
firebase emulators:exec --only auth,firestore --project demo-2daopinion \
  'flutter test --platform chrome test/integration/doctors_emulators.dart --reporter expanded'
flutter build web --debug --dart-define=USE_FIREBASE_EMULATORS=true
```

El test web usa únicamente endpoints localhost del proyecto `demo-2daopinion`. Verifica persistencia real del adaptador, duplicados, revisión obsoleta, cambio de cuenta, aprobación por otro revisor y tres eventos de auditoría. Los datos del navegador de prueba son ficticios y están aislados de la sesión personal.

Pruebas: 39 Flutter, 157 reglas y una integración web aprobadas, incluida la prueba que mantiene médicos cerrado por defecto hasta autorización. Análisis y compilaciones verificados. Inspección visual a 320/768/1440 px con evidencia local en `docs/desarrollo/evidencia/E2-14` de la carpeta central. No equivale a prueba remota. La aprobación para desplegar y crear cuentas temporales remotas sigue pendiente; no se modificó el proyecto Firebase real ni el presupuesto de USD 10. Comparación de fuentes confirma que el subconjunto generado por defecto es idéntico al de E2-13. Navegador y servicios temporales de QA cerrados, sin exportar sus cuentas ficticias.

La restauración automática de sesión después de recargar el navegador emulado no se da por validada: en ese recorrido apareció nuevamente el login y un error genérico. Se comprobó persistencia del registro con lectura de servidor y cambio de cuenta en la integración, y revisión visual en sesiones independientes. No se cambió el módulo de autenticación por inferencia ni se atribuye este comportamiento a producción; debe investigarse antes del cierre integral del recorrido remoto.
