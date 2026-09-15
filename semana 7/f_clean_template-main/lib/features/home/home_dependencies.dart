import 'package:get/get.dart';

import 'data/datasources/i_project_source.dart';
import 'data/datasources/local/local_project_source.dart';
import 'data/repositories/project_repository.dart';
import 'domain/repositories/i_project_repository.dart';
import 'ui/viewmodels/home_controller.dart';

/// Registers the home/project dependency chain with GetX. Must run
/// after `registerSharedProjects()`, since [HomeController] reads from
/// `ISharedProjectsRepository` too (see that class for why).
///
/// [HomeController] uses `fenix: true`: since Home and "Mis proyectos"
/// now navigate between each other with `Get.offNamed` (which removes
/// the previous route), GetX's default smart management would otherwise
/// delete the controller as soon as its route is removed, leaving
/// `Get.find()` unable to find it on the way back. `fenix: true` tells
/// GetX to rebuild it on demand instead of failing.
///
/// Swap [LocalProjectSource] for a remote [IProjectSource] implementation
/// here when a backend is connected; the controller, repository contract
/// and every widget stay untouched — same pattern as `registerProduct()`.
void registerHome() {
  Get.put<IProjectSource>(LocalProjectSource());
  Get.put<IProjectRepository>(ProjectRepository(Get.find()));
  Get.lazyPut(() => HomeController(Get.find(), Get.find()), fenix: true);
}
