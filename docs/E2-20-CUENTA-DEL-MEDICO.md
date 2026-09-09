# E2-20 · Cuenta del médico independiente

9 de septiembre de 2026 · Publicado en Firebase de desarrollo.

## Recorrido operativo

En Usuarios, un superadmin puede vincular una cuenta activa que ya tenga rol Médico en Chile. Introduce el RNPI, consulta la ficha y confirma explícitamente nombre, especialidad y cuenta. La ficha debe estar aprobada en desarrollo, tener schemaVersion 2 y especialidad activa del mismo país. No se exige clínica ni se infiere identidad por coincidencia de nombre/correo.

La creación e invitación de cuentas siguen en el CRUD existente. Vincular no crea otra identidad, no envía invitaciones, no cambia contraseñas, claims ni roles. No concede atención, recetas ni acceso a pacientes: una relación administrativa no es un permiso por caso.

La tarjeta muestra el identificador vinculado; se conserva al recargar. Desvincular exige confirmación y conserva cuenta, ficha, revisión profesional e historial. Cambiar la asociación requiere desvincular antes, no sobrescribir.

## Capas y datos

- Widget DoctorAccountEditor y vista de Usuarios separados; controller recibe el contrato de repositorio.
- DoctorAccountPreview es Dart puro. Adaptador llama la función privada existente, no una nueva API general.
- panelStaff/{uid}.doctorLinks: mapa país → doctorId. Compatible con cuentas antiguas sin el campo.
- doctorAccountLinks/{doctorId}: vínculo inverso único con uid, countryCode, actor y fecha de servidor.
- Un vínculo por cuenta/país y uno por ficha; referencias estables, no nombres como claves.
- Vinculación y desvinculación son atómicas junto al incremento de revisión del personal y auditoría en panelUserOperations.
- La ficha médica no se modifica al vincular; su revisión se comprueba para rechazar una aprobación previa obsoleta.

## Seguridad y validaciones

Acciones doctorPreview, linkDoctor y unlinkDoctor dentro de managePanelUsers. País CL, RNPI string requerido de 1–10 dígitos sin cero inicial, UID validado, revisiones enteras positivas y requestId de 32 caracteres hexadecimales. Campos adicionales rechazados; límite de payload existente de 4096 bytes.

Actor autenticado y verificado, habilitado en Auth y estado canónico, superadmin de todos los países del usuario objetivo. No se permite cambiar la cuenta propia o protegida. La vista previa devuelve solo nombre, especialidad, RNPI, ID y revisión; no documentos clínicos ni evidencia de revisión. No se abre doctorRecords al cliente superadmin.

La cuenta objetivo debe estar lista, activa y tener rol Médico para vincular; Auth no deshabilitado y correo coincidente con su registro. La comprobación de correo verificado para entrar sigue siendo responsabilidad del login; vincular no marca el correo como verificado.

Transacción vuelve a comprobar actor, estado del personal, revisión de ficha, especialidad y exclusividad. Reintentar una escritura incierta conserva requestId; un mismo identificador no puede cambiar intención. Reutiliza bloqueo y cupo existente de 100 mutaciones diarias del CRUD, que no equivale a un límite monetario.

No puede retirarse el rol Médico ni su país mientras exista vínculo: primero se desvincula. Desactivar acceso conserva la relación y permite desvincular sin reactivar. Una suspensión profesional no borra vínculos; los futuros accesos por caso deberán comprobar tanto estado profesional como cuenta y asignación, nunca solo doctorLinks.

El cliente no puede leer ni escribir directamente doctorAccountLinks, panelStaff o panelUserOperations: continúan cerrados por las reglas existentes. Desvincular elimina el índice inverso activo, no la auditoría.

## Verificación y despliegue

- 75 pruebas Flutter: incluye RNPI requerido/tipo, búsqueda y confirmación explícita, ausencia de mutación en la vista previa, revisión optimista, reintento y mensajes de error Firebase con sufijo HTTP.
- 21 pruebas de Functions en emuladores: registro de usuarios y nueva vinculación, unicidad, historial, permisos, países, fichas no elegibles, referencias inactivas, Auth deshabilitado, revocación y protección de roles.
- Una integración Flutter → callable real emulada conserva listado, alta, edición, baja y denegación sin sesión.
- Análisis sin incidencias y build web normal correcto.
- QA remoto con cuentas ficticias: búsqueda, vínculo, recuperación tras recarga y desvinculación desde los formularios reales a 320/768/1440 px; prueba adicional de idempotencia y errores de permisos/tipos/revisiones.
- Prueba remota de denegación de lectura/escritura directa del vínculo para todos los roles, anónimo y externo. Configuración remota de la función contrastada: Node 22, Santiago, mínimo 0/máximo 1 instancia, concurrencia 1 y 256 MiB, misma identidad de servicio.
- Publicada exclusivamente functions:panel-users:managePanelUsers. Sin nuevos servicios, IAM, reglas, índices, Storage o Hosting. El panel local usa el build actualizado.
- Limpieza final comprobada: cinco identidades QA, cuatro documentos de personal, dos fixtures con sus eventos y quince operaciones ficticias eliminadas. Vínculo inverso ausente; roles del médico ficticio y de la cuenta real sin cambios, credenciales temporales eliminadas. No se reinició la cuota ni el control compartido.

Evidencia visual central: docs/desarrollo/evidencia/E2-20. Formularios capturados sin datos reales de fondo; lista con datos del usuario real ocultos. Las pruebas no certifican profesionales ni habilitan uso clínico.

## Siguiente

Completar estado administrativo/disponibilidad del médico y su vista de trabajo. Después, asignación manual con autorización explícita por caso. No convertir el vínculo de cuenta en acceso a expedientes sin ese paso.
