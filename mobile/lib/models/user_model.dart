class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final bool isArtist;
  final bool isAdmin;
  final int followersCount;
  final int followingCount;
  final int totalPlays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.isArtist = false,
    this.isAdmin = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.totalPlays = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      isArtist: json['is_artist'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      totalPlays: json['total_plays'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_artist': isArtist,
      'is_admin': isAdmin,
      'followers_count': followersCount,
      'following_count': followingCount,
      'total_plays': totalPlays,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    bool? isArtist,
    bool? isAdmin,
    int? followersCount,
    int? followingCount,
    int? totalPlays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isArtist: isArtist ?? this.isArtist,
      isAdmin: isAdmin ?? this.isAdmin,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      totalPlays: totalPlays ?? this.totalPlays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => fullName ?? username ?? email.split('@').first;
  String get initials {
    final name = displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
