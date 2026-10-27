import 'package:flutter/material.dart';

import '../errors/app_error_localization.dart';
import '../errors/app_exception.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_error_view.dart';
import 'html_rich_text.dart';
import 'prana_app_bar.dart';
import 'responsive_content.dart';

/// Shared page frame for the offer pages: app bar with back, loading,
/// error with retry, and the scrolling content.
class OfferPageScaffold extends StatelessWidget {
  const OfferPageScaffold({
    required this.title,
    required this.loading,
    required this.error,
    required this.hasData,
    required this.onRetry,
    required this.content,
    super.key,
    this.actions = const [],
    this.bottomBar,
  });

  final String title;
  final bool loading;
  final AppException? error;
  final bool hasData;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context) content;

  /// Extra app bar buttons (for example the masterclass cart).
  final List<Widget> actions;

  /// Always-visible bar at the bottom (for example Buy now / Add to cart).
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (hasData) {
      body = SingleChildScrollView(
        child: ResponsiveContent(child: content(context)),
      );
    } else if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = AppErrorView(
        message: error!.userMessage(context),
        retryLabel: context.l10n.retry,
        onRetry: onRetry,
      );
    } else {
      body = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: PranaAppBar(title: title, showBack: true, actions: actions),
      body: body,
      bottomNavigationBar: bottomBar == null
          ? null
          : Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: bottomBar,
                ),
              ),
            ),
    );
  }
}

class OfferBanner extends StatelessWidget {
  const OfferBanner({required this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 160,
        child: url == null
            ? ColoredBox(color: scheme.primaryContainer)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    ColoredBox(color: scheme.primaryContainer),
              ),
      ),
    );
  }
}

/// A titled block of server HTML (description, about us, terms). Hidden when empty.
class OfferHtmlSection extends StatelessWidget {
  const OfferHtmlSection({required this.title, required this.html, super.key});

  final String title;
  final String html;

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.trim().isNotEmpty) ...[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
          ],
          HtmlRichText(html),
        ],
      ),
    );
  }
}
