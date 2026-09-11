# 2DAOPINION · PLAN COMPLETO CHILE V1

Versión 1.0 · 11 de septiembre de 2026 · Responsable de producto: Ronel  
Estado: planificación vigente; V1 todavía no operativa en producción.

## 1. Para qué sirve este plan

Esta es la secuencia de trabajo desde la base existente hasta la primera versión operativa en Chile. Incluye los dashboards comprometidos, el producto del paciente, el portal médico, el backoffice, cobros reales, atención, informe, receta, finanzas, seguridad, publicación y operación.

Prevalece como orden actual de ejecución sobre los párrafos históricos de “siguiente paso” del plan v0.40. Conserva los IDs M01–M25, DEV y A del plan anterior: no elimina compromisos ni declara terminados módulos por tener una pantalla o un menú.

“100% operativa” significa que el alcance V1 aprobado funciona de extremo a extremo en producción, con personas responsables, proveedores habilitados, soporte, trazabilidad y pruebas de aceptación. No significa ausencia garantizada de errores ni tener implementado todo el backlog futuro.

No se fija una fecha de lanzamiento sin cerrar equipo, capacidad, proveedores y decisiones externas. Este documento no autoriza por sí mismo nuevos gastos, contratación, cambios de IAM, pagos reales ni apertura de producción.

## 2. Definición de la primera versión

### Incluido

- Lanzamiento Chile; prioridad a médicos independientes, sin exigir clínica.
- Paciente web responsive y app en las plataformas móviles que se ratifiquen; portal médico y administración con experiencia responsive.
- Home y preparación de solicitud sin login; registro/login para identificar al paciente y continuar sin perder el trabajo.
- Autenticación por email y Google; Google está preparado, su activación sigue requiriendo la confirmación pendiente.
- Caso de segunda opinión documental y caso con revisión más consulta por chat/videollamada según lo contratado. Ambos terminan en informe.
- Ficha profesional verificada, vinculación con la cuenta, asignación manual y perfil verificado visible al paciente.
- Documentos privados, correcciones y solicitud de información; video explicativo opcional grabado directamente, hasta 30 segundos.
- Términos de registro y solicitud separados, privacidad/consentimientos, Acerca de, footer, consultas activas, notificaciones, logout y persistencia.
- Precios por especialidad/modalidad/complejidad, cobro Chile real, devoluciones, honorarios, comisión, fees, impuestos configurados, conciliación, liquidaciones y reportes.
- Receta médica dentro del MVP: emisión profesional bajo el alcance y mecanismo aprobados para Chile. No emisión automática ni garantizada para cada caso.
- Dashboard destacado para los cinco roles, con datos reales, animaciones accesibles, gráficos, eventos, pendientes y acciones.
- Superadmin con lectura y escritura administrativa, manteniendo validaciones, auditoría y alcance autorizado.
- Preparación multi-país y gateway internacional USD. M10 exige modelo/configuración; la activación comercial de USD en V1 debe resolverse explícitamente en A03.

### Límites que deben quedar ratificados antes de vender

Especialidades, admisión, edades/representantes, complejidad, documentos mínimos, tiempos, duración de consulta, ventana de aclaraciones, cancelaciones, tipos de receta, destinos móviles y activación USD. Una decisión pendiente no es permiso para quitar esa función del MVP.

No se denominará V1 completa a un piloto exclusivamente web si sigue pendiente el alcance móvil aprobado. Tampoco a una demo de pago sandbox o a una receta PDF sin mecanismo validado.

## 3. Punto de partida real

Estado reconstruido de documentación y repositorios el 11/09/2026. Últimos commits revisados: panel 83f912d y pacientes eb1fb8c. “Dev probado” no equivale a habilitación clínica o productiva. No se realizaron nuevas pruebas funcionales en esta actualización documental.

| Área | Evidencia disponible | Qué falta para V1 |
| --- | --- | --- |
| Flutter, tema, logo, formularios, responsive y capas | Base implementada en ambos productos | Completar recorridos, accesibilidad, dispositivos y pantallas nuevas |
| Paciente: identidad, perfil, términos técnicos y borrador | Entregas de desarrollo documentadas | Aprobación de textos/políticas y regresión integral de acceso invitado, recuperación y sesión |
| Google | Preparado, no activado por decisión de Ronel | Autorizar, configurar y probar |
| Solicitudes y archivos privados | E2-13 probado en Firebase dev | Múltiples casos por paciente, validación confiable de archivos, faltantes/correcciones y acceso clínico por caso |
| Límites actuales de adjuntos | 20 documentos y un video; 50 MiB acumulados; reservas no se liberan al borrar | Ratificar límites comerciales, corregir ciclo de reservas y cuotas por caso; no prometer capacidad ilimitada |
| Video explicativo | Grabación web; Ronel confirmó funcionamiento | Validar duración/contenido de forma confiable y dispositivos reales; adaptadores nativos pendientes |
| Panel: login, usuarios, roles y países | Dev probado; sin registro público de personal | Endurecimiento, recuperación, protección de cuentas y operación productiva |
| Especialidades, clínicas y médicos | CRUD de desarrollo con validación/auditoría | Catálogo real, verificación profesional operativa, vigencia y perfil publicable |
| Cuenta/ficha del médico, administración y disponibilidad | E2-20 a E2-23 | Experiencia de onboarding profesional y cierre de bloqueos reales |
| Clasificación y asignación manual | E2-24/E2-25; ampliadas a Superadmin E2-27 | Aceptación/rechazo, vencimientos, permisos clínicos y conexión a cobro confirmado |
| Dashboards | DEV-045 documentado; Resumen es provisional | Implementación: siguiente bloque de producto |
| Avisos | Centro local documentado; productor remoto pendiente | Eventos y canales reales, preferencias, deduplicación y entrega |
| Pricing, pagos y finanzas | Alcance y menú previstos | No hay evidencia de circuito comercial/financiero operativo; construirlo y probarlo |
| Chat, agenda, videollamada clínica, informe y receta | Comprometidos, no operativos | Implementación, proveedores, autorizaciones y pruebas integrales |
| Hosting/dominio y producción | Backend dev desplegado; vistas locales no son hosting público | Publicar productos, dominio/HTTPS, proyecto productivo y puesta en marcha |

