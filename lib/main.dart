import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/services/dependencies.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.bootstrap();

  runApp(
    RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
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
