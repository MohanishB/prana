import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../bloc/push_permission_cubit.dart';

/// Account screen: a short note shown only when the student refused notifications.
class PushOffNote extends StatelessWidget {
  const PushOffNote({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushPermissionCubit, PushPermissionState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.status != PushPermissionStatus.systemDenied) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: Text(context.l10n.pushOffTitle),
              subtitle: Text(context.l10n.pushOffNote),
            ),
          ),
        );
      },
    );
  }
}
