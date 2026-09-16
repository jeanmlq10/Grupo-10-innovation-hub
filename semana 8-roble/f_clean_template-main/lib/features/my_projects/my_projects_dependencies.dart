import 'package:get/get.dart';

import 'data/datasources/i_my_projects_source.dart';
import 'data/datasources/local/local_my_projects_source.dart';
import 'data/repositories/my_projects_repository.dart';
import 'domain/repositories/i_my_projects_repository.dart';
import 'ui/viewmodels/my_projects_controller.dart';

/// Registers the "Mis proyectos" dependency chain with GetX. Must run
/// after `registerSharedProjects()`, since [MyProjectsController] reads
/// from `ISharedProjectsRepository` too (see that class for why).
///
/// [MyProjectsController] uses `fenix: true` for the same reason as
/// `HomeController` in `registerHome()`: navigating away with
/// `Get.offNamed` removes this route, and without `fenix: true` GetX's
/// smart management would delete the controller and `Get.find()` would
/// fail the next time this screen is opened.
///
/// Swap [LocalMyProjectsSource] for a remote [IMyProjectsSource]
/// implementation here once the EXAMPLE entries move off local data;
/// the controller, repository contract and every widget stay
/// untouched — same pattern as `registerHome()`.
void registerMyProjects() {
  Get.put<IMyProjectsSource>(LocalMyProjectsSource());
  Get.put<IMyProjectsRepository>(MyProjectsRepository(Get.find()));
  Get.lazyPut(() => MyProjectsController(Get.find(), Get.find()), fenix: true);
}
