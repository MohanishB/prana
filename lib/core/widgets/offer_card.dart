import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'prana_picture.dart';

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
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
    this.imageUrl,
    super.key,
  });

  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  /// The picture of the item. Without it (or if it cannot be loaded) the Prana
  /// logo is shown instead.
  final String? imageUrl;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox.square(
                  dimension: AppSizes.offerImage,
                  child: PranaPicture(imageUrl: imageUrl),
                ),
              ),
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
