# TuneBox - Toda a Música, Num Só Lugar

## Configuração do Supabase

1. Crie uma conta em [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Vá ao SQL Editor e execute o ficheiro `docs/schema.sql`
4. Copie a URL e a anon key do projeto

## Configuração do Firebase

1. Crie uma conta em [firebase.google.com](https://firebase.google.com)
2. Crie um novo projeto
3. Adicione os arquivos de configuração:
   - Android: `google-services.json` em `mobile/android/app/`
   - iOS: `GoogleService-Info.plist` em `mobile/ios/Runner/`
4. Ative os serviços:
   - Firebase Analytics
   - Firebase Crashlytics
   - Firebase Cloud Messaging

## Variáveis de Ambiente

Edite `mobile/lib/services/supabase_service.dart` e adicione:

```dart
await _supabase.initialize(
  supabaseUrl: 'SUA_SUPABASE_URL',
  supabaseAnonKey: 'SUA_SUPABASE_ANON_KEY',
);
```

## Estrutura do Projeto

```
tunebox/
├── mobile/          # App Flutter (iOS/Android)
├── admin/           # Painel administrativo
├── docs/            # Documentação e schemas
├── assets/          # Assets compartilhados
└── README.md
```

## Comandos Úteis

```bash
# Instalar dependências
cd mobile && flutter pub get

# Executar em desenvolvimento
flutter run

# Build de produção
flutter build apk --release
flutter build ios --release
```
