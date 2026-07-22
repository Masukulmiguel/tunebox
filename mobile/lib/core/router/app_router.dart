import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/player/presentation/screens/player_screen.dart';
import '../../features/upload/presentation/screens/upload_screen.dart';
import '../../features/playlist/presentation/screens/playlist_detail_screen.dart';
import '../../features/playlist/presentation/screens/create_playlist_screen.dart';
import '../../features/discover/presentation/screens/artist_profile_screen.dart';
import '../../features/comments/presentation/screens/comments_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlayerScreen(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/upload',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/playlist/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PlaylistDetailScreen(
          playlistId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/create-playlist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreatePlaylistScreen(),
      ),
      GoRoute(
        path: '/artist/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ArtistProfileScreen(
          artistId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/comments/:songId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CommentsScreen(
          songId: state.pathParameters['songId']!,
        ),
      ),
    ],
  );
});
