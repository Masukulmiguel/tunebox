import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';

class CreatePlaylistScreen extends ConsumerStatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  ConsumerState<CreatePlaylistScreen> createState() =>
      _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends ConsumerState<CreatePlaylistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist criada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Criar Playlist'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.darkBorder,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.textTertiary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Adicionar\nCapa',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              TextFormField(
                controller: _nameController,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: const InputDecoration(
                  hintText: 'Nome da playlist *',
                  prefixIcon: Icon(Icons.queue_music_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textWhite,
                ),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Descrição (opcional)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description_rounded),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SwitchListTile(
                title: const Text(
                  'Playlist Pública',
                  style: AppTypography.bodyLarge,
                ),
                subtitle: Text(
                  _isPublic
                      ? 'Visível para todos'
                      : 'Apenas você pode ver',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
                activeColor: AppColors.primaryPurple,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                text: 'Criar Playlist',
                isLoading: _isCreating,
                onPressed: _createPlaylist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
