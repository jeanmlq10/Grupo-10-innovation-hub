import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import 'package:f_clean_template/core/roble/roble_client.dart';
import 'package:f_clean_template/core/storage/i_local_preferences.dart';
import 'package:f_clean_template/core/storage/local_preferences_secured.dart';
import 'package:f_clean_template/core/storage/local_preferences_shared.dart';
// auth
import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service.dart';
import 'package:f_clean_template/features/auth/data/datasources/remote/i_authentication_source.dart';
import 'package:f_clean_template/features/auth/data/repositories/auth_repository.dart';
import 'package:f_clean_template/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:f_clean_template/features/auth/ui/viewmodels/authentication_controller.dart';
// comments
import 'package:f_clean_template/features/comments/data/datasources/roble_comment_data_source.dart';
import 'package:f_clean_template/features/comments/data/repositories/comment_repository.dart';
import 'package:f_clean_template/features/comments/domain/repositories/i_comment_repository.dart';
import 'package:f_clean_template/features/comments/ui/viewmodels/comments_controller.dart';
// follows
import 'package:f_clean_template/features/follows/data/datasources/roble_follow_data_source.dart';
import 'package:f_clean_template/features/follows/data/repositories/follow_repository.dart';
import 'package:f_clean_template/features/follows/domain/repositories/i_follow_repository.dart';
// messages
import 'package:f_clean_template/features/messages/data/datasources/roble_message_data_source.dart';
import 'package:f_clean_template/features/messages/data/repositories/message_repository.dart';
import 'package:f_clean_template/features/messages/domain/repositories/i_message_repository.dart';
import 'package:f_clean_template/features/messages/ui/viewmodels/messages_controller.dart';
// profile
import 'package:f_clean_template/features/profile/data/datasources/roble_profile_data_source.dart';
import 'package:f_clean_template/features/profile/data/repositories/profile_repository.dart';
import 'package:f_clean_template/features/profile/domain/repositories/i_profile_repository.dart';
import 'package:f_clean_template/features/profile/ui/viewmodels/profile_controller.dart';
// members
import 'package:f_clean_template/features/members/data/datasources/roble_member_data_source.dart';
import 'package:f_clean_template/features/members/data/repositories/member_repository.dart';
import 'package:f_clean_template/features/members/domain/repositories/i_member_repository.dart';
// notifications
import 'package:f_clean_template/features/notifications/data/datasources/roble_notification_data_source.dart';
import 'package:f_clean_template/features/notifications/data/repositories/notification_repository.dart';
import 'package:f_clean_template/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:f_clean_template/features/notifications/ui/viewmodels/notifications_controller.dart';
// projects
import 'package:f_clean_template/features/projects/data/datasources/roble_project_data_source.dart';
import 'package:f_clean_template/features/projects/data/repositories/project_repository.dart';
import 'package:f_clean_template/features/projects/domain/repositories/i_project_repository.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/create_project_controller.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/home_controller.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/my_projects_controller.dart';
import 'package:f_clean_template/features/projects/ui/viewmodels/project_detail_controller.dart';
// requests
import 'package:f_clean_template/features/requests/data/datasources/roble_request_data_source.dart';
import 'package:f_clean_template/features/requests/data/repositories/request_repository.dart';
import 'package:f_clean_template/features/requests/domain/repositories/i_request_repository.dart';
import 'package:f_clean_template/features/requests/ui/viewmodels/requests_controller.dart';
// tasks
import 'package:f_clean_template/features/tasks/data/datasources/roble_task_data_source.dart';
import 'package:f_clean_template/features/tasks/data/repositories/task_repository.dart';
import 'package:f_clean_template/features/tasks/domain/repositories/i_task_repository.dart';

/// El UNICO sitio donde se decide que implementacion concreta se usa.
///
/// Por cada feature: `Repositorio(RobleXxxDataSource(cliente))`. Todas las
/// features reciben el MISMO `RobleClient`, asi comparten la sesion del
/// usuario logueado. El resto de la app solo conoce las interfaces
/// `I...Repository`.
class AppBindings extends Bindings {
  AppBindings({this.preferences});

