import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/files/downloadable_file.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/downloadable_file_tile.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/prana_logo.dart';
import '../../../core/widgets/responsive_content.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({
    required this.certificateId,
    this.title,
    this.downloadUrl,
    this.generatedOn,
    super.key,
  });

  final String certificateId;
  final String? title;
  final String? downloadUrl;
  final String? generatedOn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final certificateTitle = title?.trim().isNotEmpty == true
        ? title!.trim()
        : l10n.masterclass;
    final remoteUrl = downloadUrl?.trim() ?? '';

    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.certificate,
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          maxWidth: AppSizes.certificateMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: AppColors.gold),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    const PranaLogo(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.certificateCompletion,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing:
                                AppTypography.certificateLetterSpacing,
                            color: AppColors.slate,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: AppSizes.iconLarge,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      certificateTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (generatedOn?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.certificateGeneratedOn(generatedOn!.trim()),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (remoteUrl.isNotEmpty)
                Card(
                  child: DownloadableFileTile(
                    service:
                        context.read<AppDependencies>().fileDownloadService,
                    file: DownloadableFile(
                      id: 'certificate_$certificateId',
                      title: l10n.certificatePdf,
                      remoteUrl: remoteUrl,
                      folder: 'certificates',
                    ),
                    leading: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.brick,
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(l10n.certificateApiUnavailable),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
