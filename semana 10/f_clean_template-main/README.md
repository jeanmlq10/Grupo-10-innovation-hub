# Innovation Hub — Grupo 10

App Flutter + GetX con Roble (Uninorte OpenLab) como backend.

## Cómo correrlo

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

Pruebas y análisis:

```bash
flutter analyze
flutter test
```

`dart_defines.json` trae la URL de Roble y el contrato del proyecto. Las tablas,
columnas y permisos que debe tener Roble están en `ROBLE_PROJECTS_SETUP.md`.

## Estructura

Cada feature tiene tres capas:

- `domain/`: modelos, interfaces de repositorio y el `Failure` de la feature.
- `data/`: datasource de Roble (habla con la tabla) y repositorio (convierte filas y errores).
- `ui/`: viewmodels (GetX), vistas y widgets.

```
lib/
├── main.dart                          Arranque de la app, tema, idioma y rutas
├── di/
│   └── app_bindings.dart              Inyección de dependencias (único lugar)
├── routes/
│   ├── app_routes.dart                Nombres de las rutas
│   └── app_pages.dart                 Páginas con nombre y AuthGuard
├── core/
│   ├── errors/app_failure.dart        Error base que se muestra al usuario
│   ├── roble/
│   │   ├── roble_client.dart          Cliente único de Roble y nombres de tablas
│   │   ├── roble_config.dart          URL y contrato de Roble
│   │   ├── retry_after_client.dart    Cliente HTTP que respeta Retry-After
│   │   ├── roble_guard.dart           Traduce excepciones de Roble al Failure de cada feature
│   │   ├── roble_optional_columns.dart  Reintenta escrituras sin columnas que aún no existen
│   │   └── roble_rows.dart            Lectura de valores de filas y fechas
│   ├── storage/
│   │   ├── i_local_preferences.dart   Interfaz de preferencias locales
│   │   ├── local_preferences_secured.dart  Preferencias cifradas (móvil)
│   │   └── local_preferences_shared.dart   Preferencias para web
│   ├── theme/
│   │   ├── app_theme.dart             Tema de la app
│   │   └── home_colors.dart           Colores de la app (morado #4B309E)
│   ├── utils/
│   │   ├── date_format.dart           Fecha corta en español ("25 oct 2026")
│   │   ├── deadline.dart              Regla de fechas límite (incluye el día)
│   │   ├── error_message.dart         Mensaje de error apto para el usuario
│   │   └── time_ago.dart              "Hace 2 h", "Hace 1 día"
│   └── widgets/dashed_border.dart     Borde punteado
└── features/
    ├── auth/                          Registro, login, sesión y modo visitante
    │   ├── domain/
    │   │   ├── auth_exceptions.dart   Errores de configuración y autenticación
    │   │   ├── password_policy.dart   Regla de contraseña de Roble
    │   │   ├── models/authentication_user.dart  Usuario autenticado
    │   │   └── repositories/i_auth_repository.dart  Contrato de autenticación
    │   ├── data/
    │   │   ├── retry_policy.dart      Reintentos ante fallos transitorios
    │   │   ├── datasources/remote/i_authentication_source.dart  Interfaz del datasource
    │   │   ├── datasources/remote/authentication_source_service.dart  Login/registro con Roble
    │   │   └── repositories/auth_repository.dart  Implementación del repositorio
    │   └── ui/
    │       ├── auth_guard.dart        Middleware que exige sesión
    │       ├── first_access_store.dart  Recuerda el primer acceso
    │       ├── viewmodels/authentication_controller.dart  Sesión y modo visitante
    │       ├── views/central.dart     Decide entre bienvenida y Explorar
    │       ├── views/welcome_page.dart  Bienvenida (iniciar, registrarse, visitante)
    │       ├── views/login_page.dart  Iniciar sesión
    │       ├── views/signup_page.dart  Registro institucional
    │       ├── views/what_to_do_page.dart  "¿Qué quieres hacer?"
    │       └── widgets/
    │           ├── auth_form_widgets.dart  Campos y botones de los formularios
    │           ├── auth_loading_view.dart  "Iniciando sesión..."
    │           ├── login_required_dialog.dart  Aviso "Necesitas iniciar sesión"
    │           ├── verification_code_input.dart  Código de verificación de 6 dígitos
    │           └── welcome_cloud_illustration.dart  Ilustración de bienvenida
    ├── home/
    │   └── ui/widgets/home_bottom_navigation.dart  Barra inferior de 4 pestañas
    ├── projects/                      Tabla projects
    │   ├── domain/
    │   │   ├── project_failure.dart
    │   │   ├── models/project.dart    Proyecto de Explorar
    │   │   ├── models/my_project.dart  Proyecto propio (publicado o borrador)
    │   │   ├── models/project_team_role.dart  Rol del equipo necesario
    │   │   ├── models/explore_filters.dart  Filtros de Explorar
    │   │   └── repositories/i_project_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_project_data_source.dart
    │   │   ├── datasources/roble_project_data_source.dart  CRUD en la tabla projects
    │   │   └── repositories/project_repository.dart
    │   └── ui/
    │       ├── viewmodels/
    │       │   ├── home_controller.dart  Explorar: carga, búsqueda y filtros
    │       │   ├── my_projects_controller.dart  Mis proyectos y borradores, eliminar
    │       │   ├── create_project_controller.dart  Asistente de crear/editar proyecto
    │       │   └── project_detail_controller.dart  Ver proyecto (tareas, miembros, actividad)
    │       ├── views/
    │       │   ├── home_page.dart     Explorar proyectos
    │       │   ├── explore_filters_page.dart  Filtros de Explorar
    │       │   ├── my_projects_page.dart  Mis proyectos
    │       │   ├── new_idea_page.dart  "Comencemos"
    │       │   ├── create_project_page.dart  Lista de pasos de crear proyecto
    │       │   ├── basic_info_page.dart  Paso 1: información básica
    │       │   ├── team_needed_page.dart  Paso 2: equipo necesario y fecha límite
    │       │   ├── task_info_page.dart  Paso 3: tareas con personas y fecha límite
    │       │   ├── estimated_time_page.dart  Tiempo estimado
    │       │   ├── audience_page.dart  Audiencia (público/privado)
    │       │   ├── review_publish_page.dart  Revisar y publicar
    │       │   ├── project_published_page.dart  "¡Proyecto publicado!"
    │       │   └── project_detail_page.dart  Ver proyecto
    │       └── widgets/
    │           ├── project_card.dart   Tarjeta de proyecto en Explorar
    │           ├── project_search_bar.dart  Buscador
    │           ├── explore_filter_tabs.dart  "Todos" / "Seguidos"
    │           ├── active_filters_bar.dart  Filtros activos bajo el buscador
    │           ├── filter_option_chip.dart  Opción del panel de filtros
    │           ├── explore_filter_labels.dart  Textos de los filtros
    │           ├── create_idea_card.dart  Tarjeta "Crea otra idea"
    │           ├── my_project_card.dart  Tarjeta con lápiz y caneca
    │           ├── my_project_placeholder_card.dart  Tarjeta de carga
    │           ├── my_projects_tabs.dart  Pestañas proyectos / borradores
    │           ├── create_project_step_tile.dart  Fila de paso del asistente
    │           ├── step_progress_bar.dart  Barra de progreso "1/4"
    │           ├── wizard_nav_buttons.dart  Botones Anterior / Siguiente
    │           ├── team_role_tile.dart  Fila de rol del equipo
    │           ├── counter_stepper.dart  Contador – 0 +
    │           ├── selectable_option_tile.dart  Opción de selección única
    │           ├── deadline_picker_field.dart  Campo de fecha límite
    │           ├── idea_cloud_illustration.dart  Ilustración de "Comencemos"
    │           └── confetti_check_illustration.dart  Ilustración de publicado
    ├── tasks/                         Tabla project_tasks
    │   ├── domain/
    │   │   ├── task_failure.dart
    │   │   ├── models/project_task.dart  Tarea, fecha límite y estado
    │   │   └── repositories/i_task_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_task_data_source.dart
    │   │   ├── datasources/roble_task_data_source.dart
    │   │   └── repositories/task_repository.dart
    │   └── ui/views/available_tasks_page.dart  Tareas disponibles
    ├── requests/                      Tablas project_requests y request_decisions
    │   ├── domain/
    │   │   ├── request_failure.dart
    │   │   ├── models/participation_request.dart  Solicitud y su estado
    │   │   └── repositories/i_request_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_request_data_source.dart
    │   │   ├── datasources/roble_request_data_source.dart
    │   │   └── repositories/request_repository.dart
    │   └── ui/
    │       ├── viewmodels/requests_controller.dart  Enviar, aceptar y rechazar
    │       ├── views/choose_participation_page.dart  Elige cómo participar
    │       ├── views/join_team_page.dart  Envía tu solicitud
    │       ├── views/request_sent_page.dart  "¡Solicitud enviada!"
    │       ├── views/requests_page.dart  Solicitudes recibidas
    │       └── widgets/participation_option_tile.dart  Opción de participación
    ├── members/                       Tabla project_members
    │   ├── domain/
    │   │   ├── member_failure.dart
    │   │   ├── models/project_member.dart
    │   │   └── repositories/i_member_repository.dart
    │   └── data/
    │       ├── datasources/i_member_data_source.dart
    │       ├── datasources/roble_member_data_source.dart
    │       └── repositories/member_repository.dart
    ├── follows/                       Tabla project_follows
    │   ├── domain/
    │   │   ├── follow_failure.dart
    │   │   ├── models/project_follow.dart
    │   │   └── repositories/i_follow_repository.dart
    │   └── data/
    │       ├── datasources/i_follow_data_source.dart
    │       ├── datasources/roble_follow_data_source.dart
    │       └── repositories/follow_repository.dart
    ├── comments/                      Tabla project_comments
    │   ├── domain/
    │   │   ├── comment_failure.dart
    │   │   ├── models/project_comment.dart
    │   │   └── repositories/i_comment_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_comment_data_source.dart
    │   │   ├── datasources/roble_comment_data_source.dart
    │   │   └── repositories/comment_repository.dart
    │   └── ui/
    │       ├── viewmodels/comments_controller.dart
    │       └── widgets/project_comments_sheet.dart  Hoja de comentarios
    ├── notifications/                 Tabla app_notifications
    │   ├── domain/
    │   │   ├── notification_failure.dart
    │   │   ├── models/app_notification.dart  Notificación y sus tipos
    │   │   ├── models/notification_category.dart  Categorías para filtrar
    │   │   ├── models/notification_preference.dart  Preferencias del perfil
    │   │   └── repositories/i_notification_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_notification_data_source.dart
    │   │   ├── datasources/roble_notification_data_source.dart
    │   │   └── repositories/notification_repository.dart
    │   └── ui/
    │       ├── viewmodels/notifications_controller.dart  Lista, búsqueda, no leídas y filtros
    │       ├── views/notifications_page.dart  Notificaciones
    │       ├── views/notification_filters_page.dart  Filtrar notificaciones
    │       ├── views/request_notification_page.dart  Detalle de solicitud / postulación
    │       ├── views/request_result_page.dart  Solicitud aceptada o rechazada
    │       ├── views/activity_notification_page.dart  Comentario o tarea completada
    │       └── widgets/
    │           ├── notification_tile.dart  Fila de notificación
    │           ├── notification_labels.dart  Textos e iconos por tipo
    │           ├── person_header.dart  Cabecera con avatar y nombre
    │           ├── info_nav_tile.dart  Fila con flecha
    │           └── quote_box.dart     Recuadro con texto citado
    ├── profile/                       Tabla user_profiles
    │   ├── domain/
    │   │   ├── profile_failure.dart
    │   │   ├── models/user_profile.dart  Perfil y privacidad
    │   │   ├── models/public_profile.dart  Perfil de otra persona
    │   │   ├── models/trajectory_summary.dart  Indicadores de trayectoria
    │   │   ├── models/activity_entry.dart  Registro del historial
    │   │   └── repositories/i_profile_repository.dart
    │   ├── data/
    │   │   ├── datasources/i_profile_data_source.dart
    │   │   ├── datasources/roble_profile_data_source.dart
    │   │   └── repositories/profile_repository.dart
    │   └── ui/
    │       ├── viewmodels/profile_controller.dart  Perfil, trayectoria, historial y ajustes
    │       ├── views/
    │       │   ├── profile_page.dart  Perfil
    │       │   ├── edit_profile_page.dart  Editar perfil
    │       │   ├── trajectory_page.dart  Detalle de trayectoria
    │       │   ├── activity_history_page.dart  Historial de actividad
    │       │   ├── my_ideas_page.dart  Mis ideas
    │       │   ├── settings_page.dart  Configuración
    │       │   ├── notification_settings_page.dart  Preferencias de notificaciones
    │       │   ├── privacy_page.dart  Privacidad
    │       │   ├── logout_page.dart   Cerrar sesión
    │       │   ├── public_profile_page.dart  Perfil de otra persona
    │       │   └── user_participations_page.dart  Proyectos en los que participó
    │       └── widgets/
    │           ├── profile_avatar.dart  Avatar con inicial o icono
    │           ├── avatar_icons.dart  Catálogo de iconos (pendiente)
    │           ├── avatar_icon_picker.dart  Selector de icono (pendiente)
    │           ├── profile_menu_tile.dart  Fila de menú
    │           ├── trajectory_stats_grid.dart  Cuadrícula de 4 indicadores
    │           ├── performance_bar.dart  Barra de desempeño
    │           ├── activity_entry_tile.dart  Fila del historial
    │           └── profile_labels.dart  Textos e iconos del perfil
    └── messages/                      Tabla direct_messages
        ├── domain/
        │   ├── message_failure.dart
        │   ├── models/direct_message.dart  Mensaje entre dos usuarios
        │   ├── models/conversation.dart  Agrupa mensajes por persona
        │   └── repositories/i_message_repository.dart
        ├── data/
        │   ├── datasources/i_message_data_source.dart
        │   ├── datasources/roble_message_data_source.dart
        │   └── repositories/message_repository.dart
        └── ui/
            ├── viewmodels/messages_controller.dart  Conversaciones y envío
            ├── views/messages_page.dart  Mensajes
            ├── views/chat_page.dart   Chat con otra persona
            └── widgets/
                ├── conversation_tile.dart  Fila de conversación
                └── message_bubble.dart  Burbuja de mensaje

test/
├── widget_test.dart
├── core/roble_optional_columns_test.dart       Reintento sin columnas faltantes
└── features/
    ├── auth/                                   Login, registro, sesión, reintentos y contraseña
    ├── projects/explore_filters_test.dart      Filtros de Explorar
    ├── tasks/deadlines_test.dart               Fechas límite de tareas y convocatoria
    ├── notifications/notification_category_test.dart  Categorías de notificaciones
    ├── profile/trajectory_summary_test.dart    Cálculo de trayectoria
    └── messages/conversation_test.dart         Agrupación de conversaciones
```
