class GenreModel {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final int songsCount;

  const GenreModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.songsCount = 0,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      songsCount: json['songs_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'songs_count': songsCount,
    };
  }
}