Hay datos y eventos administrativos que permiten comenzar dashboards reales. No existen todavía fuentes para mostrar ingresos, consultas realizadas o recetas emitidas como métricas de negocio.

## 4. Principios que no vamos a volver a discutir en cada bloque

1. Flutter + Firebase ahora: Firestore como base, Auth y Storage; sin API general Node/Laravel. Functions pequeñas y confiables para privilegios, pagos e integraciones cuando sean necesarias.
2. Widgets separados, vistas, controllers, contratos de repositorios y dominio independiente. Firebase concreto queda en adaptadores; textos en i18n.
3. Modelos portables: IDs estables, relaciones explícitas, versiones de esquema, fechas UTC y snapshots de condiciones. Sin URLs permanentes como identidad de documentos ni tipos Firestore en dominio.
4. Locale separado de país. Moneda, pasarela, reglas comerciales, verificaciones, impuestos y zonas horarias configurados por país. No sumar monedas diferentes.
5. Tema y lenguaje visual compartidos por pacientes/panel: logo, colores, Montserrat, botones e inputs ya acordados; no inventar otro diseño.
6. Nada de datos ficticios permanentes, simuladores de usuarios o métricas inventadas. Fixtures solo en pruebas aisladas, rotuladas y eliminadas.
7. Cada sección se termina con Firebase dev, validaciones, permisos, estados visuales, pruebas, evidencia, documentación, commit y push. Despliegue selectivo; no publicar candidatos incompletos.
8. Superadmin administra todos los módulos implementados, pero no omite condiciones de negocio ni se convierte en identidad médica. Las acciones clínicas requieren profesional/caso y trazabilidad.
9. Hosting y archivos reemplazables por separado. No migrar Firestore para cambiar dónde se hospeda la web o se guardan los archivos.
10. Clínica opcional. La cuenta Médico no sustituye su ficha profesional ni genera aprobación automática.

## 5. Secuencia completa y dependencias

CLV1 identifica bloques actuales, no reemplaza los IDs históricos. B0 es un frente paralelo desde ahora; B1 es el siguiente bloque de desarrollo.

| Bloque | Entrega | Dependencia principal | Responsable funcional |
| --- | --- | --- | --- |
| B0 | Decisiones de negocio, clínica, contratos y proveedores | Empieza ahora, en paralelo | Ronel + responsables médico/legal/financiero por designar |
| B1 | Dashboards operativos por rol y país, primera entrega | Fuentes y permisos ya existentes | Producto + tecnología |
| B2 | Cierre de acceso, registro, onboarding e información | Textos y plataformas de B0 | Producto + tecnología |
| B3 | Solicitudes completas, múltiples casos y documentación | Identidad B2; política documental B0 | Operaciones + dirección médica + tecnología |
| B4 | Onboarding profesional y perfil verificado del médico | Catálogo y protocolo B0; CRUD existente | Dirección médica |
| B5 | Admisión, completitud y expediente privado | B3/B4; matriz clínica aprobada | Operaciones + dirección médica |
| B6 | Catálogo comercial, pagos y subregistro financiero | Contratos/gateway B0; admisión B5 | Finanzas + tecnología |
| B7 | Aceptación/rechazo, vencimiento y reasignación | Asignación existente; B4/B5; cobro B6 para uso real | Operaciones + médicos |
| B8 | Chat, agenda y videollamada | B5/B6/B7; proveedor de B0 | Dirección médica + tecnología |
| B9 | Informe y receta médica | B5/B7; definiciones de firma/prescripción B0 | Dirección médica + tecnología |
| B10 | Notificaciones y soporte integrados al circuito | Se incorporan desde B2; cierre con eventos B3–B9/B11 | Operaciones + tecnología |
| B11 | Honorarios, liquidaciones, payouts y conciliación | Subregistro B6; cierre de servicio B9 | Finanzas |
| B12 | Dashboards completos y reportes finales | B1 más fuentes B3–B11 | Responsables de cada rol |
| B13 | Seguridad final, móviles, hosting y producción | Trabajo transversal; cierre con B2–B12 | Tecnología + Ronel |
| B14 | Piloto real controlado y lanzamiento Chile | Todas las puertas de salida cerradas | Ronel + médico + finanzas + operación |

