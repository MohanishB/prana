import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';

/// Opens the screen a notification points to. [route] is the value the server
/// stores: home, masterclass, consult, my_consultations, `program:<booking id>`.
/// An empty or unknown value opens nothing.
void openInboxRoute(BuildContext context, String route) =>
    openInboxRouteOn(GoRouter.of(context), route);

/// Same as [openInboxRoute] for code that has the router but no BuildContext (a tapped push).
void openInboxRouteOn(GoRouter router, String route) {
  if (route.isEmpty) return;
  if (route.startsWith('program:')) {
    final bookingId = int.tryParse(route.substring('program:'.length));
    if (bookingId != null) {
      router.pushNamed(
        RouteNames.workshopDetail,
        pathParameters: {'bookingId': '$bookingId'},
      );
    }
    return;
  }
  switch (route) {
    case 'home':
      router.goNamed(RouteNames.home);
    case 'masterclass':
      router.goNamed(RouteNames.masterclass);
    case 'consult':
      router.goNamed(RouteNames.consult);
    case 'my_consultations':
      router.pushNamed(RouteNames.myConsultations);
  }
}
