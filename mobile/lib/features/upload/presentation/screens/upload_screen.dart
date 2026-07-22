import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _albumController = TextEditingController();
  final _genreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  XFile? _audioFile;
  XFile? _coverFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _audioFile = picked);
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _coverFile = picked);
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um ficheiro de áudio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload concluído com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no upload: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Upload'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Upload Música', style: AppTypography.displaySmall),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildAudioPicker(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCoverPicker(),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _titleController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textWhite),
                    decoration: const InputDecoration(hintText: 'Título da música'),
                    validator: (v) => v == null || v.isEmpty ? 'Insira o título' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _albumController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textWhite),
                    decoration: const InputDecoration(hintText: 'Álbum (opcional)'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _genreController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textWhite),
                    decoration: const InputDecoration(hintText: 'Género'),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  PrimaryButton(
                    text: 'Publicar',
                    isLoading: _isUploading,
                    onPressed: _handleUpload,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPicker() {
    return GestureDetector(
      onTap: _pickAudio,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _audioFile != null ? AppColors.primaryPurple : AppColors.darkBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _audioFile != null ? Icons.audiotrack_rounded : Icons.add_circle_outline_rounded,
              color: _audioFile != null ? AppColors.primaryPurple : AppColors.textTertiary,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _audioFile != null ? _audioFile!.name : 'Selecionar áudio',
              style: AppTypography.bodyMedium.copyWith(
                color: _audioFile != null ? AppColors.textWhite : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPicker() {
    return GestureDetector(
      onTap: _pickCover,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _coverFile != null ? AppColors.primaryPurple : AppColors.darkBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _coverFile != null ? Icons.image_rounded : Icons.add_photo_alternate_outlined,
              color: _coverFile != null ? AppColors.primaryPurple : AppColors.textTertiary,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _coverFile != null ? _coverFile!.name : 'Selecionar capa (opcional)',
              style: AppTypography.bodyMedium.copyWith(
                color: _coverFile != null ? AppColors.textWhite : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
