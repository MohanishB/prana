import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_localizations_x.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/presentation/login_screen.dart';
import 'router.dart';

class PranaApp extends StatelessWidget {
  const PranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Entering the app (login or "Skip login") always starts on Home.
      // A token refresh re-emits AuthAuthenticated; that must not reset navigation.
      listenWhen: (previous, current) =>
          (current is AuthAuthenticated && previous is! AuthAuthenticated) ||
          (current is AuthGuest && previous is! AuthGuest),
      listener: (context, state) => appRouter.go('/home'),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final router = switch (authState) {
              AuthInitial() => loadingRouter,
              AuthAuthenticated() || AuthGuest() => appRouter,
              _ => loginRouter,
            };
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => context.l10n.appTitle,
              routerConfig: router,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: mode,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        );
      },
    ));
  }
}

final loginRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
  ],
);

final loadingRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
  ],
);
