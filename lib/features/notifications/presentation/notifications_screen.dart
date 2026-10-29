import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/notifications_cubit.dart';
import '../data/notification_models.dart';
import 'notification_navigation.dart';

/// The inbox: messages from Prana (payment received, program started, ...).
/// Unread messages are bold with a dot; tapping one marks it read and opens the
/// screen it is about.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.notifications,
        showBack: true,
        actions: [
          IconButton(
            onPressed: context.read<NotificationsCubit>().markAllRead,
            icon: const Icon(Icons.done_all),
            tooltip: l10n.markAllRead,
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          final Widget body;
          if (state.messages.isNotEmpty) {
            body = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final message in state.messages)
                  _MessageCard(message: message),
                if (state.hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: state.loadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : TextButton(
                            onPressed: context.read<NotificationsCubit>().loadMore,
                            child: Text(l10n.notificationsLoadMore),
                          ),
                  ),
              ],
            );
          } else if (state.error != null) {
            body = AppErrorView(
              message: state.error!.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<NotificationsCubit>().load,
            );
          } else if (!state.loaded) {
            body = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Text(l10n.noNotifications, textAlign: TextAlign.center),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<NotificationsCubit>().load,
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

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final InboxMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !message.isRead;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          context.read<NotificationsCubit>().markRead(message);
          openInboxRoute(context, message.route);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.notifications_none),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (message.body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(message.body, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _ago(context, message.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs, top: 6),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _ago(BuildContext context, DateTime? time) {
  if (time == null) return '';
  final l10n = context.l10n;
  final age = DateTime.now().difference(time);
  if (age.inMinutes < 1) return l10n.timeJustNow;
  if (age.inMinutes < 60) return l10n.timeMinutesAgo(age.inMinutes);
  if (age.inHours < 24) return l10n.timeHoursAgo(age.inHours);
  return DateFormat('d MMM y').format(time);
}