  /// Solo para tests: permite inyectar un almacenamiento en memoria.
  final ILocalPreferences? preferences;

  @override
  void dependencies() {
    if (!Get.isRegistered<ILocalPreferences>()) {
      Get.put<ILocalPreferences>(
        preferences ??
            (kIsWeb ? LocalPreferencesShared() : LocalPreferencesSecured()),
        permanent: true,
      );
    }

    // Un solo cliente de Roble para toda la app.
    final cliente = RobleClient();
    Get.put(cliente, permanent: true);

    // ---------------- Repositorios (uno por feature, cada uno con su
    // datasource de Roble)
    Get.put<IAuthenticationSource>(
      AuthenticationSourceService(roble: cliente),
      permanent: true,
    );
    Get.put<IAuthRepository>(AuthRepository(Get.find()), permanent: true);
    Get.put<IProjectRepository>(
      ProjectRepository(RobleProjectDataSource(cliente)),
      permanent: true,
    );
    Get.put<ITaskRepository>(
      TaskRepository(RobleTaskDataSource(cliente)),
      permanent: true,
    );
    Get.put<IRequestRepository>(
      RequestRepository(RobleRequestDataSource(cliente)),
      permanent: true,
    );
    Get.put<IMemberRepository>(
      MemberRepository(RobleMemberDataSource(cliente)),
      permanent: true,
    );
    Get.put<ICommentRepository>(
      CommentRepository(RobleCommentDataSource(cliente)),
      permanent: true,
    );
    Get.put<IFollowRepository>(
      FollowRepository(RobleFollowDataSource(cliente)),
      permanent: true,
    );
    Get.put<INotificationRepository>(
      NotificationRepository(RobleNotificationDataSource(cliente)),
      permanent: true,
    );
    Get.put<IProfileRepository>(
      ProfileRepository(RobleProfileDataSource(cliente)),
      permanent: true,
    );
    Get.put<IMessageRepository>(
      MessageRepository(RobleMessageDataSource(cliente)),
      permanent: true,
    );

    // ---------------- ViewModels
    // Sesion: global, la necesita Central apenas arranca la app.
    Get.put(AuthenticationController(Get.find()), permanent: true);
    final session = Get.find<AuthenticationController>();

    Get.put(
      ProjectDetailController(
        projects: Get.find(),
        tasks: Get.find(),
        members: Get.find(),
        comments: Get.find(),
        follows: Get.find(),
        session: session,
        notifications: Get.find(),
      ),
      permanent: true,
    );
    Get.put(
      RequestsController(
        requests: Get.find(),
        projects: Get.find(),
        tasks: Get.find(),
        members: Get.find(),
        notifications: Get.find(),
        session: session,
      ),
      permanent: true,
    );
    Get.put(
      CommentsController(
        comments: Get.find(),
        projects: Get.find(),
        notifications: Get.find(),
        session: session,
      ),
      permanent: true,
    );
    Get.put(
      NotificationsController(
        notifications: Get.find(),
        projects: Get.find(),
        profiles: Get.find(),
        session: session,
      ),
      permanent: true,
    );
    Get.put(
      ProfileController(
        profiles: Get.find(),
        projects: Get.find(),
        tasks: Get.find(),
        members: Get.find(),
        comments: Get.find(),
        follows: Get.find(),
        requests: Get.find(),
        session: session,
      ),
      permanent: true,
    );
    Get.put(
      MessagesController(
        messages: Get.find(),
        profiles: Get.find(),
        notifications: Get.find(),
        session: session,
      ),
      permanent: true,
    );

    // Pantallas con estado propio: se reconstruyen al volver (fenix).
    Get.lazyPut(
      () => HomeController(Get.find(), Get.find(), session, Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => MyProjectsController(Get.find(), Get.find(), Get.find(), session),
      fenix: true,
    );
    Get.lazyPut(
      () => CreateProjectController(Get.find(), Get.find(), session),
      fenix: true,
    );
  }
}
