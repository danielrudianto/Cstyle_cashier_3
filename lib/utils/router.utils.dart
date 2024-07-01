import 'package:cstyle_cashier_3/view/checkout/checkout.page.dart';
import 'package:cstyle_cashier_3/view/compare/compare.page.dart';
import 'package:cstyle_cashier_3/view/hero/hero.page.dart';
import 'package:cstyle_cashier_3/view/page-view/pageview.page.dart';
import 'package:cstyle_cashier_3/view/setup/setup.page.dart';
import 'package:cstyle_cashier_3/view/upload/upload.page.dart';
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
        return const PageViewPage();
      },
    ),
    GoRoute(
      path: "/checkout",
      builder: (context, state) {
        return const CheckoutPage();
      },
    ),
    GoRoute(
      path: "/compare",
      builder: (context, state) {
        return const ComparePage();
      },
    ),
    GoRoute(
      path: "/setup",
      builder: (context, state) {
        return const SetupStorePage();
      },
    ),
    GoRoute(
      path: "/upload",
      builder: (context, state) {
        return const UploadPage();
      },
    )
  ],
  initialLocation: "/",
);
