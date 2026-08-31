import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.myAccount),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.white,
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(l10n.accountUserName),
                  subtitle: Text(l10n.accountContact),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _AccountGroup(
                children: [
                  _AccountTile(
                    icon: Icons.calendar_month_outlined,
                    title: l10n.bookedConsultations,
                    onTap: () => context.goNamed(RouteNames.consult),
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
              _AccountGroup(
                children: [
                  _AccountTile(
                    icon: Icons.help_outline,
                    title: l10n.faqs,
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
                  onChanged: (_) => context.read<ThemeCubit>().toggle(context),
                ),
              ),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.copyright,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
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
