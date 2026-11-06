import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/files/downloadable_file.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/downloadable_file_tile.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/prana_picture.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/my_certificates_cubit.dart';
import '../data/certificate_models.dart';

/// Every certificate generated for the student, newest first. Each row downloads
/// and opens the PDF and is named after the masterclass.
class MyCertificatesScreen extends StatelessWidget {
  const MyCertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: PranaAppBar(title: l10n.myCertificates, showBack: true),
      body: BlocBuilder<MyCertificatesCubit, MyCertificatesState>(
        builder: (context, state) {
          final Widget body;
          if (state.certificates.isNotEmpty) {
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final certificate in state.certificates)
                  _CertificateRow(certificate: certificate),
              ],
            );
          } else if (state.error != null) {
            body = AppErrorView(
              message: state.error!.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<MyCertificatesCubit>().load,
            );
          } else if (!state.loaded) {
            body = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.noCertificateGeneratedYet,
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<MyCertificatesCubit>().load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContent(child: body),
            ),
          );
        },
      ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.certificate});

  final StudentCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final raw = certificate.generatedOn;
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    final date = raw == null
        ? null
        : parsed == null
            ? raw
            : DateFormat('d MMM y').format(parsed);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DownloadableFileTile(
        service: context.read<AppDependencies>().fileDownloadService,
        file: DownloadableFile(
          id: 'certificate_${certificate.courseId}',
          title: certificate.title,
          remoteUrl: certificate.downloadUrl,
          folder: 'certificates',
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox.square(
            dimension: AppSizes.offerImage,
            child: PranaPicture(imageUrl: certificate.imageUrl),
          ),
        ),
        caption: date == null
            ? null
            : context.l10n.certificateGeneratedOn(date),
      ),
    );
  }
}
