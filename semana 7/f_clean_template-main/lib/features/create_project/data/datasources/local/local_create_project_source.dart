import '../../../domain/models/new_project_draft.dart';
import '../i_create_project_source.dart';

/// Local/in-memory implementation of [ICreateProjectSource].
///
/// This stage is scoped to LOCAL data only: no Firebase, no Supabase, no
/// API, no database. The draft just lives in a plain field here for the
/// duration of the app session — enough for "Nueva idea" and
/// "Información básica" to share the same name/description without
/// passing data through widget constructors. When "Revisar y publicar"
/// is implemented, it will read the finished draft from here through the
/// same `getDraft()` call.
class LocalCreateProjectSource implements ICreateProjectSource {
  NewProjectDraft _draft = const NewProjectDraft();

  @override
  NewProjectDraft getDraft() => _draft;

  @override
  void saveDraft(NewProjectDraft draft) => _draft = draft;

  @override
  void resetDraft() => _draft = const NewProjectDraft();
}
