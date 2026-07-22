class AppConfig {
  static const String musicApiUrl = String.fromEnvironment(
    'MUSIC_API_URL',
    defaultValue: 'https://tunebox-25.up.railway.app',
  );
}
