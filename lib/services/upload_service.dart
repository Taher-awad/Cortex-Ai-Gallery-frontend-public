import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';

class UploadService {
  final ApiService _apiService;
  StreamSubscription? _subscription;
  final List<String> _validExtensions = ['.jpg', '.jpeg', '.png', '.mp4', '.mov'];

  UploadService(this._apiService);

  void startWatching(String path) {
    stopWatching();
    final watcher = DirectoryWatcher(path);
    _subscription = watcher.events.listen((event) {
      if (event.type == ChangeType.ADD) {
        _handleNewFile(File(event.path));
      }
    });
    print("👀 Started watching folder: $path");
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    print("🛑 Stopped watching folder.");
  }

  Future<void> _handleNewFile(File file) async {
    if (!_validExtensions.contains(p.extension(file.path).toLowerCase())) return;

    print("✨ New file detected: ${file.path}");
    final hash = await _calculateHash(file);
    final neededHashes = await _apiService.checkHashes([hash]);

    if (neededHashes.contains(hash)) {
      print("🚀 Uploading new file: ${file.path}");
      await _apiService.uploadFiles([file]);
    } else {
      print("✅ File already exists on server (hash: ${hash.substring(0, 8)}...)");
    }
  }

  Future<String> _calculateHash(File file) async {
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    return hash.toString();
  }
}