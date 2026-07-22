import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/user_model.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/supabase_file.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
      },
    );

    if (response.user == null) throw Exception('Erro ao criar conta');

    final now = DateTime.now().toIso8601String();
    await _supabase.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'full_name': fullName,
      'username': username ?? fullName.toLowerCase().replaceAll(' ', ''),
      'created_at': now,
      'updated_at': now,
    });

    return UserModel(
      id: response.user!.id,
      email: email,
      fullName: fullName,
      username: username,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return null;
    return getCurrentUserProfile();
  }

  Future<UserModel?> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.tunebox://login-callback',
    );
    return null;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    if (currentUser == null) throw Exception('Não autenticado');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase.from('users').update(updates).eq('id', currentUser!.id);
  }

  Future<String> uploadAvatar(String filePath) async {
    if (currentUser == null) throw Exception('Não autenticado');

    final file = await SupabaseFile.fromPath(filePath);
    final path = 'avatars/${currentUser!.id}/${file.name}';

    await _supabase.storage.from('avatars').upload(path, file.path);

    final url = _supabase.storage.from('avatars').getPublicUrl(path);
    return url;
  }

  Future<void> followUser(String userId) async {
    if (currentUser == null) throw Exception('Não autenticado');

    await _supabase.from('followers').insert({
      'follower_id': currentUser!.id,
      'following_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unfollowUser(String userId) async {
    if (currentUser == null) throw Exception('Não autenticado');

    await _supabase.from('followers').delete().match({
      'follower_id': currentUser!.id,
      'following_id': userId,
    });
  }

  Future<bool> isFollowing(String userId) async {
    if (currentUser == null) return false;

    final data = await _supabase
        .from('followers')
        .select()
        .match({
          'follower_id': currentUser!.id,
          'following_id': userId,
        })
        .maybeSingle();

    return data != null;
  }

  Future<List<UserModel>> getFollowers(String userId, {int limit = 20}) async {
    final data = await _supabase
        .from('followers')
        .select('users!followers_follower_id_fkey(*)')
        .eq('following_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data
        .map((e) => UserModel.fromJson(e['users']))
        .toList();
  }

  Future<List<UserModel>> getFollowing(String userId, {int limit = 20}) async {
    final data = await _supabase
        .from('followers')
        .select('users!followers_following_id_fkey(*)')
        .eq('follower_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return data
        .map((e) => UserModel.fromJson(e['users']))
        .toList();
  }
}
