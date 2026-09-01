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
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  observers: [GoRouterObserver()],
  routes: <RouteBase>[
    GoRoute(
      path: "/",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const HeroPage(),
      ),
    ),
    GoRoute(
      path: "/main",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const PageViewPage(),
      ),
    ),
    GoRoute(
      path: "/checkout",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const CheckoutPage(),
      ),
    ),
    GoRoute(
      path: "/compare",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const ComparePage(),
      ),
    ),
    GoRoute(
      path: "/setup",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const SetupStorePage(),
      ),
    ),
    GoRoute(
      path: "/upload",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const UploadPage(),
      ),
    ),
    GoRoute(
      path: "/member/list",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const MemberListPage(),
      ),
    ),
    GoRoute(
      path: "/history/:id",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const HistoryPage(),
      ),
    ),
    GoRoute(
      path: "/inventory/stock-transfer/create",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const CreateStockTransferPage(),
      ),
    ),
    GoRoute(
      path: "/inventory/stock-transfer/send",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const SendStockTransferPage(),
      ),
    ),
    GoRoute(
        path: "/inventory/stock-transfer/receive",
        pageBuilder: (context, state) => halamanBergerak(
              kunci: state.pageKey,
              anak: const ReceiveStockTransferPage(),
            )),
    GoRoute(
        path: "/inventory/check-stock",
        pageBuilder: (context, state) => halamanBergerak(
              kunci: state.pageKey,
              anak: const CheckStockPage(),
            )),
    GoRoute(
        path: "/settings",
        pageBuilder: (context, state) => halamanBergerak(
              kunci: state.pageKey,
              anak: const SettingPage(),
            )),
    GoRoute(
      path: "/local",
      pageBuilder: (context, state) => halamanBergerak(
        kunci: state.pageKey,
        anak: const LocalHistoryPage(),
      ),
    ),
  ],
  initialLocation: "/",
);

class GoRouterObserver extends NavigatorObserver {}
