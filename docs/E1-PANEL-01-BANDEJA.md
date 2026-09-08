# E1-PANEL-01 · Base Flutter y bandeja de solicitudes

8 de septiembre de 2026 · DEV-006/007/009/012 parciales

## Entrega

Aplicación Flutter web independiente, sin API propia ni acceso remoto. Incluye bandeja de 18 solicitudes ficticias, búsqueda por código, filtros de estado, paginación de 8 elementos, detalle de metadatos y mensajes diferenciados de carga, vacío, error y registro no encontrado. Volver del detalle conserva búsqueda y filtros. El cambio de filtro reinicia la página y resultados tardíos no reemplazan una búsqueda más reciente.

Escritorio usa navegación lateral y tabla con desplazamiento horizontal si hace falta. Anchos menores presentan tarjetas. Logo, Montserrat, colores, botones e inputs mantienen el sistema visual de pacientes; footer inferior e información sobre el alcance siempre disponibles.

## Capas y portabilidad

- `domain/`: IDs, país, modalidad, estado, metadatos y contrato de lectura en Dart puro. Listas inmutables.
- `repositories/`: ejemplo en memoria, sin cambios de estado ni escrituras. No existe adaptador Firebase del panel todavía.
- `controllers/`: carga, filtros, paginación, errores y descarte de respuestas obsoletas; sin BuildContext.
- `views/`: composición, navegación y ciclo de vida. Una instancia de controller por pantalla.
- `widgets/`: estructura del panel, aviso de ejemplo, filtros, tabla, tarjetas, indicadores y detalle reutilizables.
- `app.dart`/`main.dart`: inyección y rutas. Idioma español separado de `countryCode` de cada solicitud.

El tema, los widgets responsive, la fuente y el logo son una instantánea de los archivos de pacientes en el commit `8aefa269e753fa4344fa0ade8c857c3a2f18cb4b`. Se incluyen en este repositorio para que pueda compilarse por separado. **No hay sincronización automática entre repositorios**; cambios de diseño requieren mantener ambas copias hasta decidir el paquete común de ADR-003. No se crea una identidad visual nueva.

## Seguridad y límites

La vista previa es pública porque solo contiene datos ficticios incorporados al código, sin nombres, antecedentes clínicos, archivos descargables ni URLs privadas. Cada pantalla muestra «EJEMPLO». No equivale a un portal administrativo autenticado: no hay login, usuarios privilegiados, roles, acceso a cuentas de pacientes, validación documental, asignación médica, mensajes, pagos ni emisión de recetas.

Los estados de ejemplo solo representan una propuesta de bandeja documental, no el ciclo completo de casos ni una confirmación clínica. La receta que aparece en metadatos es un documento de ejemplo aportado por el paciente, no una receta generada. El video es un indicador ficticio, no reproducción ni acceso al video grabado por un paciente.

No se incorpora SDK Firebase al panel ni se modifican reglas compartidas, facturación, Hosting o Storage. `firebase/` sigue siendo la fuente única de reglas; sus candidatos locales no deben desplegarse por inercia. El presupuesto USD 10 es una alerta, no un corte de consumo.

## Comprobación

```sh
flutter pub get
flutter analyze
flutter test
flutter build web
```

11 pruebas Flutter aprobadas: páginas, filtros, IDs, inmutabilidad, concurrencia, limpieza, detalle inexistente, búsqueda/detalle/retorno a 320/768/1440 px, paginación, alcance, texto ampliado y separación de capas. El chequeo de ausencia de conexión remota es una comprobación estática del ejemplo, no una prueba de permisos administrativos. Las reglas no cambian y no se declaran nuevamente desplegadas o verificadas remotamente.

Análisis y build web aprobados. Revisión manual en navegador a 1280×720 y 375×812: bandeja, búsqueda por código, detalle, documentación, indicador de video opcional, desplazamiento hasta el footer y regreso conservando la búsqueda. Tamaño de navegador restaurado. Logo/fuente comparados por hash y tema/responsive por contenido con pacientes; coinciden. Servidor de vista previa exclusivamente local en `http://127.0.0.1:8766/`, separado de pacientes en 8765; solo sirve `build/web`, no la carpeta del repositorio.

## Siguiente bloque

Definir y probar identidad administrativa y permisos mínimos en emuladores; cerrar contrato de envío de solicitud, consentimiento, estados y auditoría antes de conectar paciente y bandeja. Luego validación de completitud/faltantes. No habilitar acceso general a borradores o documentación clínica mediante una cuenta autenticada cualquiera. DEV-012 sigue parcial; esta entrega no recibe solicitudes reales.
