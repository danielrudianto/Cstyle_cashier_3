import 'package:cstyle_cashier_3/view/check-stock/check-stock.page.dart';
import 'package:cstyle_cashier_3/view/checkout/checkout.page.dart';
import 'package:cstyle_cashier_3/view/compare/compare.page.dart';
import 'package:cstyle_cashier_3/view/hero/hero.page.dart';
import 'package:cstyle_cashier_3/view/history/history.page.dart';
import 'package:cstyle_cashier_3/view/local-history/local-history.page.dart';
import 'package:cstyle_cashier_3/view/member-list/member-list.page.dart';
import 'package:cstyle_cashier_3/view/page-view/pageview.page.dart';
import 'package:cstyle_cashier_3/view/setting/setting.page.dart';
import 'package:cstyle_cashier_3/view/setup/setup.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/create-stock-transfer/create-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/receive-stock-transfer/receive-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/send-stock-transfer/send-stock.transfer.page.dart';
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
    ),
    GoRoute(
      path: "/member/list",
      builder: (context, state) {
        return const MemberListPage();
      },
    ),
    GoRoute(
      path: "/history/:id",
      builder: (context, state) {
        return const HistoryPage();
      },
    ),
    GoRoute(
      path: "/inventory/stock-transfer/create",
      builder: (context, state) {
        return const CreateStockTransferPage();
      },
    ),
    GoRoute(
      path: "/inventory/stock-transfer/send",
      builder: (context, state) {
        return const SendStockTransferPage();
      },
    ),
    GoRoute(
        path: "/inventory/stock-transfer/receive",
        builder: (context, state) {
          return const ReceiveStockTransferPage();
        }),
    GoRoute(
        path: "/inventory/check-stock",
        builder: (context, state) {
          return const CheckStockPage();
        }),
    GoRoute(
        path: "/settings",
        builder: (context, state) {
          return const SettingPage();
        }),
    GoRoute(
      path: "/local",
      builder: (context, state) {
        return const LocalHistoryPage();
      },
    ),
  ],
  initialLocation: "/",
);

class GoRouterObserver extends NavigatorObserver {}
