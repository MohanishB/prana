import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_typography.dart';

class PranaLogo extends StatelessWidget {
  const PranaLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'PRANA',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.eco_outlined,
            color: AppColors.gold,
            size: AppSizes.iconMedium,
          ),
          if (!compact)
            Text(
              'PRĀNA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: AppTypography.brandLetterSpacing,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        ],
      ),
    );
  }
}
