class DownloadModel {
  final String id;
  final String songId;
  final String userId;
  final String filePath;
  final int progress;
  final DownloadStatus status;
  final DateTime createdAt;

  const DownloadModel({
    required this.id,
    required this.songId,
    required this.userId,
    required this.filePath,
    this.progress = 0,
    this.status = DownloadStatus.pending,
    required this.createdAt,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'] as String,
      songId: json['song_id'] as String,
      userId: json['user_id'] as String,
      filePath: json['file_path'] as String,
      progress: json['progress'] as int? ?? 0,
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song_id': songId,
      'user_id': userId,
      'file_path': filePath,
      'progress': progress,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DownloadModel copyWith({
    String? id,
    String? songId,
    String? userId,
    String? filePath,
    int? progress,
    DownloadStatus? status,
    DateTime? createdAt,
  }) {
    return DownloadModel(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      userId: userId ?? this.userId,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}
