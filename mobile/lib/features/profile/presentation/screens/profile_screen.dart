import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/app_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Não autenticado',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    text: 'Fazer Login',
                    width: 200,
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.darkBackground,
                title: const Text('Perfil'),
                actions: [
                  IconButton(
                    icon: const Icon(
                      AppIcons.settings,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildProfileHeader(user),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildStatsRow(user),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildMenuSection(context, ref),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text('Erro: $e'),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.purpleBlueGradient,
            boxShadow: AppShadows.colored(AppColors.primaryPurple),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkBackground,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: user.avatarUrl != null
                  ? Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(user),
                    )
                  : _buildAvatarPlaceholder(user),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user.displayName,
          style: AppTypography.headlineMedium,
        ),
        if (user.username != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '@${user.username}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
            ),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (user.isArtist) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'ARTISTA VERIFICADO',
              style: AppTypography.labelSmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarPlaceholder(dynamic user) {
    return Container(
      color: AppColors.darkSurfaceVariant,
      child: Center(
        child: Text(
          user.initials,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Seguidores', '${user.followersCount}'),
          Container(
            width: 1,
            height: 32,
            color: AppColors.darkBorder,
          ),
          _buildStatItem('A seguir', '${user.followingCount}'),
          Container(
            width: 1,
            height: 32,
            color: AppColors.darkBorder,
          ),
          _buildStatItem('Reproduções', '${user.totalPlays}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.upload_rounded,
            'Minhas Músicas',
            'Gerir as suas publicações',
            () {},
          ),
          _buildMenuItem(
            AppIcons.downloadCloud,
            'Downloads',
            'Músicas guardadas offline',
            () {},
          ),
          _buildMenuItem(
            AppIcons.like,
            'Curtidas',
            'Músicas que curtiu',
            () {},
          ),
          _buildMenuItem(
            AppIcons.notification,
            'Notificações',
            'Gerir notificações',
            () {},
          ),
          _buildMenuItem(
            AppIcons.language,
            'Idioma',
            'Português',
            () {},
          ),
          _buildMenuItem(
            Icons.dark_mode_rounded,
            'Aparência',
            'Modo escuro',
            () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          _buildMenuItem(
            AppIcons.info,
            'Sobre',
            'Versão 1.0.0',
            () {},
          ),
          const SizedBox(height: AppSpacing.md),
          _buildMenuItem(
            AppIcons.logout,
            'Terminar Sessão',
            '',
            () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
            isDestructive: true,
          ),
          const SizedBox(height: AppSpacing.xxxxxl),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing: Icon(
        AppIcons.arrowForward,
        color: AppColors.textTertiary,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
