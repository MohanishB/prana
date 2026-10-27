import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';

/// Section title row used on Home and the tabs (same look as "Keep going").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// One bookable item: masterclass, consultation or Gut Reset program.
class OfferCard extends StatelessWidget {
  const OfferCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon, size: AppSizes.iconSmall)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(price, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stacks cards with a gap between them.
class CardColumn extends StatelessWidget {
  const CardColumn({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
