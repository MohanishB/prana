import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/account_profile_cubit.dart';
import '../data/account_models.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // A guest has no profile, purchases or certificates: show a sign-in card instead.
    final guest = context.watch<AuthBloc>().state is AuthGuest;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.myAccount),
      body: RefreshIndicator(
        onRefresh:
            guest ? () async {} : context.read<AccountProfileCubit>().load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              children: [
                if (guest)
                  const _GuestCard()
                else
                  BlocBuilder<AccountProfileCubit, AccountProfileState>(
                  builder: (context, state) {
                    return switch (state) {
                      AccountProfileLoading() => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      AccountProfileFailure(:final error) => Card(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(AppSpacing.md),
                            leading: const Icon(Icons.error_outline),
                            title: Text(error.userMessage(context)),
                            trailing: TextButton(
                              onPressed:
                                  context.read<AccountProfileCubit>().load,
                              child: Text(l10n.retry),
                            ),
                          ),
                        ),
                      AccountProfileLoaded(:final profile) =>
                        _ProfileCard(profile: profile),
                    };
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (!guest) ...[
                  _AccountGroup(
                    children: [
                      _AccountTile(
                        icon: Icons.lock_outline,
                        title: l10n.changePassword,
                        onTap: () => context.pushNamed(RouteNames.changePassword),
                      ),
                      _AccountTile(
                        icon: Icons.calendar_month_outlined,
                        title: l10n.bookedConsultations,
                        onTap: () => context.pushNamed(RouteNames.myConsultations),
                      ),
                      _AccountTile(
                        icon: Icons.monitor_heart_outlined,
                        title: l10n.liveQaSessions,
                      ),
                      _AccountTile(
                        icon: Icons.workspace_premium_outlined,
                        title: l10n.myCertificates,
                        onTap: () => context.pushNamed(
                          RouteNames.certificate,
                          pathParameters: const {'certificateId': 'ah-4821'},
                        ),
                      ),
                      _AccountTile(
                        icon: Icons.notifications_none,
                        title: l10n.reminders,
                        subtitle: l10n.dailyAtSix,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _AccountGroup(
                  children: [
                    // The Dosha quiz and FAQs are public: guests can open them too.
                    _AccountTile(
                      icon: Icons.spa_outlined,
                      title: l10n.doshaQuiz,
                      subtitle: l10n.doshaQuizSubtitle,
                      onTap: () => context.pushNamed(RouteNames.doshaQuiz),
                    ),
                    _AccountTile(
                      icon: Icons.help_outline,
                      title: l10n.faqs,
                      onTap: () => context.pushNamed(RouteNames.faqs),
                    ),
                    _AccountTile(
                      icon: Icons.mail_outline,
                      title: l10n.contactSupport,
                    ),
                    _AccountTile(
                      icon: Icons.description_outlined,
                      title: l10n.termsPrivacy,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.darkMode),
                    subtitle: Text(l10n.darkModeDescription),
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (_) =>
                        context.read<ThemeCubit>().toggle(context),
                  ),
                ),
                if (!guest) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLogoutRequested(),
                    ),
                    child: Text(
                      l10n.signOut,
                      style: const TextStyle(color: AppColors.brick),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.copyright,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the profile when browsing as a guest.
class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: AppSizes.avatarSmall / 2,
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.white,
                child: Icon(Icons.person_outline),
              ),
              title: Text(l10n.guestAccountTitle),
              subtitle: Text(l10n.guestAccountSubtitle),
            ),
            const SizedBox(height: AppSpacing.xs),
            FilledButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthLoginRequested()),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final AccountProfile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photoUrl;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: CircleAvatar(
          radius: AppSizes.avatarSmall / 2,
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          backgroundImage:
              photoUrl == null ? null : NetworkImage(photoUrl),
          child: photoUrl == null ? const Icon(Icons.person_outline) : null,
        ),
        title: Text(profile.fullName),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.email.isNotEmpty) Text(profile.email),
              if (profile.formattedPhone.isNotEmpty)
                Text(profile.formattedPhone),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final updated = await context.pushNamed<bool>(
            RouteNames.editProfile,
            extra: profile,
          );
          if (updated == true && context.mounted) {
            await context.read<AccountProfileCubit>().load();
          }
        },
      ),
    );
  }
}

class _AccountGroup extends StatelessWidget {
  const _AccountGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: AppSpacing.xxs,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(icon, size: AppSizes.iconSmall),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
