# Innovation Hub — Grupo 10

App para publicar ideas y encontrar personas que las construyan. Flutter +
GetX, con Roble (Uninorte OpenLab) como backend.

## Cómo correrlo

```bash
flutter pub get
flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json
```

`dart_defines.json` trae la URL de Roble y el contrato `movil_flutter_dcaabc5f4e`
(no son secretos). Las tablas y permisos de Roble están en
`ROBLE_PROJECTS_SETUP.md`.

## Arquitectura

Clean architecture **por feature**, con MVVM en la presentación (GetX para
navegación e inyección). **No hay casos de uso**: las reglas de negocio viven
en los view models (`ui/viewmodels/`), que solo conocen las interfaces
`I...Repository` del dominio.

```
lib/
  core/              lo transversal
    roble/           RobleClient (UNO para toda la app), config, utilidades
    errors/          AppFailure (base de los Failure de cada feature)
    storage/         preferencias locales
    theme/ utils/ widgets/
  di/app_bindings.dart   el ÚNICO sitio que decide qué implementación se usa
  routes/            nombres de ruta y GetPages
  features/
    auth/            registro, login, logout, sesión (Roble Auth)
    projects/        tabla projects: explorar, crear, mis proyectos, ver proyecto
    tasks/           tabla project_tasks: tareas específicas
    requests/        tablas project_requests + request_decisions: solicitudes
    members/         tabla project_members: miembros reales
    comments/        tabla project_comments: comentarios
    follows/         tabla project_follows: seguir proyectos
    notifications/   tabla app_notifications: bandeja de avisos, filtros y detalle
    profile/         tabla user_profiles: Mi perfil, trayectoria, historial, privacidad
    messages/        tabla direct_messages: Mensajes entre usuarios
    home/            carcasa: barra de navegación inferior
```

Cada feature repite las mismas capas:

```
features/<nombre>/
  domain/
    models/          entidades
    repositories/    interfaces (prefijo I)
    <nombre>_failure.dart   el error de la feature (extiende AppFailure)
  data/
    datasources/     i_<x>_data_source.dart + roble_<x>_data_source.dart
                     SOLO hablan con Roble y lo hacen en FILAS (Map).
                     No deciden nada.
    repositories/    convierten filas en entidades, deciden y traducen los
                     errores de Roble al Failure de la feature
  ui/
    viewmodels/ views/ widgets/
```

**Cada feature tiene su propio datasource de Roble**, y todos reciben el mismo
`RobleClient` desde `di/app_bindings.dart`:

```dart
ProjectRepository(RobleProjectDataSource(cliente))
TaskRepository(RobleTaskDataSource(cliente))
RequestRepository(RobleRequestDataSource(cliente))
MemberRepository(RobleMemberDataSource(cliente))
CommentRepository(RobleCommentDataSource(cliente))
FollowRepository(RobleFollowDataSource(cliente))
NotificationRepository(RobleNotificationDataSource(cliente))
ProfileRepository(RobleProfileDataSource(cliente))
MessageRepository(RobleMessageDataSource(cliente))
AuthRepository(AuthenticationSourceService(roble: cliente))
```

Un solo cliente = una sola sesión: cada petición lleva el token del usuario y
Roble llena `_owner` con su userId.

**Las llamadas a Roble viven solo en `data/datasources/`.** Se comprueba así:

```bash
grep -rn "_client.db" lib/features/*/data/repositories   # vacío
grep -rn "roble" lib/features/*/domain lib/features/*/ui  # vacío
```

La regla de dependencia va hacia adentro: `ui` conoce `domain`, `data`
implementa `domain`, y `domain` no conoce a nadie.

### Traducción de errores

| Lo que llega de Roble | Lo que ve el usuario (Failure de la feature) |
|---|---|
| 403 | «Tu cuenta no tiene permiso para hacer esto.» |
| 404 en update/delete | no existe **o** no es tuyo (el servidor responde igual) |
| lo demás | el mensaje del servidor dentro del Failure |

### Dónde están las reglas de negocio

| Regla | Dónde vive |
|---|---|
| Explorar = publicados y «Toda la comunidad»; Mis proyectos = los míos | `ProjectRepository` |
| «Solo yo» = borrador, «Toda la comunidad» = publicado (misma fila, autoguardado) | `CreateProjectController` |
| Solo a proyectos públicos y nunca al propio | `RequestsController._submit` |
| Solo el dueño acepta/rechaza; una sola vez (idempotente) | `RequestsController.acceptRequest / rejectRequest` |
| Aceptar = decisión + contador tarea/rol + miembro + acceptedMembersCount + aviso | `RequestsController.acceptRequest` |
| Estado de una solicitud = última decisión escrita por el dueño | `RequestRepository` |
| Solo cuentan miembros registrados por el dueño; sin duplicados | `MemberRepository` |
| Sincronizar tareas (crear, actualizar, borrar o cerrar) | `TaskRepository.sync` |
| Seguir = insertar, dejar de seguir = borrar | `FollowRepository.toggle` |
| Avisar al dueño de un comentario | `CommentsController.addComment` |
| Visitante: solo explorar y consultar; lo demás pide sesión | `AuthenticationController.isGuest` + `requireSession()` (`auth/ui/widgets/login_required_dialog.dart`) |
| Visitante lee sin sesión (`db.publicRead`) | `ProjectRepository` / `TaskRepository` con `publicAccess: true` |
| Filtros de Explorar (fecha, tareas, miembros, rol) | `ExploreFilters.matches` (`projects/domain/models/explore_filters.dart`), aplicado en `HomeController.filteredProjects` |
| Fechas límite: se puede postular hasta las 23:59 del día límite | `isBeforeDeadline` (`core/utils/deadline.dart`), `ProjectTask.canApplyAt`, `Project.isTeamCallOpenAt` |
| No se acepta una solicitud con la tarea o la convocatoria cerradas | `RequestsController._submit` |
| Estado de la tarea (Disponible / En progreso / Completada / Cerrada) | `ProjectTask.displayStatusAt`; el dueño lo cambia con `ProjectDetailController.setTaskProgress` |
| Notificaciones: categorías, filtros y lo que se oculta por preferencias | `NotificationCategory`, `NotificationPreference`, `NotificationsController.visible` |
| Cada aviso guarda quién lo causó y su detalle (rol, tarea, comentario) | `RequestsController`, `CommentsController`, `ProjectDetailController.setTaskProgress` |
| Trayectoria (proyectos/tareas completadas, participaciones, compromiso, desempeño) | `TrajectorySummary` (domain) + `ProfileController._summarize` |
| Una participación cuenta solo si la registró el creador del proyecto | `ProfileController._collect` |
| Perfil público respeta "Visibilidad" y "Datos de actividad" | `ProfileController.publicProfile` |
| No se escribe a quien eligió "Nadie" en "Quién puede contactarte" | `MessagesController.send` |

## Rutas

| Ruta | Pantalla | Protección |
|---|---|---|
| `/` | `Central`: restaura la sesión → Home o Bienvenido | — |
| `/home` | Explorar proyectos | `AuthGuard` (deja pasar al visitante) |
| `/mis-proyectos` | Mis proyectos | `AuthGuard` |
| `/notificaciones` | Notificaciones | `AuthGuard` |
| `/perfil` | Mi perfil | `AuthGuard` |
