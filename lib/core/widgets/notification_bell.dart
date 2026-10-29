import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_names.dart';
import '../../features/notifications/bloc/notification_badge_cubit.dart';
import '../localization/app_localizations_x.dart';

/// The bell in the app bar, with the number of unread inbox messages. Opens the
/// inbox; the number is refreshed when the app comes back to the foreground.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<NotificationBadgeCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBadgeCubit, int>(
      builder: (context, unread) => IconButton(
        onPressed: () async {
          final badge = context.read<NotificationBadgeCubit>();
          await context.pushNamed(RouteNames.notifications);
          badge.refresh();
        },
        tooltip: context.l10n.notifications,
        icon: Badge.count(
          count: unread,
          isLabelVisible: unread > 0,
          child: const Icon(Icons.notifications_none),
        ),
      ),
    );
  }
}
