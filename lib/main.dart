import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/services/dependencies.dart';
import 'core/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies.bootstrap();

  runApp(
    RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: const PranaApp(),
      ),
    ),
  );
}
