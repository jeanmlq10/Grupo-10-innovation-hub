import 'package:get/get.dart';

import 'data/datasources/i_project_source.dart';
import 'data/datasources/local/local_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/home_controller.dart';

/// Registers the home/project dependency chain with GetX.
///
/// Swap [LocalProjectSource] for a remote [IProjectSource] implementation
/// here when a backend is connected; the controller, repository contract
/// and every widget stay untouched — same pattern as `registerProduct()`.
void registerHome() {
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.lazyPut(() => HomeController(Get.find()));
}
