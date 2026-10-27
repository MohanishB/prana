import 'package:flutter/material.dart';

/// The Prana by Dimple Jangda logo. The artwork has a white wordmark for the
/// dark theme and a forest green wordmark for the light theme.
class PranaLogo extends StatelessWidget {
  const PranaLogo({super.key, this.compact = false, this.height});

  /// Smaller logo (app bar). Ignored when [height] is given.
  final bool compact;
  final double? height;

  static const _darkAsset = 'assets/images/prana_logo.png';
  static const _lightAsset = 'assets/images/prana_logo_light.png';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'PRANA by Dimple Jangda',
      image: true,
      child: Image.asset(
        dark ? _darkAsset : _lightAsset,
        height: height ?? (compact ? 44 : 96),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}
