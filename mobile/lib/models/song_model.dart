class SongModel {
  final String id;
  final String title;
  final String artistId;
  final String? artistName;
  final String? albumId;
  final String? albumName;
  final String audioUrl;
  final String? coverUrl;
  final String? genre;
  final String? language;
  final int? year;
  final String? description;
  final List<String>? tags;
  final Duration duration;
  final int playsCount;
  final int likesCount;
  final int downloadsCount;
  final int commentsCount;
  final bool isApproved;
  final bool isExplicit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SongModel({
    required this.id,
    required this.title,
    required this.artistId,
    this.artistName,
    this.albumId,
    this.albumName,
    required this.audioUrl,
    this.coverUrl,
    this.genre,
    this.language,
    this.year,
    this.description,
    this.tags,
    this.duration = Duration.zero,
    this.playsCount = 0,
    this.likesCount = 0,
    this.downloadsCount = 0,
    this.commentsCount = 0,
    this.isApproved = false,
    this.isExplicit = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artist_id'] as String,
      artistName: json['artist_name'] as String? ?? json['artists']?['full_name'] as String?,
      albumId: json['album_id'] as String?,
      albumName: json['album_name'] as String? ?? json['albums']?['title'] as String?,
      audioUrl: json['audio_url'] as String,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      language: json['language'] as String?,
      year: json['year'] as int?,
      description: json['description'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      playsCount: json['plays_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isApproved: json['is_approved'] as bool? ?? false,
      isExplicit: json['is_explicit'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_id': artistId,
      'album_id': albumId,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'genre': genre,
      'language': language,
      'year': year,
      'description': description,
      'tags': tags,
      'duration': duration.inSeconds,
      'plays_count': playsCount,
      'likes_count': likesCount,
      'downloads_count': downloadsCount,
      'comments_count': commentsCount,
      'is_approved': isApproved,
      'is_explicit': isExplicit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? albumId,
    String? albumName,
    String? audioUrl,
    String? coverUrl,
    String? genre,
    String? language,
    int? year,
    String? description,
    List<String>? tags,
    Duration? duration,
    int? playsCount,
    int? likesCount,
    int? downloadsCount,
    int? commentsCount,
    bool? isApproved,
    bool? isExplicit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      audioUrl: audioUrl ?? this.audioUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      year: year ?? this.year,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      playsCount: playsCount ?? this.playsCount,
      likesCount: likesCount ?? this.likesCount,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isApproved: isApproved ?? this.isApproved,
      isExplicit: isExplicit ?? this.isExplicit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlays {
    if (playsCount >= 1000000) {
      return '${(playsCount / 1000000).toStringAsFixed(1)}M';
    } else if (playsCount >= 1000) {
      return '${(playsCount / 1000).toStringAsFixed(1)}K';
    }
    return playsCount.toString();
  }
}
