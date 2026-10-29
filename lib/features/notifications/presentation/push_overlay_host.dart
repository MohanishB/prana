import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/push_messages_cubit.dart';
import '../bloc/push_permission_cubit.dart';
import 'notification_navigation.dart';

/// Wraps the whole app (MaterialApp builder). It shows:
///  - the "Turn on notifications" screen on top of whatever is open, when it is time to ask;
///  - a banner when a push arrives while the app is open;
///  - and opens the right screen when the student taps a push.
class PushOverlayHost extends StatelessWidget {
  const PushOverlayHost({required this.router, required this.child, super.key});

  /// The router of the signed-in app (where a tapped push opens its screen).
  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PushMessagesCubit, PushMessagesState>(
      listenWhen: (previous, current) => previous.sequence != current.sequence,
      listener: _onMessage,
      child: BlocBuilder<PushPermissionCubit, PushPermissionState>(
        buildWhen: (previous, current) =>
            (previous.status == PushPermissionStatus.askUser) !=
            (current.status == PushPermissionStatus.askUser),
        builder: (context, state) {
          return Stack(
            children: [
              child,
              if (state.status == PushPermissionStatus.askUser)
                const Positioned.fill(child: _PushPermissionScreen()),
            ],
          );
        },
      ),
    );
  }

  void _onMessage(BuildContext context, PushMessagesState state) {
    final signedIn = context.read<AuthBloc>().state is AuthAuthenticated;
    final opened = state.opened;
    if (opened != null) {
      if (signedIn) _openLater(opened.route);
      return;
    }
    final message = state.foreground;
    if (message == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final theme = Theme.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.title.isNotEmpty)
                Text(
                  message.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
              if (message.body.isNotEmpty)
                Text(
                  message.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
            ],
          ),
          action: signedIn && message.route.isNotEmpty
              ? SnackBarAction(
                  label: context.l10n.pushBannerOpen,
                  onPressed: () => _openLater(message.route),
                )
              : null,
        ),
      );
  }

  /// Waits for the current frame so a screen change from "Skip login"/login settles first.
  void _openLater(String route) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => openInboxRouteOn(router, route),
    );
  }
}

class _PushPermissionScreen extends StatelessWidget {
  const _PushPermissionScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<PushPermissionCubit>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) cubit.notNow();
      },
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.compactContentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: AppSizes.iconLarge,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.pushPromptTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.pushPromptBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      height: AppSizes.primaryButtonHeight,
                      child: FilledButton(
                        onPressed: cubit.turnOn,
                        child: Text(l10n.pushPromptTurnOn),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: cubit.notNow,
                      child: Text(l10n.pushPromptNotNow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
