# Convenciones de 2daOpinion Panel

- Flutter y Firebase directo, sin API propia en el MVP.
- E1-PANEL-01: base Flutter web y bandeja de ejemplo, sin SDK Firebase ni acceso administrativo real. Ver docs/E1-PANEL-01-BANDEJA.md. Tema/logo/fuentes son una instantánea de pacientes, no se sincronizan automáticamente. No convertir ejemplos en accesos remotos sin implementar y probar roles/casos.
- E2-08: reglas patientNotices candidatas y probadas solo localmente. Clientes leen sus avisos y cambian únicamente readAt; no crean ni borran. Productor e IAM pendientes; no desplegar por inercia ni activar push/email.
- E2-06: firebase/storage.rules y los permisos draftAttachments de Firestore son candidatos probados solo en emuladores. No están desplegados; no publicar las reglas locales completas por inercia. No crear buckets ni activar carga remota sin confirmar costos, IAM y prueba de aislamiento remota. La cuota de reservas es acumulativa y no se libera al borrar bytes.
- E2-07 amplía el candidato local: 20 documentos JPG/JPEG/PNG/DOC/XLS/PDF y una reserva de video opcional MP4/MOV (duración declarada hasta 30 s), 50 MiB combinados. Las reglas no inspeccionan contenido ni duración real; no habilitar uso clínico sin validación confiable.
- Alcance vigente: docs/desarrollo/ALCANCE-001-EXPERIENCIA-Y-RECETAS.md en la raíz de 2daOpinion. Incluye términos separados de registro/solicitud, Acerca de, home con casos activos, footer, notificaciones, logout, persistencia y receta médica en MVP. No volver a excluir recetas; no habilitar emisión real sin resolver requisitos A18. Son compromisos, no funciones ya implementadas.
- Archivos y hosting deben ser reemplazables por separado: Firebase en MVP/dev; proveedor de producción pendiente. Al implementar archivos, usar contrato de dominio y adaptador inyectado, documentId estable y ubicación física separada; nunca URLs públicas permanentes como identidad ni secretos en Flutter. Ver docs/arquitectura/ADR-004-ARCHIVOS-Y-HOSTING-PORTABLES.md en la raíz de 2daOpinion. No anticipar otra API ni migrar Firestore por este motivo.
- Usar el mismo sistema visual de la app de pacientes: logo, colores, tipografía, botones, inputs y widgets reutilizables; adaptar la composición a administración sin crear otra identidad. Mantener diseño responsivo. Decisión central: docs/arquitectura/ADR-003-DISENO-COMPARTIDO.md en la raíz de 2daOpinion.
- Vistas y widgets en archivos separados; controllers para casos de uso; contratos y entidades en dominio Dart puro; implementaciones en repositorios.
- No llamar Firebase ni repositorios concretos desde vistas o widgets.
- Controllers reciben contratos por constructor y no reciben BuildContext.
- No usar tipos de Firestore en dominio; mapear IDs y fechas en el adaptador.
- País y locale separados. Todo texto visible debe salir de localización.
- Reglas e índices Firestore compartidos tienen fuente única en firebase/ de este repositorio, desplegados mediante firebase.json. No duplicar en pacientes. Functions y modelos compartidos se organizarán al implementarlos.
- Ronel autorizó commit y push de cada entrega terminada y verificada. No incluir secretos, logs, datos clínicos, builds ni cambios ajenos. El despliegue debe limitarse al servicio y ambiente autorizado.
- No crear acceso administrativo, desplegar ni cambiar facturación sin resolver permisos y requisitos del proyecto.
- Pruebas de capas, controllers, widgets y denegación de permisos antes de dar por terminada una entrega.
