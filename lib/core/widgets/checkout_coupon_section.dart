import 'package:flutter/material.dart';

import '../checkout/checkout_models.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_spacing.dart';

/// Coupon entry for a checkout. The screen decides WHEN to show it; this widget
/// shows the input with Apply, a wrong code with its error (and a bin to clear
/// it), or the applied coupon with a bin to remove it.
class CheckoutCouponSection extends StatelessWidget {
  const CheckoutCouponSection({
    required this.controller,
    required this.coupon,
    required this.busy,
    required this.onApply,
    required this.onRemove,
    super.key,
  });

  final TextEditingController controller;

  /// The coupon of the latest price check (null = none tried).
  final CheckoutCoupon? coupon;

  /// The price is being checked: Apply waits.
  final bool busy;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final applied = coupon;
    if (applied != null && applied.valid) {
      return _AppliedCoupon(coupon: applied, onRemove: onRemove);
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onApply(),
                decoration: InputDecoration(
                  labelText: l10n.couponCode,
                  prefixIcon: const Icon(Icons.sell_outlined),
                  // A wrong code can be cleared again.
                  suffixIcon: applied == null
                      ? null
                      : IconButton(
                          tooltip: l10n.removeCoupon,
                          onPressed: onRemove,
                          icon: const Icon(Icons.delete_outline),
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // The theme makes buttons full width; inside a Row they need a
            // fixed width.
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
                onPressed: busy ? null : onApply,
                child: Text(l10n.applyCoupon),
              ),
            ),
          ],
        ),
        if (applied != null && applied.message.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            applied.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// The applied coupon: its name and a bin to remove it (like the website).
class _AppliedCoupon extends StatelessWidget {
  const _AppliedCoupon({required this.coupon, required this.onRemove});

  final CheckoutCoupon coupon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final text = coupon.description.isEmpty
        ? coupon.code
        : '${coupon.code} · ${coupon.description}';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(Icons.sell_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${l10n.couponCode}: $text',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.removeCoupon,
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
