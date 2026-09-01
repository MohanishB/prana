import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/dependencies.dart';
import '../session/user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

class SessionAvatar extends StatelessWidget {
  const SessionAvatar({
    super.key,
    this.radius = AppSizes.avatarSmall / 2,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.read<AppDependencies>().sessionManager;
    return StreamBuilder<UserSession?>(
      stream: sessionManager.changes,
      initialData: sessionManager.current,
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.photoUrl;
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          backgroundImage:
              photoUrl == null ? null : NetworkImage(photoUrl),
          child: photoUrl == null
              ? const Icon(Icons.person_outline)
              : null,
        );
      },
    );
  }
}
