import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_x.dart';
import '../../../../core/theme/app_spacing.dart';

class CourseNavigationButtons extends StatelessWidget {
  const CourseNavigationButtons({
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: Text(l10n.previous),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.next),
                const SizedBox(width: AppSpacing.xxs),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
