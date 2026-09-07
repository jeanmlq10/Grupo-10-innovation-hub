import '../../domain/models/project.dart';

/// Data-source contract for projects. Shared by local and (future) remote
/// implementations — mirrors `features/product/data/datasources/i_remote_product_source.dart`.
abstract class IProjectSource {
  Future<List<Project>> getProjects();
}
