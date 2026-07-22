class AlbumModel {
  final String id;
  final String title;
  final String artistId;
  final String? artistName;
  final String? coverUrl;
  final String? description;
  final int year;
  final int songsCount;
  final int totalPlays;
  final DateTime createdAt;

  const AlbumModel({
    required this.id,
    required this.title,
    required this.artistId,
    this.artistName,
    this.coverUrl,
    this.description,
    this.year = 0,
    this.songsCount = 0,
    this.totalPlays = 0,
    required this.createdAt,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artist_id'] as String,
      artistName: json['artist_name'] as String? ?? json['artists']?['full_name'] as String?,
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      year: json['year'] as int? ?? 0,
      songsCount: json['songs_count'] as int? ?? 0,
      totalPlays: json['total_plays'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_id': artistId,
      'cover_url': coverUrl,
      'description': description,
      'year': year,
      'songs_count': songsCount,
      'total_plays': totalPlays,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
