import 'dart:io';

enum FileType {
  folder,
  image,
  video,
  audio,
  pdf,
  zip,
  text,
  code,
  unknown,
}

class FileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime lastModified;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.lastModified,
  });

  factory FileItem.fromFile(File file) {
    return FileItem(
      name: file.path.split('/').last,
      path: file.path,
      isDirectory: file.statSync().type == FileSystemEntityType.directory,
      size: file.lengthSync(),
      lastModified: file.lastModifiedSync(),
    );
  }

  String get displaySize {
    if (isDirectory) return 'Pasta';
    return _formatSize(size);
  }

  FileType get fileType {
    if (isDirectory) return FileType.folder;
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') ||
        lower.endsWith('.gif') || lower.endsWith('.webp') || lower.endsWith('.bmp') ||
        lower.endsWith('.svg') || lower.endsWith('.ico')) {
      return FileType.image;
    }
    if (lower.endsWith('.mp4') || lower.endsWith('.mkv') || lower.endsWith('.avi') ||
        lower.endsWith('.mov') || lower.endsWith('.wmv') || lower.endsWith('.flv') ||
        lower.endsWith('.webm') || lower.endsWith('.3gp')) {
      return FileType.video;
    }
    if (lower.endsWith('.mp3') || lower.endsWith('.wav') || lower.endsWith('.ogg') ||
        lower.endsWith('.flac') || lower.endsWith('.aac') || lower.endsWith('.m4a') ||
        lower.endsWith('.wma')) {
      return FileType.audio;
    }
    if (lower.endsWith('.pdf')) return FileType.pdf;
    if (lower.endsWith('.zip') || lower.endsWith('.rar') || lower.endsWith('.7z') ||
        lower.endsWith('.tar') || lower.endsWith('.gz')) return FileType.zip;
    if (lower.endsWith('.txt') || lower.endsWith('.md') || lower.endsWith('.rtf') ||
        lower.endsWith('.log') || lower.endsWith('.csv')) return FileType.text;
    if (lower.endsWith('.kt') || lower.endsWith('.java') || lower.endsWith('.py') ||
        lower.endsWith('.js') || lower.endsWith('.ts') || lower.endsWith('.html') ||
        lower.endsWith('.css') || lower.endsWith('.xml') || lower.endsWith('.json') ||
        lower.endsWith('.dart') || lower.endsWith('.swift') || lower.endsWith('.go') ||
        lower.endsWith('.rs') || lower.endsWith('.cpp') || lower.endsWith('.c') ||
        lower.endsWith('.h') || lower.endsWith('.rb') || lower.endsWith('.php') ||
        lower.endsWith('.sql')) return FileType.code;
    return FileType.unknown;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItem && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}