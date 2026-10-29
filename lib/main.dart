import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/bloc/catalog_refresh_cubit.dart';
import 'core/services/dependencies.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/masterclass/bloc/masterclass_cart_cubit.dart';
import 'features/notifications/bloc/notification_badge_cubit.dart';
import 'features/notifications/bloc/push_messages_cubit.dart';
import 'features/notifications/bloc/push_permission_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.bootstrap();
  // Starts Firebase. Never throws: if push cannot start, the rest of the app still works.
  await dependencies.pushClient.initialize();

  runApp(
    RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => MasterclassCartCubit()),
          BlocProvider(create: (_) => CatalogRefreshCubit()),
          BlocProvider(
            create: (_) => NotificationBadgeCubit(
              dependencies.notificationRepository,
              dependencies.sessionManager,
            ),
          ),
          BlocProvider(
            create: (_) => PushPermissionCubit(
              dependencies.pushClient,
              dependencies.pushPreferences,
              dependencies.deviceTokenRepository,
              dependencies.sessionManager,
            ),
          ),
          BlocProvider(
            create: (context) => PushMessagesCubit(
              dependencies.pushClient,
              dependencies.notificationRepository,
              context.read<NotificationBadgeCubit>(),
              dependencies.sessionManager,
            ),
          ),
          BlocProvider(
            create: (_) => AuthBloc(
              dependencies.authRepository,
              dependencies.sessionManager,
            )..add(const AuthStarted()),
          ),
        ],
        child: const PranaApp(),
      ),
    ),
  );
}
