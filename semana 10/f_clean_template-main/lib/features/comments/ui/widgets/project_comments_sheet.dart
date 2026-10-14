import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:f_clean_template/core/utils/error_message.dart';
import 'package:f_clean_template/core/theme/home_colors.dart';
import 'package:f_clean_template/features/comments/domain/models/project_comment.dart';
import 'package:f_clean_template/features/comments/ui/viewmodels/comments_controller.dart';

/// Opens the comments of [projectId] as a bottom sheet over "Ver proyecto":
/// list of comments + "Escribe un comentario..." field, so commenting is
/// one tap away from the project (no intermediate screen).
Future<void> showProjectComments(BuildContext context, String projectId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ProjectCommentsSheet(projectId: projectId),
  );
}

class ProjectCommentsSheet extends StatefulWidget {
  const ProjectCommentsSheet({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectCommentsSheet> createState() => _ProjectCommentsSheetState();
}

class _ProjectCommentsSheetState extends State<ProjectCommentsSheet> {
  final CommentsController _controller = Get.find();
  final TextEditingController _textController = TextEditingController();

  List<ProjectComment>? _comments;
  String? _loadError;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final comments = await _controller.commentsFor(widget.projectId);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _comments = const [];
        _loadError = errorMessage(error);
      });
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _controller.addComment(projectId: widget.projectId, text: text);
      _textController.clear();
      await _load();
    } catch (error) {
      Get.snackbar(
        'Comentarios',
        errorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    final days = diff.inDays;
    return days == 1 ? 'Hace 1 día' : 'Hace $days días';
  }

  @override
  Widget build(BuildContext context) {
    final comments = _comments ?? const <ProjectComment>[];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Comentarios (${comments.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HomeColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: HomeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: HomeColors.borderGrey),
              Flexible(
                child: _comments == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(
                            _loadError ??
                                'Todavía no hay comentarios. ¡Sé el primero!',
                            style: const TextStyle(
                              color: HomeColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: HomeColors.borderGrey,
                        ),
                        itemBuilder: (_, index) =>
                            _CommentTile(comment: comments[index]),
                      ),
              ),
              const Divider(height: 1, color: HomeColors.borderGrey),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autofocus: false,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 14,
                          color: HomeColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe un comentario...',
                          hintStyle: const TextStyle(
                            color: HomeColors.textSecondary,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: HomeColors.borderGrey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: HomeColors.borderGrey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: HomeColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: HomeColors.primaryPurple,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _sending ? null : _send,
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final ProjectComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: HomeColors.navSelectedBackground,
            child: Icon(
              Icons.person,
              color: HomeColors.primaryPurple,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: HomeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: HomeColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ProjectCommentsSheetState._timeAgo(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: HomeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