No son quince bloques totalmente secuenciales: proveedores, seguridad, eventos y móviles avanzan en paralelo. Se puede prototipar B7/B9 antes de terminar el gateway con fixtures aislados, pero nunca habilitar atención real sin sus precondiciones. Agenda/informe pueden desarrollarse en frentes separados compartiendo el mismo modelo de caso.

## 6. Detalle de las entregas

### B0 · Cerrar lo que no puede decidir el código

- Definir quién presta, cobra, factura y contrata; contratos con médicos, comprobantes y tratamiento fiscal revisados por los responsables competentes.
- Aprobar catálogo inicial, documentos mínimos, admisión/exclusiones, derivación, complejidad, tiempos de respuesta, ausencia de médico, urgencias y soporte.
- Elegir gateway Chile, política de reembolsos y medio de pago a médicos. Evaluar capacidades reales y costos con fecha; no escoger proveedor por una maqueta.
- Resolver proveedor de video, receta/firma, USD, dominios, hosting/archivos de producción y plataformas móviles.
- Aprobar honorarios, comisiones, impuestos, cancelaciones, inasistencia, plazos de aclaración y liquidación.

Aceptación: decisiones documentadas con responsable, fecha y evidencia; ninguna integración crítica se construye sobre una contratación o capacidad supuesta. Las decisiones abiertas tienen dueño y bloque afectado, no un “lo vemos después” sin seguimiento.

### B1 · Dashboard primero: base visual y operación real

- Encabezado por rol/país, período, última actualización, tarjetas, tendencias, distribuciones, actividad reciente, “Requiere tu atención” y accesos a listados filtrados.
- Componentes reutilizables con animaciones sutiles, skeletons, reducción de movimiento, contraste y alternativa textual a los gráficos. Mobile/tablet/desktop.
- Implementar fuentes de datos autorizadas y acotadas. Por indicador: definición, fórmula, zona horaria, período, filtros y política de actualización. No barrer colecciones completas ni hacer un listener por tarjeta.
- No convertir una página de 20 filas en un “total de médicos”. Usar agregados o consultas de conteo autorizadas; asegurar consistencia y protección de datos también en métricas.
- Si una persona tiene varios roles, la selección cambia la composición, no sus permisos. Superadmin conserva gestión total del alcance autorizado.

| Rol | Primera entrega con fuentes existentes | Ampliación necesaria antes de cerrar V1 |
| --- | --- | --- |
| Superadmin | Solicitudes administrativas, médicos y verificaciones, catálogos, tareas y actividad autorizada | Servicio completo, alertas, finanzas por país/moneda y tendencias fiables |
| Operaciones | Recibidas, por clasificar/asignar, asignaciones pendientes y acciones rápidas | Vencimientos, faltantes, aceptación y agenda operativa |
| Dirección médica | Verificaciones y estados profesionales, distribución por especialidad | Supervisión clínica autorizada, informes/recetas y plazos |
| Médico | Ficha propia, vínculo, estado y disponibilidad | Casos asignados/aceptados, agenda, informe, receta y honorarios propios |
| Finanzas | Composición del rol con estados explícitos de fuentes todavía no habilitadas | Datos reales de cobros, devoluciones, honorarios, payouts y conciliación |

Aceptación B1: dashboard operativo para los indicadores respaldados por fuentes existentes; acciones correctas, consistencia comprobada y costo de consulta documentado. Un panel financiero sin fuentes se identifica como pendiente, no como un módulo finalizado. DEV-045 se cierra por completo recién en B12.

Primeras entregas ejecutables: B1.1 contrato de métricas/permisos y estructura visual; B1.2 indicadores/actividad reales de administración; B1.3 vistas de rol, enlaces, accesibilidad, pruebas y despliegue. Cada incremento muestra datos reales, no un simulador.

### B2 · Acceso y experiencia inicial completos

- Terminar onboarding, home pública y acceso invitado a la solicitud. Al identificarse, retomar el mismo borrador sin duplicarlo ni perder campos.
- Registro/login email, verificación, recuperación, errores seguros, sesión y logout. Activar Google únicamente tras confirmación y probar vinculación/conflictos de cuenta.
- Términos versionados del registro, privacidad, aceptación explícita y trazabilidad; textos aprobados, no borradores legales presentados como definitivos.
- Perfil del paciente con tipos/fechas correctos; política de menores/representantes. Acerca de, contacto/ayuda, footer al final de página y enlaces reales.

Aceptación: invitado → solicitud → registro/login → continuación; recuperar sesión y datos tras recarga, salir y cambiar de cuenta sin mostrar información anterior. Email/Google funcionan en los destinos aprobados. Ningún enlace informativo roto ni alta incompleta tratada como válida.

### B3 · Solicitudes y archivos listos para uso real

