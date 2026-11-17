import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/prakriti_models.dart';

/// The Prakriti result: three percentage bars, the body type, every text
/// section, the doctors' contact lines and a way to book a consultation.
class PrakritiResultView extends StatelessWidget {
  const PrakritiResultView({
    required this.result,
    required this.onRetake,
    super.key,
  });

  final PrakritiResult result;
  final VoidCallback onRetake;

  String? _date(BuildContext context) {
    final parsed = DateTime.tryParse(result.takenAt.replaceFirst(' ', 'T'));
    if (parsed == null) return null;
    return MaterialLocalizations.of(context).formatMediumDate(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final taken = _date(context);
    final sections = <(String, String)>[
      (l10n.prakritiStrengths, result.strengths),
      (l10n.prakritiWatchOuts, result.watchOuts),
      (l10n.prakritiFood, result.food),
      (l10n.prakritiRoutine, result.routine),
      (l10n.prakritiMovementMind, result.movementMind),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prakritiYourBodyType.toUpperCase(),
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          result.displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        if (result.title.isNotEmpty)
          Text(
            result.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        if (taken != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.prakritiTakenOn(taken),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Bar(label: l10n.prakritiVata, percent: result.vata),
        _Bar(label: l10n.prakritiPitta, percent: result.pitta),
        _Bar(label: l10n.prakritiKapha, percent: result.kapha),
        const SizedBox(height: AppSpacing.md),
        if (result.elements.isNotEmpty)
          Text(result.elements, style: theme.textTheme.bodyMedium),
        if (result.summary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(result.summary, style: theme.textTheme.bodyMedium),
        ],
        for (final s in sections)
          if (s.$2.trim().isNotEmpty) _Section(heading: s.$1, body: s.$2),
        if (result.doshasText.trim().isNotEmpty)
          _Section(
            heading: l10n.prakritiWhatAreDoshas,
            body: result.doshasText,
          ),
        if (result.footerText.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            result.footerText,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
        if (result.pranaPlan.trim().isNotEmpty)
          _Section(heading: l10n.prakritiPranaPlan, body: result.pranaPlan),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(result.adviceHeading, style: theme.textTheme.titleSmall),
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
        TextButton(onPressed: onRetake, child: Text(l10n.prakritiRetake)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.labelLarge),
              Text('$percent%', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percent.clamp(0, 100)) / 100,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
