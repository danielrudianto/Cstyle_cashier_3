import 'dart:io';
import 'dart:ui';

import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('CSTYLE CASHIER APPLICATION');
    setWindowMinSize(const Size(1280, 720));
  }

  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  await FastCachedImageConfig.init(
      subDir: tempPath, clearCacheAfter: const Duration(days: 30));

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
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      debugShowCheckedModeBanner: false,
      title: 'Cstyle Cashier Application',
      theme: themeData,
      routerConfig: router,
    );
  }
}