- Pasar de una recepción por cuenta a múltiples casos con ID propio, borradores, historial y consultas activas en home. Diseñar migración compatible sin perder el flujo existente.
- Consolidar fecha de nacimiento, motivo/detalle y diagnóstico en textos amplios; síntomas, medicamentos, alergias y preguntas mediante chips con instrucciones y límites. Campos médicos adicionales solo con criterio aprobado.
- Selección de especialidad del catálogo público mínimo o “No sé”; asignar clasificación humana sin inferir un diagnóstico. Proteger los datos administrativos que no deban publicarse.
- Adjuntos múltiples claramente visibles, título, listado, estado/progreso, reintento y reemplazo autorizado. Documentos JPG/JPEG, PNG, DOC, XLS y PDF; no ampliar formatos silenciosamente.
- Video opcional grabado dentro de la app: permisos, detener, revisar, regrabar, cancelar y liberar cámara/micrófono. Probar nativo y navegadores/dispositivos acordados; no hacerlo requisito de envío.
- Validación confiable de tamaño, tipo real, contenido/seguridad y duración de video antes de liberar archivos para uso clínico. Diseñar cuarentena, rechazo y explicación al paciente; no confiar solo en extensión/MIME del cliente.
- Revisar reservas, cuotas, reintentos y limpieza de archivos huérfanos. Ratificar máximo por caso y solicitudes de ampliación; no reservar bytes indefinidamente sin salida.

Aceptación: mismo paciente crea al menos dos casos independientes; no hay mezclas de borradores, archivos o consentimientos. Carga fallida se recupera; archivo inválido no llega al médico. Subida y envío son explícitos, con términos de solicitud separados de registro y acceso ajeno denegado.

### B4 · Médico independiente listo para recibir casos

- Cerrar alta/edición de ficha, especialidades, evidencia RNPI/registro aplicable, vigencia, suspensión y revalidación; la revisión de desarrollo no acredita por sí sola a un médico real.
- Vincular ficha con cuenta creada desde Usuarios; detectar duplicados, bajas y cambios de rol/país. Guiar al administrador para evitar confundir usuario con ficha.
- Perfil mínimo visible al paciente con identidad, especialidad y estado verificado vigentes. No publicar notas de revisión, información privada ni una insignia sin comprobación.
- Confirmar disponibilidad, aceptación de condiciones profesionales, honorarios y datos necesarios para liquidación, con permisos específicos.

Aceptación: un médico real autorizado y revisado puede ingresar, ver su ficha correcta y quedar elegible. Un profesional suspendido/no verificado/no vinculado no recibe nuevos casos. No requiere clínica.

### B5 · Admisión, faltantes y expediente privado

- Bandeja operativa con clasificación, completitud, revisión clínica cuando corresponda, inadmisión y motivo adecuado para el paciente.
- Pedir documentación/información adicional, avisar al paciente, recibirla y devolver el caso a la etapa correcta. Conservar versiones de antecedentes enviados.
- Definir matriz de acceso al expediente por acción y caso: paciente, médico autorizado, operación mínima, dirección médica y acceso excepcional auditado.
- Diseñar accesos temporales a archivos privados, revocación y comportamiento al suspender/reasignar; no URLs públicas permanentes.
- Validar consentimientos y admisibilidad antes de ofrecer atención.

Aceptación: un caso incompleto se corrige de extremo a extremo; el médico ajeno no accede ni con el ID/URL conocido. Reasignación o baja revoca el acceso según la política aprobada. No se confunde validación técnica del archivo con evaluación de suficiencia clínica.

### B6 · Pricing, checkout y dinero trazable desde el primer cobro

- CRUD comercial por país, CLP, especialidad, modalidad y complejidad. Configurar precio, honorario médico, comisión y tratamiento de costos/impuestos aprobado.
- Cotización versionada y con vigencia: inclusiones, plazos, política de cancelación, monto y honorario congelados para ese caso; no modificar lo aceptado cambiando el catálogo.
- Checkout Chile real mediante proveedor aprobado, con secretos fuera de Flutter y confirmación confiable por webhook/consulta al proveedor. El retorno del navegador nunca marca un pago como realizado.
- Manejar rechazo, abandono, demora, duplicado, desorden de eventos, reintento y conciliación posterior. No duplicar cargos ni saldos.
- Registrar desde aquí payments, intentos, gateway IDs, movimientos contables y fees estimados/confirmados. Importes en unidades monetarias mínimas, moneda/exponente definidos, sin aritmética flotante para dinero.
- Subregistro financiero balanceado por moneda con eventos idempotentes; ajustes reversan movimientos, no borran historia. No confundir libro auxiliar con un ERP ni con cumplimiento fiscal ya resuelto.
- Cancelación y devolución total/parcial con motivo, autorización, ejecución y confirmación real; prever devolución antes y después del payout.
- Preparar adaptador local por país y ruta USD. Si A03 activa USD para V1, probarla de extremo a extremo; si se difiere, registrar aprobación y mantenerla deshabilitada de forma explícita.

Aceptación: precios no manipulables desde el cliente; el caso solo cumple su condición de cobro cuando la confirmación confiable existe. Una entrega sandbox cierra desarrollo, no la aceptación de pagos reales, que se comprueba en B14.

### B7 · Asignación aceptada, no solo guardada

- Bandeja privada del médico con propuesta, metadatos mínimos, condiciones/honorario y plazo de respuesta.
- Aceptar o rechazar con motivo adecuado; historial y avisos. La aceptación la emite el profesional, no se simula mediante Superadmin.
- Vencimiento, falta de capacidad, cambios de disponibilidad y reasignación manual. Revalidar cuenta, vínculo, especialidad, revisión profesional y estado administrativo.
- Evitar dos asignaciones activas y decisiones tardías sobre propuestas ya liberadas/vencidas. Probar operaciones concurrentes e idempotencia.
- Conectar los permisos clínicos y requisitos comerciales: consentimiento, admisión, documentación y pago confirmado según política.

