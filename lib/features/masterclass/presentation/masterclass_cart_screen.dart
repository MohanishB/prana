import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/masterclass_cart_cubit.dart';
import '../data/masterclass_checkout_models.dart';

/// The masterclass cart: remove items, then go to checkout.
class MasterclassCartScreen extends StatelessWidget {
  const MasterclassCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: PranaAppBar(title: l10n.cart, showBack: true),
      body: BlocBuilder<MasterclassCartCubit, MasterclassCartState>(
        builder: (context, cart) {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 48),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.cartEmpty,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.cartEmptyHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.cartItemsCount(cart.count),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in cart.items) _CartTile(item: item),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.cartPriceNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => context.pushNamed(
                      RouteNames.masterclassCheckout,
                      extra: CheckoutArgs(
                        courseIds: cart.courseIds,
                        mode: CheckoutMode.cart,
                      ),
                    ),
                    child: Text(l10n.proceedToCheckout),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = item.thumbnailUrl;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 72,
                height: 54,
                child: url == null
                    ? ColoredBox(color: theme.colorScheme.primaryContainer)
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: theme.colorScheme.primaryContainer,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(item.price.formatted, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.removeFromCart,
              onPressed: () =>
                  context.read<MasterclassCartCubit>().remove(item.courseId),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
