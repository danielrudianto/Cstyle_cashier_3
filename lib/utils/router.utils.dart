import 'package:cstyle_cashier_3/view/dashboard/dashboard.page.dart';
import 'package:cstyle_cashier_3/view/hero/hero.page.dart';
import 'package:cstyle_cashier_3/view/page-view/pageview.page.dart';
import 'package:cstyle_cashier_3/view/setup/setup.page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: "/",
      builder: (context, state) {
        return const HeroPage();
      },
    ),
    GoRoute(
      path: "/main",
      builder: (context, state) {
        return PageViewPage();
      },
    ),
    GoRoute(
      path: "/setup",
      builder: (context, state) {
        return const SetupStorePage();
      },
    )
  ],
  initialLocation: "/",
);
