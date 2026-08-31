import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/app_error_localization.dart';
import '../files/downloadable_file.dart';
import '../files/file_download_cubit.dart';
import '../files/file_download_service.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_sizes.dart';

class DownloadableFileTile extends StatelessWidget {
  const DownloadableFileTile({
    required this.file,
    required this.service,
    this.leading,
    this.subtitle,
    super.key,
  });

  final DownloadableFile file;
  final FileDownloadService service;
  final Widget? leading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FileDownloadCubit(service, file)..check(),
      child: BlocConsumer<FileDownloadCubit, FileDownloadState>(
        listener: (context, state) {
          if (state case FileDownloadFailure(:final error)) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(error.userMessage(context))),
              );
          }
        },
        builder: (context, state) {
          final downloaded =
              state is FileDownloadReady && state.downloaded;
          final busy =
              state is FileDownloadChecking || state is FileDownloading;

          return ListTile(
            leading: leading,
            title: Text(file.title),
            subtitle: Text(
              subtitle ??
                  (downloaded
                      ? context.l10n.downloadedOpenFile
                      : context.l10n.tapToDownloadAndOpen),
            ),
            trailing: _TrailingState(state: state),
            enabled: !busy,
            onTap: busy
                ? null
                : context.read<FileDownloadCubit>().downloadOrOpen,
          );
        },
      ),
    );
  }
}

class _TrailingState extends StatelessWidget {
  const _TrailingState({required this.state});

  final FileDownloadState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      FileDownloadChecking() => const SizedBox.square(
          dimension: AppSizes.loadingIndicatorSmall,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      FileDownloading(:final progress) => SizedBox.square(
          dimension: AppSizes.loadingIndicatorSmall,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
          ),
        ),
      FileDownloadReady(:final downloaded) => Icon(
          downloaded ? Icons.open_in_new : Icons.download_outlined,
          semanticLabel:
              downloaded ? context.l10n.openFile : context.l10n.downloadFile,
        ),
      FileDownloadFailure() => Icon(
          Icons.refresh,
          semanticLabel: context.l10n.retry,
        ),
    };
  }
}
