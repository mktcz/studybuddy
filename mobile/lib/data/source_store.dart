import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


class SourceStore {
  const SourceStore();

  static const _folder = 'sources';

  Future<Directory> _directory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _folder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }


  Future<String> import(File file, String sourceId) async {
    final dir = await _directory();
    final target = File(p.join(dir.path, '$sourceId.pdf'));
    await file.copy(target.path);
    return target.path;
  }


  Future<void> remove(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  Future<bool> existsAsync(String filePath) => File(filePath).exists();

  Future<int> sizeOf(String filePath) async {
    final file = File(filePath);
    return await file.exists() ? file.length() : 0;
  }

  Future<void> deleteAll() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _folder));
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
