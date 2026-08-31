import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class VideoProgressStore {
  Future<Duration> read(String videoId);

  Future<void> write(String videoId, Duration position);

  Future<void> clear(String videoId);
}

final class LocalVideoProgressStore implements VideoProgressStore {
  static const String _fileName = 'video_progress.json';

  @override
  Future<Duration> read(String videoId) async {
    final map = await _readAll();
    final milliseconds = map[videoId];
    if (milliseconds is! int || milliseconds < 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: milliseconds);
  }

  @override
  Future<void> write(String videoId, Duration position) async {
    final map = await _readAll();
    map[videoId] = position.inMilliseconds;
    await _writeAll(map);
  }

  @override
  Future<void> clear(String videoId) async {
    final map = await _readAll();
    if (map.remove(videoId) != null) {
      await _writeAll(map);
    }
  }

  Future<Map<String, dynamic>> _readAll() async {
    final file = await _storageFile();
    if (!await file.exists()) {
      return <String, dynamic>{};
    }

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on Object {
      // A corrupt local progress file should never block playback.
    }

    return <String, dynamic>{};
  }

  Future<void> _writeAll(Map<String, dynamic> values) async {
    final file = await _storageFile();
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    final temporary = File('${file.path}.part');
    await temporary.writeAsString(jsonEncode(values), flush: true);

    if (await file.exists()) {
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  Future<File> _storageFile() async {
    final root = await getApplicationDocumentsDirectory();
    return File('${root.path}/prana/$_fileName');
  }
}
