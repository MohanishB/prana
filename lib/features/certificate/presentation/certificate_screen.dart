import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/prana_logo.dart';
import '../../../core/widgets/responsive_content.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({required this.certificateId, super.key});

  final String certificateId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing:
                                AppTypography.certificateLetterSpacing,
                            color: AppColors.slate,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.certificateRecipient,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l10n.certificateCompletedMasterclass),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.ayurvedaHerbalism,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.certificateDateIssuer,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.certificateId(certificateId),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.certificateApiUnavailable)),
                ),
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.downloadPdf),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(l10n.share),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.certificateNameNotice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