Aceptación: asignar → aceptar/rechazar/vencer → reasignar funciona y deja auditoría; nadie puede aceptar una asignación ajena o expirada. Asignar por sí solo no equivale a iniciar atención ni a devengar automáticamente un pago médico.

### B8 · Consulta: chat, agenda y videollamada

- Chat por caso con participantes autorizados, estado de entrega y ventanas de uso; distinguir coordinación administrativa de consulta clínica.
- Propuesta de horarios, reserva, zonas horarias, reprogramación, cancelación e inasistencia; evitar doble reserva.
- Videollamada real con salas/accesos limitados por caso/cita, permisos de cámara/micrófono, espera y reconexión. Probar acceso de terceros y caída del proveedor.
- La modalidad documental no exige videollamada; la modalidad con consulta incluye lo que se vendió, sin terminar el servicio solamente al cerrar la llamada.
- Política de contingencia y soporte. No grabar ni transcribir videollamadas en V1; no confundirlas con el video explicativo que aporta el paciente.

Aceptación: paciente y médico completan una consulta desde dispositivos acordados; un tercero no entra, la agenda permanece consistente y una interrupción tiene una salida operativa definida.

### B9 · Informe y receta médica

- Plantilla de segunda opinión: antecedentes pertinentes, preguntas, valoración y conclusión profesional; borrador guardado, autoría y validaciones.
- Publicación controlada, versión emitida identificada, fecha y mecanismo de firma/validación aprobado. PDF privado y descarga del paciente; adendas/correcciones sin sobrescribir lo emitido.
- Receta vinculada al caso con paciente/profesional inequívocos, campos estructurados de indicación aprobados, borrador, revisión y emisión confiable/idempotente.
- Resolver A18/A22: tipos admitidos, mecanismo de firma/verificación, correcciones, vigencia y relación comercial con la consulta. No habilitar categorías no validadas ni prometer dispensación por crear un PDF.
- Emisión clínica exclusiva de profesional autorizado. Superadmin gestiona el sistema, pero no emite una indicación haciéndose pasar por médico.

Aceptación: el paciente recibe informe auténtico del caso correcto; las correcciones preservan historia. Un profesional habilitado emite y entrega una receta bajo el mecanismo validado para el alcance aprobado. Si A18 no está cerrado, la receta y la V1 completa siguen bloqueadas: no se envía silenciosamente al backlog.

### B10 · Notificaciones, seguimiento y soporte

- Centro in-app real, contador y leído/no leído persistentes; avisos para alta/verificación, faltantes, pago, asignación/respuesta, cita, informe, receta y liquidación.
- Productores de eventos confiables, deduplicación, reintentos y enlaces protegidos; no publicar reglas de avisos sin un productor operativo.
- Email/push por plataformas y canales aprobados en A21; preferencias y contenido mínimo sin diagnósticos ni adjuntos clínicos en la notificación.
- Soporte del paciente y del médico: contactos reales, cola/incidencias, seguimiento de reclamos, pagos fallidos, inasistencia y errores de entrega.

Aceptación: evento → aviso correcto → acceso autorizado; un aviso duplicado no duplica acciones. Una entrega fallida se detecta y se puede reintentar. El centro no muestra fixtures ni estados de éxito inexistentes.

### B11 · Finanzas operativas completas

- Reglas de devengo/elegibilidad del honorario, retenciones o bloqueos aprobados, ajustes y reversos. Diferenciar cobrado, devengado, por pagar y efectivamente pagado.
- Liquidaciones por médico/país/moneda/período, lote, aprobación, ejecución del payout/transferencia y evidencia confirmada. No registrar “pagado” solo porque se inició el envío.
- Conciliar pagos, devoluciones, fees y depósitos del proveedor con banco; identificar diferencias, asignar responsable y registrar resolución.
- Reportes de saldo y movimientos por país, moneda, fecha, médico, especialidad y modalidad; CSV protegido. Fecha de cobro, atención y liquidación diferenciadas.
- Configuración fiscal y proceso de comprobantes aprobados por responsables competentes; integrar o ejecutar el proceso contable definido, sin declarar cumplimiento por exportar un CSV.
- Marketplace/split preparado en los contratos de proveedor y dominio; split automático no es requisito inicial. Un payout manual supervisado puede ser operativo si tiene aprobación, evidencia, conciliación y prevención de duplicados.

Aceptación: reconstruir cada monto desde su origen; no sumar CLP y USD. Casos finalizados, devoluciones y pagos a médicos concuerdan con proveedor/banco. Sin diferencias inexplicadas ni posibilidad de pagar dos veces el mismo honorario.

### B12 · Cerrar los dashboards y reportes de todos los roles

- Completar las vistas de B1 con las fuentes nuevas: aceptación, agenda, atención, documentos publicados y finanzas.
- Gráficos y comparación de períodos equivalentes; filtros por país/moneda, etiquetas de actualización y estados pendientes/error sin convertirlos en cero.
- Tareas priorizadas, eventos navegables, alertas de plazos y métricas de rendimiento del circuito.
- Contrastar cada indicador con su listado y fuente; revisar permiso del agregado y del enlace de detalle. Validar accesibilidad/animaciones sin lecturas extra.

