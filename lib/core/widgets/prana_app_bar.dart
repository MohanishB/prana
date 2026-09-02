import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_names.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'prana_logo.dart';
import 'session_avatar.dart';

class PranaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PranaAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: showBack
          ? AppSizes.appBarHeight
          : AppSizes.appBarHeight + AppSpacing.xl,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? () => context.pop(),
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
      title: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          onPressed: () => context.goNamed(RouteNames.account),
          tooltip: context.l10n.account,
          icon: const SessionAvatar(),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
