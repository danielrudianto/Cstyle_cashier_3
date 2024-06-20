import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // SyncUtils.run();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<CartNotifier>(create: (_) => CartNotifier()),
      ChangeNotifierProvider<CompareNotifier>(create: (_) => CompareNotifier()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Cstyle Cashier Application',
      theme: themeData,
      routerConfig: router,
    );
  }
}
