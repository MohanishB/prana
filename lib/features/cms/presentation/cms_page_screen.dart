import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/external_link.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/html_content.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/cms_page_cubit.dart';
import '../data/cms_models.dart';

/// Account -> Contact support / Terms & privacy: the heading and text written in the
/// admin; the Contact support page also shows the contact buttons and social links.
class CmsPageScreen extends StatelessWidget {
  const CmsPageScreen({required this.pageKey, super.key});

  final CmsPageKey pageKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (pageKey) {
      CmsPageKey.contactSupport => l10n.contactSupport,
      CmsPageKey.termsPrivacy => l10n.termsPrivacy,
    };
    return Scaffold(
      appBar: PranaAppBar(title: title, showBack: true),
      body: BlocBuilder<CmsPageCubit, CmsPageState>(
        builder: (context, state) {
          final page = state.page;
          final Widget body;
          if (page != null) {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: page.hasContent
                  ? _PageBody(page: page)
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Text(
                        l10n.cmsComingSoon,
                        textAlign: TextAlign.center,
                      ),
                    ),
            );
          } else if (state.error != null) {
            body = AppErrorView(
              message: state.error!.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<CmsPageCubit>().load,
            );
          } else {
            body = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<CmsPageCubit>().load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContent(child: body),
            ),
          );
        },
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final CmsPage page;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final contact = page.contact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (page.heading.isNotEmpty) ...[
          Text(
            page.heading,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (page.contentHtml.trim().isNotEmpty)
          HtmlContent(page.contentHtml),
        if (contact != null && !contact.isEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (contact.email.isNotEmpty)
                  _ContactTile(
                    icon: Icons.mail_outline,
                    title: l10n.contactEmail,
                    subtitle: contact.email,
                    url: contact.emailLink,
                  ),
                if (contact.mobile.isNotEmpty)
                  _ContactTile(
                    icon: Icons.phone_outlined,
                    title: l10n.contactCall,
                    subtitle: contact.mobile,
                    url: contact.phoneLink,
                  ),
                if (contact.whatsappNumber.isNotEmpty)
                  _ContactTile(
                    icon: Icons.chat_outlined,
                    title: l10n.contactWhatsapp,
                    subtitle: contact.whatsappNumber,
                    url: contact.whatsappLink,
                  ),
                if (contact.website.isNotEmpty)
                  _ContactTile(
                    icon: Icons.language,
                    title: l10n.contactWebsite,
                    subtitle: contact.website,
                    url: contact.website,
                  ),
              ],
            ),
          ),
        ],
        if (page.socialLinks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.contactFollowUs,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          _SocialLinksGrid(links: page.socialLinks),
        ],
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.url,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openExternalLink(context, url),
      );
}

/// Round logo buttons spread evenly across the full width: up to 4 equal columns,
/// more links wrap onto new rows and a short last row is centred.
class _SocialLinksGrid extends StatelessWidget {
  const _SocialLinksGrid({required this.links});

  static const _maxColumns = 4;

  final List<SocialLink> links;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              links.length < _maxColumns ? links.length : _maxColumns;
          // rounded down so a full row never wraps early
          final cellWidth = (constraints.maxWidth / columns).floorToDouble();
          return Wrap(
            alignment: WrapAlignment.center,
            runSpacing: AppSpacing.md,
            children: [
              for (final link in links)
                SizedBox(
                  width: cellWidth,
                  child: _SocialButton(link: link),
                ),
            ],
          );
        },
      );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.link});

  final SocialLink link;

  // The platforms' own brand colours (not part of the app theme).
  static const _brandColors = <SocialPlatform, Color>{
    SocialPlatform.instagram: Color(0xFFE4405F),
    SocialPlatform.facebook: Color(0xFF0866FF),
    SocialPlatform.youtube: Color(0xFFFF0000),
    SocialPlatform.x: Color(0xFF000000),
    SocialPlatform.linkedin: Color(0xFF0A66C2),
    SocialPlatform.telegram: Color(0xFF26A5E4),
    SocialPlatform.pinterest: Color(0xFFBD081C),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = link.platform.logoAsset;
    final brand = _brandColors[link.platform] ?? theme.colorScheme.secondary;
    return Semantics(
      button: true,
      label: link.label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => openExternalLink(context, link.url),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.socialButton,
                height: AppSizes.socialButton,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: brand,
                  shape: BoxShape.circle,
                  // keeps the black X button visible on the dark theme
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: asset == null
                    ? const Icon(
                        Icons.link,
                        color: Colors.white,
                        size: AppSizes.socialIcon,
                      )
                    : Image.asset(
                        asset,
                        width: AppSizes.socialIcon,
                        height: AppSizes.socialIcon,
                      ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                link.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
