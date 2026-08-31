import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/app_exception.dart';
import 'downloadable_file.dart';
import 'file_download_service.dart';

sealed class FileDownloadState {
  const FileDownloadState();
}

final class FileDownloadChecking extends FileDownloadState {
  const FileDownloadChecking();
}

final class FileDownloadReady extends FileDownloadState {
  const FileDownloadReady({required this.downloaded});

  final bool downloaded;
}

final class FileDownloading extends FileDownloadState {
  const FileDownloading(this.progress);

  final double? progress;
}

final class FileDownloadFailure extends FileDownloadState {
  const FileDownloadFailure(this.error);

  final AppException error;
}

final class FileDownloadCubit extends Cubit<FileDownloadState> {
  FileDownloadCubit(this._service, this.file)
      : super(const FileDownloadChecking());

  final FileDownloadService _service;
  final DownloadableFile file;

  Future<void> check() async {
    try {
      emit(
        FileDownloadReady(
          downloaded: await _service.isDownloaded(file),
        ),
      );
    } on Object catch (error, stackTrace) {
      emit(
        FileDownloadFailure(
          AppException(
            AppErrorType.generic,
            cause: error,
            stackTrace: stackTrace,
          ),
        ),
      );
    }
  }

  Future<void> downloadOrOpen() async {
    try {
      if (await _service.isDownloaded(file)) {
        await _service.open(file);
        emit(const FileDownloadReady(downloaded: true));
        return;
      }

      emit(const FileDownloading(null));
      await _service.download(
        file,
        onProgress: (progress) {
          if (!isClosed) emit(FileDownloading(progress));
        },
      );

      await _service.open(file);
      emit(const FileDownloadReady(downloaded: true));
    } on AppException catch (error) {
      emit(FileDownloadFailure(error));
    } on Object catch (error, stackTrace) {
      emit(
        FileDownloadFailure(
          AppException(
            AppErrorType.downloadFailed,
            cause: error,
            stackTrace: stackTrace,
          ),
        ),
      );
    }
  }
}
