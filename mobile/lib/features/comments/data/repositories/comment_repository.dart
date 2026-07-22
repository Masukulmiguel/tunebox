import '../../../../models/comment_model.dart';
import '../../../../services/supabase_service.dart';

class CommentRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<CommentModel> addComment({
    required String songId,
    required String content,
    String? parentId,
  }) async {
    final userId = _supabase.currentUserId;
    if (userId == null) throw Exception('Não autenticado');

    final data = {
      'song_id': songId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('comments')
        .insert(data)
        .select('*, users(full_name, avatar_url)')
        .single();

    return CommentModel.fromJson(response);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.from('comments').delete().eq('id', commentId);
  }

  Future<List<CommentModel>> getSongComments(String songId, {int limit = 50}) async {
    final data = await _supabase
        .from('comments')
        .select('*, users(full_name, avatar_url)')
        .eq('song_id', songId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: false)
        .limit(limit);

    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<List<CommentModel>> getCommentReplies(String parentId, {int limit = 20}) async {
    final data = await _supabase
        .from('comments')
        .select('*, users(full_name, avatar_url)')
        .eq('parent_id', parentId)
        .order('created_at', ascending: true)
        .limit(limit);

    return data.map((e) => CommentModel.fromJson(e)).toList();
  }

  Future<void> likeComment(String commentId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('comment_likes').insert({
      'user_id': userId,
      'comment_id': commentId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unlikeComment(String commentId) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('comment_likes').delete().match({
      'user_id': userId,
      'comment_id': commentId,
    });
  }

  Future<void> reportComment(String commentId, String reason) async {
    final userId = _supabase.currentUserId;
    if (userId == null) return;

    await _supabase.from('reports').insert({
      'user_id': userId,
      'comment_id': commentId,
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
