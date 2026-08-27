import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_names.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'prana_logo.dart';

class PranaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PranaAppBar({
    super.key,
    this.title,
    this.showBack = false,
  });

  final String? title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: AppSizes.appBarHeight + AppSpacing.xl,
      leading: showBack
          ? IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.chevron_left),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : const Padding(
              padding: EdgeInsets.only(left: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: PranaLogo(),
              ),
            ),
      title: Text(title ?? ''),
      actions: [
        IconButton.filled(
          onPressed: () => context.goNamed(RouteNames.account),
          icon: const Icon(Icons.person_outline),
          tooltip: context.l10n.account,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }
}
