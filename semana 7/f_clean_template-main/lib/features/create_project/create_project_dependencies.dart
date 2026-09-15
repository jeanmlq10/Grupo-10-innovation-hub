import 'package:get/get.dart';

import 'data/datasources/i_create_project_source.dart';
import 'data/datasources/local/local_create_project_source.dart';
import 'data/repositories/create_project_repository.dart';
import 'domain/repositories/i_create_project_repository.dart';
import 'ui/viewmodels/create_project_controller.dart';

/// Registers the "Crear proyecto" dependency chain with GetX.
///
/// [CreateProjectController] uses `fenix: true` for the same reason as
/// `HomeController`/`MyProjectsController`: "Nueva idea" and
/// "Información básica" are pushed (not replaced) as the user moves
/// forward, so the controller stays alive while progressing through the
/// wizard; it only gets deleted once every one of those screens is
/// popped (i.e. the user backed all the way out). `fenix: true` lets it
/// be rebuilt cleanly — with a blank draft, via `onInit`'s
/// `resetDraft()` — the next time "+" is tapped, instead of throwing a
/// "not found" error.
void registerCreateProject() {
  Get.put<ICreateProjectSource>(LocalCreateProjectSource());
  Get.put<ICreateProjectRepository>(CreateProjectRepository(Get.find()));
  Get.lazyPut(() => CreateProjectController(Get.find()), fenix: true);
}