Aceptación: DEV-045 completo para los cinco roles y países autorizados, sin módulos comprometidos simulados. DEV-028/finanzas se implementa una sola vez, compartiendo las fuentes.

### B13 · Endurecimiento, dispositivos y publicación

- Pruebas de seguridad por rol/país/caso, acceso a archivos, revocación, cuentas privilegiadas, sesiones, secretos, abuso/rate limits y registros sin datos clínicos innecesarios.
- Backups, restauración ensayada, retención/borrado aprobados, observabilidad, alertas, incidentes y RPO/RTO ratificados.
- Completar adaptadores nativos y dispositivos reales Android/iOS según A12: archivos, cámara/video explicativo, login Google, permisos, notificaciones y videollamada. Preparar firma, privacidad, cuentas de tiendas y distribución.
- Crear proyecto productivo limpio separado de dev; desplegar configuración/reglas/índices/funciones y catálogos aprobados. No copiar usuarios ficticios, secretos, permisos de QA o expedientes de desarrollo.
- Publicar paciente y panel con dominio propio/HTTPS. Dominio pendiente: no inventar ni comprar sin aprobación. Separar dominios/productos sin depender de rutas locales.
- Elegir hosting y archivos de producción mediante evaluación de seguridad, región, costos, egress, respaldos y operación. Firebase o proveedor alternativo según decisión; no asumir que DigitalOcean u otro será más barato.
- Si se decide migrar archivos/hosting antes del lanzamiento: adaptador privado, comprobación de integridad y permisos, ensayo/rollback y monitoreo. Migración de PostgreSQL/API no entra por ese motivo.
- Plan de gasto de dev y producción, cuotas de producto y respuesta a picos. El objetivo de USD 10 de dev no es una promesa de presupuesto productivo.

Aceptación: ambas webs públicas en sus dominios, builds móviles aprobados disponibles por los canales acordados, restauración y rollback ensayados, controles de seguridad aprobados y ningún secreto/fixture de dev en producción.

### B14 · Piloto real y puesta en marcha Chile

- Congelar alcance/versiones y obtener autorización explícita de producción y de pruebas con dinero real.
- Incorporar profesionales reales revisados, responsables de soporte/finanzas y participantes informados mediante el protocolo aprobado.
- Completar al menos un caso documental y uno con consulta: solicitud → documentación → consentimiento/admisión → cobro → asignación/aceptación → atención → informe → liquidación/conciliación.
- Verificar cobro y abono reales, devolución real autorizada y payout/transferencia real conciliable; usar importes/protocolo aprobados, no los inventa tecnología.
- Probar receta real únicamente cuando el profesional determine que corresponde y esté autorizado por el mecanismo aprobado; no emitir una prescripción innecesaria para completar QA. Acordar con dirección médica evidencia de validación que no fuerce una indicación clínica.
- Ensayar incidentes: no hay médico, rechazo/vencimiento, falta de documentos, fallo de video, pago duplicado/demorado y corrección del informe.
- Cerrar defectos bloqueantes, documentar capacitación/manuales, límites de capacidad y escalamiento. Acordar tamaño/duración del piloto y criterios de salida antes de iniciarlo.

Aceptación: acta de salida de Ronel, dirección médica, finanzas y operación con evidencia del circuito, soporte disponible y monitoreo activo. Solo entonces se anuncia V1 operativa Chile.

## 7. Modelo operativo de estados que debemos cerrar

Propuesta de estados para ratificar en A16; no representa una migración ya ejecutada:

| Dimensión | Estados/circuito |
| --- | --- |
| Caso | Borrador → enviado → recepción/completitud → admitido → listo para contratar → atención → informe emitido → cerrado; ramas faltantes/inadmitido/cancelado |
| Pago | No iniciado → pendiente → confirmado / fallido / vencido; devolución pendiente → parcial/total confirmada |
| Asignación | Sin asignar → propuesta pendiente → aceptada / rechazada / vencida / liberada; nueva propuesta con historial |
| Atención | Pendiente → programada cuando corresponda → en revisión/consulta → informe publicado → aclaraciones/cierre |
| Honorario | No devengado → devengado → elegible/bloqueado → liquidado → envío pendiente → pago confirmado; ajustes/reversos |
| Documentos | Seleccionado/reservado → subido → validación técnica → aceptado/rechazado → vinculado/versionado |
| Receta | Borrador → revisión profesional → emitida; corrección/anulación según mecanismo y política aprobados |

No mezclar estas dimensiones en un único “pagado/finalizado”. Las etiquetas finales, transiciones, plazos y responsables deben aprobarse antes de conectar procesos automáticos.

## 8. Decisiones y bloqueos: registro para cerrar con responsables

La implementación técnica previa no cierra por sí sola una decisión comercial o clínica. Cuando una parte ya se decidió, se conserva y se registra solo lo restante.

