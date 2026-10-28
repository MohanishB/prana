import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/dosha_models.dart';

/// The Prakriti result, as on the website, with a way to book a consultation.
class DoshaQuizResultScreen extends StatelessWidget {
  const DoshaQuizResultScreen({required this.result, super.key});

  final DoshaResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.doshaQuiz,
        showBack: true,
        onBack: () => context.goNamed(RouteNames.account),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.doshaHi(result.studentName),
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.doshaYourDosha(result.title),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final section in result.sections) ...[
                if (section.heading != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(section.heading!, style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                ],
                for (final paragraph in section.paragraphs) ...[
                  Text(paragraph, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(result.adviceHeading,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        result.adviceNote,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SelectableText(result.adviceEmail),
                      SelectableText(result.advicePhone),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () => context.goNamed(RouteNames.consult),
                        child: Text(l10n.bookConsultation),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () =>
                    context.pushReplacementNamed(RouteNames.doshaQuiz),
                child: Text(l10n.doshaRetake),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
