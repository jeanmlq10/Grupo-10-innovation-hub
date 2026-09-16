import 'package:get/get.dart';

import 'data/datasources/i_shared_projects_source.dart';
import 'data/datasources/local/local_shared_projects_source.dart';
import 'data/repositories/shared_projects_repository.dart';
import 'domain/repositories/i_shared_projects_repository.dart';
import 'ui/viewmodels/project_application_controller.dart';

/// Registers the shared-projects dependency chain with GetX.
///
/// This MUST run before `registerHome()`, `registerMyProjects()` and
/// `registerCreateProject()` in `main.dart` — all three now depend on
/// [ISharedProjectsRepository] via `Get.find()`.
void registerSharedProjects() {
  Get.put<ISharedProjectsSource>(LocalSharedProjectsSource());
  Get.put<ISharedProjectsRepository>(SharedProjectsRepository(Get.find()));
  Get.put(ProjectApplicationController(Get.find()));
}
