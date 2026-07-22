class CommentModel {
  final String id;
  final String songId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? parentId;
  final int likesCount;
  final int repliesCount;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.songId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.parentId,
    this.likesCount = 0,
    this.repliesCount = 0,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      songId: json['song_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? json['users']?['full_name'] as String?,
      userAvatar: json['user_avatar'] as String? ?? json['users']?['avatar_url'] as String?,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      repliesCount: json['replies_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song_id': songId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isReply => parentId != null;
}
