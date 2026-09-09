# DEV-045 · Dashboard por rol y país

8 de septiembre de 2026 · Solicitado por Ronel · Pendiente de implementación.

## Objetivo acordado

Un dashboard visualmente destacado, con animaciones, estadísticas, eventos y acciones útiles, adaptado a cada rol. Mantener logo, colores, tipografía y componentes de 2daOpinion; no crear otra identidad visual. Este registro no implementa pantallas ni habilita nuevos permisos o servicios.

## Composición propuesta por rol

| Rol | Indicadores y contenido | Acciones y eventos |
| --- | --- | --- |
| Superadmin | Resumen de los países autorizados, volumen de solicitudes, estados y tendencias; resumen financiero según permisos y moneda | Pendientes operativos, incidencias, actividad administrativa autorizada y accesos a gestión |
| Operación de país | Solicitudes recibidas, documentación pendiente, casos por asignar y tiempos de atención del país | Revisar antecedentes, solicitar información y asignar; actividad reciente de casos autorizados |
| Dirección médica | Carga por especialidad, verificaciones profesionales pendientes y tiempos de revisión | Revisiones profesionales, alertas de plazos y tareas de supervisión dentro de su alcance |
| Médico | Casos asignados, próximas consultas, informes y recetas pendientes cuando esos módulos estén habilitados | Agenda, seguimiento de sus casos y avisos de nueva documentación; sin acceso a casos ajenos |
| Finanzas de país | Payments, payouts, honorarios pendientes, fees, devoluciones y conciliación, separados por moneda y período | Liquidaciones pendientes, diferencias de conciliación y eventos financieros autorizados; sin detalle clínico |

Las tarjetas concretas, fórmulas y umbrales se definirán al implementar cada módulo con su responsable. No se asume que asignar un rol ya habilita datos clínicos, financieros o emisión de recetas.

## Experiencia visual y funcional

- Encabezado contextual con rol, país, período y fecha de última actualización.
- Tarjetas de indicadores, gráficos de tendencia y distribución, comparaciones entre períodos equivalentes y accesos a listados filtrados.
- Agenda de próximos eventos y lista cronológica de actividad reciente: consultas programadas, cambios de estado, documentos recibidos o liquidaciones, según permisos. No implica sincronización con calendarios externos ni un sistema genérico de eventos.
- Bloque «Requiere tu atención» con tareas priorizadas y accesos rápidos; no solo gráficos decorativos.
- Animaciones sutiles de entrada, transiciones, gráficos y respuesta a acciones. Respetar reducción de movimiento y evitar efectos que distraigan del trabajo.
- Diseño responsive en móvil, tablet y escritorio; teclado, contraste, etiquetas accesibles y alternativa textual para gráficos. El color no será la única señal de estado.
- Estados explícitos de carga, vacío, error, falta de permiso y módulo todavía no disponible. Nunca presentar estadísticas inventadas, ceros por errores o datos de ejemplo como resultados reales.

## Seguridad, arquitectura y consumo

- Separar widgets, vistas, controllers, contratos de dominio y repositorios. Textos en localización; país y locale independientes.
- Seleccionar el rol activo cuando una persona tenga varios, sin cambiar sus permisos. La selección solo cambia la composición de la vista. Validar alcance en servidor/reglas también para agregados, eventos y enlaces de detalle.
- Filtrar por países autorizados; ninguna comparación global ni agregado puede exponer territorios fuera del alcance de la persona. No sumar monedas distintas.
- Mostrar actividad mínima necesaria, sin diagnósticos, documentos ni información clínica en resúmenes administrativos o financieros no autorizados.
- Consultas acotadas, paginación de eventos y estrategia de agregados/caché a definir; evitar listeners sin límite, recorridos completos de colecciones y refrescos continuos por tarjeta. Animaciones locales no deben provocar lecturas adicionales.
- Definir fuente, fórmula, período, zona horaria, filtros y actualización de cada indicador. Un evento de actividad no reemplaza el registro de auditoría.
- Cualquier productor de agregados, índice o función adicional requiere diseño, pruebas y despliegue explícito; este pendiente no autoriza nuevos recursos ni costos.

## Secuencia y aceptación

1. Mantener el siguiente bloque acordado: envío de solicitud y recepción real en el panel.
2. Incorporar dashboard operativo por rol cuando existan casos/eventos y permisos comprobables, con componentes visuales reutilizables desde la primera versión.
3. Completar agenda, supervisión y estadísticas financieras a medida que sus módulos estén operativos; enlazar finanzas con DEV-028, sin duplicar su implementación.
4. Ajustar animaciones y rendimiento con datos reales de desarrollo, no mediante un nuevo simulador de usuarios o estadísticas.

Terminado cuando las vistas se adapten a los cinco roles y al país autorizado, los indicadores coincidan con sus fuentes, los enlaces respeten permisos y pasen pruebas de aislamiento, roles múltiples, monedas, estados de error/vacío, tamaños de pantalla y reducción de movimiento. Documentar lecturas y límites de consulta antes del despliegue. Entregas incrementales verificadas con commit y push.
