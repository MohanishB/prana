import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/live_sessions_cubit.dart';
import '../data/live_session_models.dart';

/// Account -> Live Q&A sessions: the sessions that are running or still to come,
/// each with its text, its time and a button that opens the session link in the browser.
class LiveSessionsScreen extends StatelessWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: PranaAppBar(title: l10n.liveQaSessions, showBack: true),
      body: BlocBuilder<LiveSessionsCubit, LiveSessionsState>(
        builder: (context, state) {
          final Widget body;
          final now = state.now ?? DateTime.now();
          // A session whose end time has passed leaves the list without a refresh.
          final sessions = state.sessions
              .where((s) => s.end == null || now.isBefore(s.end!))
              .toList(growable: false);
          if (sessions.isNotEmpty) {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final session in sessions)
                    _SessionCard(session: session, now: now),
                ],
              ),
            );
          } else if (state.error != null) {
            body = AppErrorView(
              message: state.error!.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<LiveSessionsCubit>().load,
            );
          } else if (!state.loaded) {
            body = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            body = Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.noLiveSessionsAvailable,
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<LiveSessionsCubit>().load,
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.now});

  final LiveSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final when = _whenText(session);
    final start = session.start;
    final end = session.end;
    // Join is active only from the start time until the end time.
    final live = start != null &&
        end != null &&
        !now.isBefore(start) &&
        now.isBefore(end);
    final opensAt = !live && start != null && now.isBefore(start)
        ? DateFormat('EEE, d MMM · h:mm a').format(start)
        : null;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (when != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      when,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            if (session.title.isNotEmpty) ...[
              if (when != null) const SizedBox(height: AppSpacing.sm),
              Text(
                session.title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (session.text.isNotEmpty) ...[
              if (when != null || session.title.isNotEmpty)
                const SizedBox(height: AppSpacing.xs),
              Text(session.text, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: live ? () => _open(context) : null,
              child: Text(session.buttonText),
            ),
            if (opensAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.liveSessionJoinOpens(opensAt),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(session.buttonUrl);
    var opened = false;
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Object {
        opened = false;
      }
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
    }
  }
}

/// "Thu, 12 Nov · 7:00 PM – 8:00 PM", or both dates when the session crosses midnight.
String? _whenText(LiveSession session) {
  final start = session.start;
  final end = session.end;
  if (start == null) return null;
  final day = DateFormat('EEE, d MMM');
  final time = DateFormat('h:mm a');
  if (end == null) return '${day.format(start)} · ${time.format(start)}';
  final sameDay = start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  if (sameDay) {
    return '${day.format(start)} · ${time.format(start)} – ${time.format(end)}';
  }
  return '${day.format(start)} · ${time.format(start)} – '
      '${day.format(end)} · ${time.format(end)}';
}
