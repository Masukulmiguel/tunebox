import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/comment_repository.dart';
import '../../../../models/comment_model.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

final songCommentsProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, songId) async {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.getSongComments(songId);
});
