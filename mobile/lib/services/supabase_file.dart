class SupabaseFile {
  final String path;
  final String name;
  final String extension;

  SupabaseFile._({
    required this.path,
    required this.name,
    required this.extension,
  });

  static Future<SupabaseFile> fromPath(String filePath) async {
    final fileName = filePath.split('/').last;
    final ext = fileName.contains('.') ? fileName.split('.').last : '';

    return SupabaseFile._(
      path: filePath,
      name: fileName,
      extension: ext,
    );
  }
}
