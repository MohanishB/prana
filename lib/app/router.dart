import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prana/features/masterclass/presentation/masterclass_screen.dart';

import '../core/localization/app_localizations_x.dart';
import '../core/services/dependencies.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/certificate/presentation/certificate_screen.dart';
import '../features/consult/presentation/consult_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/bloc/library_bloc.dart';
import '../features/library/domain/library_video.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/video_detail_screen.dart';
import '../features/masterclass/bloc/course_detail_cubit.dart';
import '../features/masterclass/bloc/masterclass_cubit.dart'; 


import '../features/masterclass/presentation/course_screen.dart';

import '../features/shell/presentation/prana_shell.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PranaShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/masterclass',
              name: RouteNames.masterclass,
              builder: (context, state) => BlocProvider(
                create: (_) => MasterclassCubit(
                  context.read<AppDependencies>().masterclassRepository,
                ),
                child: const MasterclassScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'course/:courseId',
                  name: RouteNames.course,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final courseId = int.tryParse(
                      state.pathParameters['courseId'] ?? '',
                    );
                    if (courseId == null) {
                      return Scaffold(
                        body: Center(
                          child: Text(context.l10n.errorCourseNotFound),
                        ),
                      );
                    }
                    final repository =
                        context.read<AppDependencies>().masterclassRepository;
                    return BlocProvider(
                      create: (_) => CourseDetailCubit(repository, courseId)
                        ..load(),
                      child: CourseScreen(courseId: courseId),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/consult',
              name: RouteNames.consult,
              builder: (context, state) => const ConsultScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              name: RouteNames.library,
              builder: (context, state) {
                final deps = context.read<AppDependencies>();
                return BlocProvider(
                  create: (_) => LibraryBloc(deps.libraryRepository)
                    ..add(const LibraryStarted()),
                  child: const LibraryScreen(),
                );
              },
              routes: [
                GoRoute(
                  path: 'video/:videoId',
                  name: RouteNames.libraryVideo,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final video = state.extra;
                    if (video is! LibraryVideo) {
                      return Scaffold(
                        body: Center(child: Text(context.l10n.videoNotFound)),
                      );
                    }
                    return VideoDetailScreen(video: video);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              name: RouteNames.account,
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/certificate/:certificateId',
      name: RouteNames.certificate,
      builder: (context, state) => CertificateScreen(
        certificateId: state.pathParameters['certificateId']!,
      ),
    ),
  ],
);
