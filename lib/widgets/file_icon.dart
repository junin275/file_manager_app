import 'package:flutter/material.dart';
import '../models/file_item.dart';

class FileIcon extends StatelessWidget {
  final FileItem item;
  final double size;
  final bool isSelected;

  const FileIcon({
    super.key,
    required this.item,
    this.size = 40,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = _getIconData();
    final iconColor = _getIconColor(colorScheme);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, size: size * 0.6, color: iconColor),
    );
  }

  IconData _getIconData() {
    switch (item.fileType) {
      case FileType.folder:
        return Icons.folder_rounded;
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.videocam_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.zip:
        return Icons.archive_rounded;
      case FileType.text:
        return Icons.description_rounded;
      case FileType.code:
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    switch (item.fileType) {
      case FileType.folder:
        return colorScheme.primary;
      case FileType.image:
        return Colors.green.shade600;
      case FileType.video:
        return Colors.red.shade600;
      case FileType.audio:
        return Colors.purple.shade600;
      case FileType.pdf:
        return Colors.red.shade600;
      case FileType.zip:
        return colorScheme.primary;
      case FileType.text:
        return colorScheme.primary;
      case FileType.code:
        return colorScheme.primary;
      default:
        return colorScheme.outline;
    }
  }
}