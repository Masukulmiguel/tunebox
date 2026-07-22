import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), AppColors.darkBackground],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Recuperar\nPalavra-passe',
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_sent) ...[
                  Text(
                    'Insira o seu email para receber um link de recuperação.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textWhite,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira o seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    text: 'Enviar Link',
                    isLoading: authState.isLoading,
                    onPressed: _handleReset,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xxxl),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        color: AppColors.success,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Center(
                    child: Text(
                      'Email Enviado!',
                      style: AppTypography.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(
                      'Verifique a sua caixa de entrada e clique no link para redefinir a sua palavra-passe.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  PrimaryButton(
                    text: 'Voltar ao Login',
                    isOutlined: true,
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
