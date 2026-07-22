class AppConfig {
  static const String musicApiUrl = String.fromEnvironment(
    'MUSIC_API_URL',
    defaultValue: 'http://127.0.0.1:9090',
  );
}
