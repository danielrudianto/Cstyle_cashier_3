import 'package:cstyle_cashier_3/view/bill-view/bill-view.page.dart';
import 'package:cstyle_cashier_3/view/checkout/checkout.page.dart';
import 'package:cstyle_cashier_3/view/compare/compare.page.dart';
import 'package:cstyle_cashier_3/view/hero/hero.page.dart';
import 'package:cstyle_cashier_3/view/member-list/member-list.page.dart';
import 'package:cstyle_cashier_3/view/page-view/pageview.page.dart';
import 'package:cstyle_cashier_3/view/product-selector/product-selector.page.dart';
import 'package:cstyle_cashier_3/view/setup/setup.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/create-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/upload/upload.page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  observers: [GoRouterObserver()],
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
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            child: const CheckoutPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(animation),
                child: child,
              );
            });
      },
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
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            opaque: false,
            child: UploadPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(animation),
                child: child,
              );
            });
      },
    ),
    GoRoute(
      path: "/member/list",
      builder: (context, state) {
        return const MemberListPage();
      },
    ),
    GoRoute(
      path: "/history/:id",
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            opaque: false,
            child: BillViewPage(id: int.parse(state.pathParameters['id']!)),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(animation),
                child: child,
              );
            });
      },
    ),
    GoRoute(
      path: "/inventory/stock-transfer/create",
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            opaque: false,
            child: CreateStockTransferPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(animation),
                child: child,
              );
            });
      },
    ),
    GoRoute(
        path: "/select-product/:id",
        pageBuilder: (context, state) {
          return CustomTransitionPage(
              opaque: false,
              child: ProductSelectorPage(storeID: state.pathParameters['id']!),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          .animate(animation),
                  child: child,
                );
              });
        }),
  ],
  initialLocation: "/",
);

class GoRouterObserver extends NavigatorObserver {}
