# Módulo de proyectos en Roble

Todo el módulo de proyectos (proyectos, borradores, audiencia, roles, tareas,
solicitudes, decisiones, miembros, comentarios, seguimientos y
notificaciones) se lee y escribe en Roble con el SDK oficial `roble`,
reutilizando el mismo cliente y la misma sesión del login. No hay fuente
local en producción (`LocalSharedProjectsSource` fue eliminada).

La app usa **exactamente** las tablas que ya existen en el proyecto
`movil_flutter_dcaabc5f4e` (no hay que crear nada más):

| Tabla | Columnas que usa la app |
|---|---|
| `projects` | name, description, categories, canApply, teamRoles, acceptedRoleCounts, duration, audience, isDraft, acceptedMembersCount, createdBy, createdByName |
| `project_tasks` | projectId, title, description, requiredCount, acceptedCount |
| `project_requests` | projectId, type, taskId, teamRoleId, role, message, applicantUserId, applicantName, applicantEmail, status, createdAt, updatedAt |
| `request_decisions` | requestId, status, decidedAt |
| `project_members` | projectId, userId, name, email, role, joinedAt, sourceType, sourceId |
| `project_comments` | projectId, authorUserId, authorName, text, createdAt |
| `project_follows` | projectId, userId, createdAt |
| `app_notifications` | recipientUserId, projectId, requestId, type, title, message, read, createdAt |

Además, en todas se usa `_id` y `_owner` (los pone Roble).

## Cómo funciona

- **Roles del equipo**: viven en la fila del proyecto. `teamRoles` =
  `{"Diseñador/a": 2}` (personas necesarias) y `acceptedRoleCounts` =
  `{"Diseñador/a": 1}` (ya aceptadas). En `project_requests`, `teamRoleId`
  guarda el nombre del rol.
- **Tareas específicas**: filas de `project_tasks` (`requiredCount` /
  `acceptedCount`). Se definen en "Equipo necesario → Tareas específicas".
- **Audiencia**: "Solo yo" guarda de inmediato `isDraft = true`; "Toda la
  comunidad" guarda `isDraft = false`. Siempre la misma fila.
- **Explorar**: `isDraft = false` y `audience = "Toda la comunidad"`.
  **Mis proyectos / Mis borradores**: `_owner` = usuario actual.
- **Solicitudes**: la fila de `project_requests` es del solicitante, por eso
  su `status` queda en `pending`. La decisión del dueño se guarda en
  `request_decisions` y solo cuenta si su `_owner` es el creador del
  proyecto. Aceptar = decisión + contador de la tarea o del rol + fila en
  `project_members` + `acceptedMembersCount` + notificación.
- **Autoría**: creador, autor de comentario, quién sigue y quién decidió se
  leen de `_owner`, que Roble pone con el usuario del token y no se puede
  falsificar desde la app.

## Configuración en la consola (obligatoria)

### 1. Propiedad de las filas (icono de escudo de cada tabla)

En **todas** las tablas: activa **"La aplicación ve de quién es cada fila"**
(sin esto la app no sabe quién creó cada fila) y deja **"Leer sólo lo
propio" apagado**.

| Tabla | Eliminar sólo lo propio | Actualizar sólo lo propio |
|---|---|---|
| `projects` | ✅ | ✅ |
| `project_tasks` | ✅ | ✅ |
| `project_requests` | ✅ | ✅ |
| `request_decisions` | ✅ | ✅ |
| `project_members` | ✅ | ✅ |
| `project_comments` | ✅ | ✅ |
| `project_follows` | ✅ | ✅ |
| `app_notifications` | ✅ | ❌ **apagado** |

`app_notifications` va con "Actualizar sólo lo propio" apagado porque la
fila la crea quien envía el aviso, pero quien la marca como leída es el
destinatario.

### 2. Permisos del rol `user` (Configuración → Permisos)

`user` (el rol de quien se registra) trae de fábrica solo crear y leer. Dale
además:

- **Actualizar**: `projects`, `project_tasks`, `app_notifications`
- **Borrar**: `project_tasks`, `project_follows`

Con el paso 1, "actualizar/borrar" queda limitado a las filas propias
(Roble responde 404 si alguien intenta tocar un proyecto ajeno, aunque se
salte la app).

## Límites conocidos

- Roble no filtra la lectura por condición de fila. La app nunca muestra
  borradores ajenos ni notificaciones de otros, pero alguien que llame la
  API directamente con sesión podría leerlos. Activar "Leer sólo lo propio"
  en `projects` rompería Explorar.
- Si "Actualizar" no está dado al rol `user` en `app_notifications`,
  marcar como leída falla en silencio (la notificación se abre igual).
