import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  static const String _supabaseUrl = 'https://hgmuwnkrppwyirxfomnd.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_j2aPzmRyJaQWIhUtSN9CxQ_JQ2UF2KJ';

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  GoTrueClient get auth => _client.auth;
  SupabaseQueryBuilder from(String table) => _client.from(table);
  SupabaseStorageClient get storage => _client.storage;
  RealtimeChannel get realtime => _client.channel('public');
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) =>
      _client.rpc(functionName, params: params);
}
