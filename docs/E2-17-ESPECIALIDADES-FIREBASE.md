# E2-17 · Especialidades operativas en Firebase de desarrollo

9 de septiembre de 2026. Activación bajo la nueva autorización de Ronel para entregar cada sección probada y publicada en desarrollo. Sustituye el bloqueo de E2-16; su contrato de datos y separación de capas se mantienen.

## Entrega

- Firestore Rules de `specialties` y auditoría publicadas exclusivamente en `segundaopinion-ea0c8`.
- Panel normal usa `FirebaseSpecialtyRepository`; no requiere `ENABLE_SPECIALTY_CATALOG`.
- Generador incluye especialidades por defecto y conserva médicos y recepción/adjuntos. Avisos siguen excluidos. `--exclude-specialties` queda solo como reversión deliberada, sin eliminar datos.
- Superadmin administra dentro de su país; Operaciones y Dirección médica consultan. Claims y personal canónico activos/coincidentes obligatorios. No se modifican roles asignados a usuarios reales.
- Alta, corrección, desactivación y reactivación auditadas. Código estable único por país, sin borrado físico desde clientes.

## Verificación

53 pruebas Flutter y 190 de reglas aprobadas; análisis sin incidencias y build web correcto. La integración emulada del adaptador ya había comprobado también conflictos y paginación en E2-16.

Recorrido contra Firebase remoto desde contextos de navegador separados: superadmin ficticio crea, intenta duplicado, edita, desactiva y reactiva. Operaciones y Dirección médica ficticios ven el mismo registro sin controles de escritura. Los tres recuperan sesión y datos al recargar. Cuatro revisiones y eventos `create`, `edit`, `deactivate`, `reactivate`; snapshot y timestamp final coinciden con el documento.

Pruebas remotas rechazan anónimo/tercero, país ajeno, consultas sin límite y páginas excesivas, borrado de registro/eventos, alteración de auditoría, revisión obsoleta, código de tipo incorrecto o cambiado, nombre vacío/excesivo, descripción excesiva, tipo de estado incorrecto, campos desconocidos, autor falso y escritura sin evento atómico. Los lectores no pueden editar ni desactivar. Revocar al superadmin ficticio en el estado canónico bloquea la lectura aun con su token previo. Los intentos inválidos dejan intacta la revisión 4; avisos permanecen denegados.

Inspección visual a 320/768/1440 px de formulario, vacío, validación, duplicado, confirmación, éxito, estados activo/inactivo, lectura por rol y datos recuperados. Evidencia ficticia en `docs/desarrollo/evidencia/E2-17` de la carpeta central, separada de los emuladores E2-16.

Carga comprobada con latencia controlada del navegador y error de permisos tras revocar al superadmin ficticio, también a los tres tamaños. La fuente publicada coincide exactamente con el subconjunto generado. Eliminadas y verificadas ausentes las cuatro cuentas QA, tres documentos de personal, especialidad ficticia y cuatro eventos. Credenciales temporales eliminadas; claims de Ronel idénticos antes y después. Contextos de navegador QA cerrados, sin alterar su sesión personal.

## Publicación reproducible

```sh
node scripts/development-rules.mjs
firebase deploy --only firestore:rules --config firebase.development.json \
  --project segundaopinion-ea0c8 --non-interactive
flutter build web
```

La vista previa habitual del panel sirve el nuevo build; no se publica un sitio de Hosting ni se resuelve el dominio en esta entrega. No hubo cambios de IAM, facturación, índices, Functions o Storage. USD 10 sigue siendo alerta, no corte de gasto.

## Límites

Catálogo administrativo de desarrollo con datos ficticios, no oferta médica publicada. Pendientes: selectores por ID en médicos/solicitudes, mapeo revisado del texto anterior, proyección pública segura para pacientes y CRUD de clínicas. No hay migración automática, habilitación clínica ni cambios en verificaciones profesionales. Los eventos se guardan; el explorador global de auditoría no está implementado todavía.

La política de entregas operativas está en `docs/operacion/POLITICA-DE-ENTREGAS.md` de la carpeta central y referenciada por las instrucciones de ambos repositorios. No se volverá a pedir confirmación rutinaria para publicar secciones verificadas dentro de ese alcance.