| IDs | Falta cerrar | Responsable | Bloque que no puede finalizar sin ello |
| --- | --- | --- | --- |
| A01 | Entidad prestadora/cobradora, contratos y proceso fiscal | Ronel + legal/contador | B4/B6/B11/B14 |
| A02 | Proveedor Chile, capacidades, contrato y credenciales | Finanzas + tecnología | B6 |
| A03 | Gateway USD y activación comercial V1 o diferimiento explícito | Ronel + finanzas | Congelación de alcance B0/B14 |
| A04/A13 | Especialidades, admisión, complejidad y documentos/límites | Dirección médica | B3/B5/B6 |
| A05/A08 | Precios, honorarios, comisiones, devengo y liquidaciones | Ronel + finanzas | B6/B11 |
| A06/A07 | SLA, chat, aclaraciones, cancelación, devolución e inasistencia | Médico + operación + legal | B6/B8/B10 |
| A09 | Video y contingencias | Médico + tecnología | B8 |
| A10/A11 | Privacidad productiva, retención, transferencias, consentimientos y firma | Legal + médico + tecnología | Datos/atención reales B5/B9/B13 |
| A12 | Android/iOS, canales/tiendas y alcance del panel móvil | Ronel | B13 y compromiso de fecha |
| A14/A16 | Verificación vigente, acceso tras reasignación y estados definitivos | Médico + tecnología + finanzas | B4/B5/B7 |
| A15 | Personas responsables, capacidad, presupuesto productivo, soporte y RPO/RTO | Ronel | Calendario y B13/B14 |
| A17 | Google: autorización de activación pendiente; diseño/marca ya definidos | Ronel | Cierre B2 |
| A18/A22 | Alcance y mecanismo de receta; servicio independiente o ligado al caso | Médico + legal + producto | B9/B14 |
| A19/A20 | Textos definitivos, entidad/contactos y aceptación versionada | Legal + médico + Ronel | B2/B3/B6/B13 |
| A21 | Canales de notificación y proveedores | Producto + tecnología | B10/B13 |
| OP-DOM | Dominio disponible, DNS y titularidad | Ronel | B13 |
| OP-INFRA | Proveedor productivo de hosting/archivos; migración antes o después del lanzamiento | Ronel + tecnología + privacidad | B13 |

Una decisión cerrada registra fecha, alternativa, evidencia, aprobador e impacto. No cambiar automáticamente cuentas reales, facturación o proveedores para “desbloquear” una tarea.

## 9. Matriz de cobertura: ningún compromiso desaparece

| Compromiso | Bloques de cierre |
| --- | --- |
| M01 Paciente web/app, portal médico y backoffice | B1/B2/B4/B12/B13/B14 |
| M02 Caso y documentación | B3/B5 |
| M03 Médicos verificados | B4 |
| M04 Asignación manual y perfil visible | B4/B7 |
| M05 Dos modalidades | B6/B8/B9/B14 |
| M06 Agenda y video | B8/B13 |
| M07 Informe | B9 |
| M08 Pricing | B6 |
| M09 Cobro Chile real | B6/B14 |
| M10 USD | A03 en B0; B6/B14 si se activa, configuración incluida siempre |
| M11 Finanzas por país | B6/B11 |
| M12 Reembolsos y conciliación | B6/B11/B14 |
| M13 Liquidaciones y payouts | B11/B14 |
| M14 Reportes | B11/B12 |
| M15 Seguridad y auditoría | Todos los bloques; cierre B13/B14 |
| M16 Regionalización | Todos; comprobación B6/B8/B13 |
| M17 Términos del registro | B2 |
| M18 Términos por solicitud | B3/B6 |
| M19 Acerca de | B2 |
| M20 Consultas activas en home | B3/B10 |
| M21 Footer informativo | B2 |
| M22 Notificaciones/alertas | B10 |
| M23 Logout | B2/B13 |
| M24 Persistencia | Cada bloque; cierre B13/B14 |
| M25 Receta médica | B0/B9/B14; no se elimina del MVP |
| DEV-044 Video grabado en app | B3/B13 |
| DEV-045 Dashboard por rol/país | B1 primero, cierre completo B12 |
| Superadmin lectura/escritura | E2-27 existente; regresión en todos los nuevos módulos |
| CRUD de médicos/especialidades/clínicas | Base existente; B4/B6 y mantenimiento por panel |

## 10. Pruebas y criterio de terminado por entrega

- Alcance y criterios escritos antes de desarrollar; cada tarea tiene ID, responsable, dependencia y evidencia esperada.
- Tipos, requeridos, límites, fechas, dinero y relaciones validados en interfaz/dominio y servidor/reglas. No confiar en teclados o controles visuales.
- Permisos positivos/negativos, país ajeno, cuenta revocada, concurrencia, doble clic/reintentos y eventos duplicados cuando correspondan.
- Persistencia y recuperación tras recarga, cambio de cuenta, red interrumpida y sesión cerrada; sin filtrar datos del usuario anterior.
- Inspección visual móvil/tablet/escritorio: carga, vacío, error y éxito; teclado/accesibilidad y reducción de movimiento.
- Pruebas automatizadas relevantes, análisis y build. Los conteos de tests no se usan como porcentaje de avance.
- Publicación selectiva en Firebase dev y prueba con adaptadores reales; separar backend desplegado de frontend publicado.
- Fixtures aislados eliminados, evidencia sin datos reales, documentación/contexto actualizados y commit/push. No se hace un commit que incluya secretos o builds.
- Una limitación o dependencia pendiente se declara: demo, local, dev probado y producción validada son estados diferentes.

## 11. Puertas de salida para declarar “Chile V1 operativa”

Todas deben estar cerradas; no se sustituyen por un porcentaje aproximado.

