import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/bloc/catalog_refresh_cubit.dart';
import '../core/localization/app_localizations_x.dart';
import '../core/services/dependencies.dart';
import '../features/account/bloc/account_profile_cubit.dart';
import '../features/account/bloc/change_password_cubit.dart';
import '../features/account/bloc/edit_profile_cubit.dart';
import '../features/account/data/account_models.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/account/presentation/change_password_screen.dart';
import '../features/account/presentation/edit_profile_screen.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/certificate/presentation/certificate_screen.dart';
import '../features/consult/bloc/consult_cubit.dart';
import '../features/consult/presentation/consult_screen.dart';
import '../features/consult/presentation/consultation_offer_screen.dart';
import '../features/faq/bloc/faq_cubit.dart';
import '../features/faq/presentation/faq_screen.dart';
import '../features/gut_reset/bloc/gut_reset_offers_cubit.dart';
import '../features/gut_reset/data/gut_reset_models.dart';
import '../features/gut_reset/presentation/program_offer_screen.dart';
import '../features/home/bloc/home_cubit.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/bloc/library_bloc.dart';
import '../features/library/bloc/library_feed_cubit.dart';
import '../features/library/domain/library_video.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/video_detail_screen.dart';
import '../features/masterclass/bloc/course_detail_cubit.dart';
import '../features/masterclass/bloc/masterclass_cubit.dart';
import '../features/masterclass/bloc/masterclass_offers_cubit.dart';
import '../features/masterclass/data/masterclass_checkout_models.dart';
import '../features/masterclass/data/masterclass_models.dart';
import '../features/masterclass/presentation/course_screen.dart';
import '../features/masterclass/presentation/course_video_screen.dart';
import '../features/masterclass/presentation/masterclass_cart_screen.dart';
import '../features/masterclass/presentation/masterclass_checkout_screen.dart';
import '../features/masterclass/presentation/masterclass_offer_screen.dart';
import '../features/masterclass/presentation/masterclass_order_success_screen.dart';
import '../features/masterclass/presentation/masterclass_screen.dart';
import '../features/shell/presentation/prana_shell.dart';
import '../features/workshops/presentation/workshop_day_video.dart';
import '../features/workshops/presentation/workshop_detail.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PranaShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (context, state) => BlocProvider(
                create: (_) => HomeCubit(
                  context.read<AppDependencies>().homeRepository,
                )..load(),
                // After a purchase the home lists are out of date.
                child: BlocListener<CatalogRefreshCubit, int>(
                  listener: (context, _) => context.read<HomeCubit>().load(),
                  child: const HomeScreen(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/masterclass',
              name: RouteNames.masterclass,
              builder: (context, state) {
                final deps = context.read<AppDependencies>();
                // A guest has no purchased courses to load.
                final guest = context.read<AuthBloc>().state is AuthGuest;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => MasterclassCubit(
                        deps.masterclassRepository,
                        loadsCourses: !guest,
                      ),
                    ),
                    BlocProvider(
                      create: (_) =>
                          MasterclassOffersCubit(deps.masterclassOfferRepository)
                            ..load(),
                    ),
                    BlocProvider(
                      create: (_) =>
                          GutResetOffersCubit(deps.gutResetRepository)..load(),
                    ),
                  ],
                  // After a purchase: bought items move to "my masterclasses".
                  child: BlocListener<CatalogRefreshCubit, int>(
                    listener: (context, _) {
                      context.read<MasterclassOffersCubit>().load();
                      context.read<GutResetOffersCubit>().load();
                      if (!guest) context.read<MasterclassCubit>().loadCourses();
                    },
                    child: const MasterclassScreen(),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'workshop/:bookingId',
                  name: RouteNames.workshopDetail,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final bookingId=int.tryParse(state.pathParameters['bookingId']??'');
                    if(bookingId==null)return const Scaffold(body:Center(child:Text('Workshop not found')));
                    return WorkshopDetailScreen(bookingId:bookingId);
                  },
                  routes: [
                    GoRoute(
                      path: 'day/:itemId',
                      name: RouteNames.workshopDayVideo,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final itemId=int.tryParse(state.pathParameters['itemId']??'');
                        if(itemId==null)return const Scaffold(body:Center(child:Text('Day not found')));
                        return WorkshopDayVideoScreen(itemId:itemId);
                      },
                    ),
                  ],
                ),
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
                  routes: [
                    GoRoute(
                      path: 'video/:videoId',
                      name: RouteNames.courseVideo,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final video = state.extra;
                        if (video is! CourseVideo) {
                          return Scaffold(
                            body: Center(
                              child: Text(context.l10n.videoNotFound),
                            ),
                          );
                        }
                        return CourseVideoScreen(video: video);
                      },
                    ),
                  ],
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
              builder: (context, state) => BlocProvider(
                create: (_) => ConsultCubit(
                  context.read<AppDependencies>().consultRepository,
                )..load(),
                child: BlocListener<CatalogRefreshCubit, int>(
                  listener: (context, _) => context.read<ConsultCubit>().load(),
                  child: const ConsultScreen(),
                ),
              ),
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
                    final extra = state.extra;
                    final args = switch (extra) {
                      final LibraryPlaybackArgs args => args,
                      final LibraryVideo video => LibraryPlaybackArgs(
                          videos: [video],
                          initialIndex: 0,
                          query: '',
                        ),
                      _ => null,
                    };
                    if (args == null) {
                      return Scaffold(
                        body: Center(child: Text(context.l10n.videoNotFound)),
                      );
                    }
                    final repository =
                        context.read<AppDependencies>().libraryRepository;
                    return BlocProvider(
                      create: (_) => LibraryFeedCubit(repository, args),
                      child: const VideoDetailScreen(),
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
              path: '/account',
              name: RouteNames.account,
              builder: (context, state) {
                final repository =
                    context.read<AppDependencies>().accountRepository;
                final guest = context.read<AuthBloc>().state is AuthGuest;
                return BlocProvider(
                  create: (_) {
                    final cubit = AccountProfileCubit(repository);
                    if (!guest) cubit.load();
                    return cubit;
                  },
                  child: const AccountScreen(),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  name: RouteNames.editProfile,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final profile = state.extra;
                    if (profile is! AccountProfile) {
                      return Scaffold(
                        body: Center(child: Text(context.l10n.errorProfileNotFound)),
                      );
                    }
                    final repository =
                        context.read<AppDependencies>().accountRepository;
                    return BlocProvider(
                      create: (_) => EditProfileCubit(repository),
                      child: EditProfileScreen(profile: profile),
                    );
                  },
                ),
                GoRoute(
                  path: 'change-password',
                  name: RouteNames.changePassword,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final repository =
                        context.read<AppDependencies>().accountRepository;
                    return BlocProvider(
                      create: (_) => ChangePasswordCubit(repository),
                      child: const ChangePasswordScreen(),
                    );
                  },
                ),
                GoRoute(
                  path: 'faqs',
                  name: RouteNames.faqs,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final repository =
                        context.read<AppDependencies>().faqRepository;
                    return BlocProvider(
                      create: (_) => FaqCubit(repository)..load(),
                      child: const FaqScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/offer/masterclass/:courseId',
      name: RouteNames.masterclassOffer,
      builder: (context, state) {
        final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
        if (courseId == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorCourseNotFound)),
          );
        }
        return MasterclassOfferScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/offer/consultation/:consultationId',
      name: RouteNames.consultationOffer,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['consultationId'] ?? '');
        if (id == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorGeneric)),
          );
        }
        return ConsultationOfferScreen(consultationId: id);
      },
    ),
    GoRoute(
      path: '/offer/program/:type',
      name: RouteNames.programOffer,
      builder: (context, state) {
        final offer = state.extra;
        if (offer is! GutResetOffer) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorGeneric)),
          );
        }
        return ProgramOfferScreen(offer: offer);
      },
    ),
    GoRoute(
      path: '/masterclass-cart',
      name: RouteNames.masterclassCart,
      builder: (context, state) => const MasterclassCartScreen(),
    ),
    GoRoute(
      path: '/masterclass-checkout',
      name: RouteNames.masterclassCheckout,
      builder: (context, state) {
        final args = state.extra;
        if (args is! CheckoutArgs) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorGeneric)),
          );
        }
        return MasterclassCheckoutScreen(args: args);
      },
    ),
    GoRoute(
      path: '/masterclass-order-success',
      name: RouteNames.masterclassOrderSuccess,
      builder: (context, state) {
        final result = state.extra;
        if (result is! MasterclassOrderResult) {
          return Scaffold(
            body: Center(child: Text(context.l10n.errorGeneric)),
          );
        }
        return MasterclassOrderSuccessScreen(result: result);
      },
    ),
    GoRoute(
      path: '/certificate/:certificateId',
      name: RouteNames.certificate,
      builder: (context, state) => CertificateScreen(
        certificateId: state.pathParameters['certificateId']!,
        title: state.uri.queryParameters['title'],
        downloadUrl: state.uri.queryParameters['url'],
        generatedOn: state.uri.queryParameters['generatedOn'],
      ),
    ),
  ],
);
