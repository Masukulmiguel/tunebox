class PlaylistModel {
  final String id;
  final String name;
  final String userId;
  final String? description;
  final String? coverUrl;
  final bool isPublic;
  final int songsCount;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.userId,
    this.description,
    this.coverUrl,
    this.isPublic = true,
    this.songsCount = 0,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      songsCount: json['songs_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'description': description,
      'cover_url': coverUrl,
      'is_public': isPublic,
      'songs_count': songsCount,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? description,
    String? coverUrl,
    bool? isPublic,
    int? songsCount,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      isPublic: isPublic ?? this.isPublic,
      songsCount: songsCount ?? this.songsCount,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