- [ ] G1 Alcance aprobado: modalidades, móviles, USD, recetas, catálogo, precios y políticas.
- [ ] G2 Responsables y habilitaciones: profesionales, entidad, contratos, proceso fiscal, privacidad y soporte.
- [ ] G3 Producto paciente completo: invitado/registro, múltiples casos, documentos/video, términos, home y seguimiento.
- [ ] G4 Operación médica: admisión, verificación, asignación/aceptación, expediente privado, consulta, informe y receta en el alcance aprobado.
- [ ] G5 Dinero real: cobro/abono, devolución, honorario, payout y conciliación demostrados, sin diferencias inexplicadas.
- [ ] G6 Dashboards: cinco roles, métricas contrastadas, eventos/acciones, permisos y ninguna cifra ficticia.
- [ ] G7 Notificaciones y soporte: canales aprobados, fallos visibles, reintentos, responsables y procedimientos.
- [ ] G8 Seguridad/continuidad: permisos, monitoreo, restauración, rollback y controles de gasto ensayados.
- [ ] G9 Publicación: dominios/HTTPS, proyecto productivo limpio y destinos móviles aprobados disponibles.
- [ ] G10 Piloto: recorridos documental y consulta completos, incidencias bloqueantes resueltas y acta de salida firmada por responsables.

Defecto bloqueante: exposición de datos, suplantación/permiso indebido, cobro o payout duplicado, monto inconsistente, pérdida de expediente, documento clínico inválidamente emitido o imposibilidad de completar un recorrido contratado. Su existencia impide el lanzamiento.

## 12. Seguimiento sin perder el contexto otra vez

Estados: pendiente, lista, en curso, en revisión, dev probado, bloqueada, producción validada. “Dev probado” nunca marca automáticamente una puerta productiva.

Por tarea: ID CLV1-Bx.nn + DEV/M relacionados, responsable, criterios, dependencias, PR/commit, despliegue y evidencia. Por decisión: ID A/OP, aprobador y fecha. La tarea actual, el siguiente bloque y los bloqueos deben quedar al principio de cada reporte.

Orden inmediato: B0 en paralelo + B1 dashboards. No volver a saltar directamente a aceptación médica omitiendo DEV-045. B2–B5 cierran el recorrido base mientras pagos/proveedores se resuelven; B6–B12 cierran el servicio y dinero; B13/B14 habilitan operación pública.

Antes de cada bloque, revisar cambios del repositorio y estado real de Firebase, no solo el último resumen de conversación. Los documentos históricos conservan evidencia, pero no deciden la prioridad vigente.

No se prometen semanas ficticias: el calendario se construye al estimar tareas pequeñas y ratificar A15. En cada entrega se muestra qué funciona, qué falta y qué decisión concreta bloquea la siguiente.

## 13. Fuera de V1, salvo cambio explícito de alcance

Expansión comercial a otros países; despliegue/base separada por país sin necesidad demostrada; migración a PostgreSQL/API Node/Laravel; ERP completo; conversión automática de monedas; split/marketplace automático; asignación automática; IA diagnóstica; grabación/transcripción de videollamadas; integraciones con historias clínicas de terceros; B2B y operación de clínicas como eje principal.

Hosting/archivos alternativos no están excluidos si se eligen para producción en OP-INFRA. La preparación multi-país y para marketplace sí entra; activar todos los países/proveedores no.

## 14. Costos y fuentes

El proyecto dev tiene documentado un presupuesto de alertas USD 10. No se vuelve a describir esa configuración como un corte global garantizado. La documentación oficial distingue alertas —que no pausan servicios— de límites de gasto para servicios específicos; evaluar disponibilidad/aplicabilidad y riesgos antes de modificar facturación. Un límite parcial no garantiza un techo total de Firestore, Storage y los demás proveedores. Fuente consultada el 11/09/2026: [Firebase: evitar cargos inesperados](https://firebase.google.com/docs/projects/billing/avoid-surprise-bills).

Fuentes internas de alcance y evidencia:

- [Plan maestro histórico](../../../docs/2DAOPINION-MASTER-PLAN.md), edición 0.1; no se presenta el DOCX histórico como actualización de este roadmap.
- [Plan de desarrollo e historial](../../../docs/desarrollo/2DAOPINION-PLAN-DE-DESARROLLO.md).
- [Dashboards DEV-045](PENDIENTE-DASHBOARD-POR-ROL.md).
- [Superadmin E2-27](E2-27-SUPERADMIN-GESTION.md).
- [Asignación E2-25](E2-25-ASIGNACION-MANUAL.md).
- [Paciente/archivos dev E2-13](../../2daopinion-app/docs/E2-13-FIREBASE-DESARROLLO.md).
- [Experiencia y recetas: ampliación del MVP](../../../docs/desarrollo/ALCANCE-001-EXPERIENCIA-Y-RECETAS.md).
- [Política de entregas](../../../docs/operacion/POLITICA-DE-ENTREGAS.md).

### Control de cambios

| Versión | Fecha | Cambio |
| --- | --- | --- |
| 1.0 | 11/09/2026 | Consolidación de principio a fin para Chile; dashboard vuelve al siguiente bloque, base dev diferenciada de producción, cobertura M01–M25 y puertas de salida completas. |
