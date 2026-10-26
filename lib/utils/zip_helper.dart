import 'dart:io';
import 'package:archive/archive.dart';

class ZipHelper {
  static Future<bool> compress(List<File> files, File outputZip) async {
    try {
      final archive = Archive();
      for (final file in files) {
        await _addToArchive(archive, file, file.path.split('/').last);
      }
      final encoder = ZipEncoder();
      final data = encoder.encode(archive);
      await outputZip.writeAsBytes(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _addToArchive(Archive archive, FileSystemEntity entity, String entryName) async {
    final stat = await entity.stat();
    if (stat.type == FileSystemEntityType.directory) {
      final dir = Directory(entity.path);
      final children = dir.listSync();
      for (final child in children) {
        await _addToArchive(archive, child, '$entryName/${child.path.split('/').last}');
      }
    } else {
      final file = File(entity.path);
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
    }
  }

  static Future<bool> decompress(File zipFile, Directory destDir) async {
    try {
      await destDir.create(recursive: true);
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final targetFile = File('${destDir.path}/${file.name}');
        if (file.isFile) {
          await targetFile.parent.create(recursive: true);
          await targetFile.writeAsBytes(file.content as List<int>);
        } else {
          await targetFile.create(recursive: true);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}