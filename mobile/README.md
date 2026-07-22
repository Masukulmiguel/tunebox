# TuneBox

**Toda a música, num só lugar.**

TuneBox é uma plataforma moderna de streaming de música onde qualquer utilizador pode ouvir, descarregar, publicar e partilhar músicas.

## Funcionalidades

- Streaming de música com player completo
- Download para ouvir offline
- Publicação de músicas
- Playlists (públicas e privadas)
- Seguir artistas
- Curtir músicas
- Comentários
- Partilha (WhatsApp, Facebook, Telegram)
- Descoberta de novos artistas
- Modo escuro / claro

## Tecnologias

- **Flutter** - Framework mobile
- **Riverpod** - Gestão de estado
- **GoRouter** - Navegação
- **Supabase** - Backend (Auth, Database, Storage, Realtime)
- **just_audio** - Reprodução de áudio
- **Hive** - Cache local
- **Firebase** - Analytics, Crashlytics, Cloud Messaging

## Arquitetura

- Clean Architecture
- Repository Pattern
- Feature-based organization

## Estrutura

```
mobile/
  lib/
    core/
      theme/        # Design System
      constants/
      router/       # GoRouter config
      utils/
      widgets/      # Widgets reutilizáveis
    features/
      auth/         # Autenticação
      home/         # Tela principal
      search/       # Pesquisa
      player/       # Player de áudio
      library/      # Biblioteca
      profile/      # Perfil
      upload/       # Publicar música
      playlist/     # Playlists
      comments/     # Comentários
      discover/     # Descoberta
    models/         # Data models
    services/       # Serviços globais
  assets/
    images/
    fonts/
    icons/
admin/              # Painel administrativo
docs/               # Documentação
```

## Configuração

1. Clone o repositório
2. Configure as variáveis de ambiente do Supabase em `lib/services/supabase_service.dart`
3. Execute `flutter pub get`
4. Execute `flutter run`

## Licença

MIT License
