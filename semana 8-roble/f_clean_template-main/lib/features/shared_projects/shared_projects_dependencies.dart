import 'package:get/get.dart';

import '../auth/data/datasources/remote/authentication_source_service.dart';
import '../auth/data/datasources/remote/i_authentication_source.dart';
import 'data/datasources/i_shared_projects_source.dart';
import 'data/datasources/remote/roble_shared_projects_source.dart';
import 'data/repositories/shared_projects_repository.dart';
import 'domain/repositories/i_shared_projects_repository.dart';
import 'ui/viewmodels/project_application_controller.dart';

/// Registers the projects module. The data source is Roble, reusing the
/// same client (and session) the auth layer created at login. Must run
/// after `registerAuth()`.
void registerSharedProjects() {
  Get.put<ISharedProjectsSource>(
    RobleSharedProjectsSource(
      () =>
          (Get.find<IAuthenticationSource>() as AuthenticationSourceService)
              .robleClient,
    ),
  );
  Get.put<ISharedProjectsRepository>(SharedProjectsRepository(Get.find()));
  Get.put(ProjectApplicationController(Get.find()));
}
