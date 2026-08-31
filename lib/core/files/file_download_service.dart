import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/app_exception.dart';
import '../network/network_info.dart';
import 'downloadable_file.dart';

abstract interface class FileDownloadService {
  Future<bool> isDownloaded(DownloadableFile file);

  Future<File> download(
    DownloadableFile file, {
    void Function(double progress)? onProgress,
  });

  Future<void> open(DownloadableFile file);
}

final class LocalFileDownloadService implements FileDownloadService {
  LocalFileDownloadService({required NetworkInfo networkInfo})
      : _networkInfo = networkInfo;

  final NetworkInfo _networkInfo;

  @override
  Future<bool> isDownloaded(DownloadableFile file) async {
    final target = await _targetFile(file);
    return target.exists();
  }

  @override
  Future<File> download(
    DownloadableFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final target = await _targetFile(file);

    // The local file is authoritative for offline availability. This prevents
    // repeated downloads and also allows the user to open saved files offline.
    if (await target.exists()) {
      return target;
    }

    if (!await _networkInfo.isConnected) {
      throw const AppException(AppErrorType.noInternet);
    }

    final uri = Uri.tryParse(file.remoteUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw const AppException(AppErrorType.downloadFailed);
    }

    final parent = target.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    final partial = File('${target.path}.part');
    if (await partial.exists()) {
      await partial.delete();
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);

    try {
      final request = await client.getUrl(uri).timeout(
            const Duration(seconds: 20),
          );
      final response = await request.close().timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode < HttpStatus.ok ||
          response.statusCode >= HttpStatus.multipleChoices) {
        throw const AppException(AppErrorType.downloadFailed);
      }

      final sink = partial.openWrite();
      final total = response.contentLength;
      var received = 0;

      try {
        await for (final chunk in response.timeout(const Duration(seconds: 45))) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0 && onProgress != null) {
            onProgress((received / total).clamp(0.0, 1.0).toDouble());
          }
        }
      } finally {
        await sink.close();
      }

      if (!await partial.exists() || await partial.length() == 0) {
        throw const AppException(AppErrorType.downloadFailed);
      }

      await partial.rename(target.path);
      onProgress?.call(1);
      return target;
    } on AppException {
      if (await partial.exists()) {
        await partial.delete();
      }
      rethrow;
    } on Object catch (error, stackTrace) {
      if (await partial.exists()) {
        await partial.delete();
      }
      throw AppException(
        AppErrorType.downloadFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<void> open(DownloadableFile file) async {
    final target = await _targetFile(file);
    if (!await target.exists()) {
      throw const AppException(AppErrorType.fileNotDownloaded);
    }

    final result = await OpenFilex.open(target.path);
    if (result.type != ResultType.done) {
      throw AppException(
        AppErrorType.fileOpenFailed,
        cause: result.message,
      );
    }
  }

  Future<File> _targetFile(DownloadableFile file) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(
      '${root.path}/prana_downloads/${_safeSegment(file.folder)}',
    );

    final uri = Uri.tryParse(file.remoteUrl);
    final remoteName = uri == null || uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last;
    final extension = _extension(remoteName, file.fallbackExtension);
    final safeId = _safeSegment(file.id);

    return File('${folder.path}/$safeId.$extension');
  }

  String _extension(String fileName, String fallback) {
    final dot = fileName.lastIndexOf('.');
    if (dot >= 0 && dot < fileName.length - 1) {
      final candidate = fileName.substring(dot + 1).toLowerCase();
      if (RegExp(r'^[a-z0-9]{1,8}$').hasMatch(candidate)) {
        return candidate;
      }
    }
    return _safeSegment(fallback).toLowerCase();
  }

  String _safeSegment(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return sanitized.isEmpty ? 'file' : sanitized;
  }
}
