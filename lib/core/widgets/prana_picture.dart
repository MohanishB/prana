import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'prana_logo.dart';

/// A network picture that shows the Prana logo on a soft background when there
/// is no [imageUrl], or when the picture cannot be loaded.
///
/// The widget fills the space it is given; wrap it in a [SizedBox] / [AspectRatio]
/// and a [ClipRRect] for the size and the corners.
class PranaPicture extends StatelessWidget {
  const PranaPicture({required this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return const PranaPicturePlaceholder();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const PranaPicturePlaceholder(),
    );
  }
}

/// The Prana logo centred on a soft background, scaled to fit any size.
class PranaPicturePlaceholder extends StatelessWidget {
  const PranaPicturePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.xs),
        child: FittedBox(fit: BoxFit.contain, child: PranaLogo(height: 96)),
      ),
    );
  }
}
