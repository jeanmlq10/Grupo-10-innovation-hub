import 'package:get/get.dart';

import 'ui/viewmodels/create_project_controller.dart';

/// Registers the "Crear proyecto" dependency chain with GetX.
///
/// There's no local source/repository here anymore — the wizard reads
/// and writes straight to `ISharedProjectsRepository` (registered by
/// `registerSharedProjects()`, which must run before this).
///
/// [CreateProjectController] uses `fenix: true` for the same reason as
/// `HomeController`/`MyProjectsController`: "Nueva idea" through
/// "Revisar y publicar" are pushed (not replaced) as the user moves
/// forward, so the controller stays alive while progressing through the
/// wizard; it only gets deleted once every one of those screens is
/// popped (i.e. the user backed all the way out). `fenix: true` lets it
/// be rebuilt cleanly the next time "+" is tapped, instead of throwing a
/// "not found" error.
void registerCreateProject() {
  Get.lazyPut(() => CreateProjectController(Get.find()), fenix: true);
}
