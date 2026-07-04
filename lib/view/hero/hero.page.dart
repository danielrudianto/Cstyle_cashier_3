import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/model/model.migration.model.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/sync.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  String loadingStatus = "Initializing";

  // Guard biar proses inisialisasi TIDAK jalan dobel
  bool _initStarted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Satu pintu masuk buat semua proses startup.
  Future<void> _initialize() async {
    if (_initStarted) return; // cegah dobel
    _initStarted = true;

    try {
      await checkDateTime();
    } catch (e, st) {
      // Ini hanya kejadian kalau jam PC BENERAN salah (selisih > 30 detik).
      // NTP yang gagal/diblok jaringan TIDAK sampai sini (di-skip di checkDateTime).
      LoggerUtils().log(
        "Startup dihentikan karena selisih waktu",
        LogType.error,
        error: e,
        stackTrace: st,
      );
      return; // berhenti, biar user benerin jam dulu
    }

    await connectAndSync();
  }

  void _setStatus(String status) {
    if (!mounted) return;
    setState(() {
      loadingStatus = status;
    });
  }

  Future<void> checkDateTime() async {
    _setStatus("Checking time with our online services.");

    try {
      // Timeout 5 detik: kalau NTP diblok (port 123 UDP) app gak akan hang lama.
      DateTime ntpTime = await NTP.now().timeout(
            const Duration(seconds: 5),
          );
      DateTime localTime = DateTime.now();

      final diff = ntpTime.difference(localTime).inSeconds.abs();

      if (diff > 30) {
        LoggerUtils().log("Time difference is $diff seconds", LogType.error);
        _setStatus(
          "Time difference is too large. Please set your time and date appropriately.",
        );
        // Jam PC beneran salah -> ini masalah SAH, hentikan startup.
        throw Exception("Time mismatch: $diff seconds");
      } else {
        _setStatus("Time is synced.");
      }
    } on Exception catch (e, st) {
      // Bedakan dua kasus:
      if (e.toString().contains("Time mismatch")) {
        // 1. Jam PC beneran salah -> teruskan biar startup berhenti.
        rethrow;
      }

      // 2. NTP gagal diakses (kemungkinan port 123 UDP diblok di jaringan client).
      //    SKIP pengecekan waktu, app tetap lanjut jalan.
      LoggerUtils().log(
        "NTP check skipped (unreachable / blocked)",
        LogType.error,
        error: e,
        stackTrace: st,
      );
      _setStatus("Time check skipped, continuing...");
      // TIDAK throw -> alur lanjut ke connectAndSync().
    }
  }

  Future<void> connectAndSync() async {
    _setStatus("Connecting to local database");
    try {
      await DatabaseUtils().database;
      LoggerUtils().log("Database connected", LogType.info);
      _setStatus("Database connected");

      final lastMigrationVersion =
          await MigrationModel.getLastMigrationVersion();

      MigrationModel.syncMigration(lastMigrationVersion).then((value) async {
        _setStatus("Migration obtained, applying to local database.");

        if (value.commands!.isNotEmpty) {
          try {
            await DatabaseUtils().runCommands(value.commands!);
            LoggerUtils().log(
              "${value.commands!.length} commands successfully ran 🚀🚀🚀",
              LogType.info,
            );
            _setStatus("Migration applied to local database.");
            if (lastMigrationVersion == 0 ||
                lastMigrationVersion != value.migrationVersion) {
              await MigrationModel(
                migrationVersion: value.migrationVersion,
                createdAt: DateTime.now(),
              ).create();

              _setStatus("Migration applied to local database.");
            }
          } catch (error, st) {
            LoggerUtils().log(
              "Gagal menjalankan migration commands",
              LogType.error,
              error: error,
              stackTrace: st,
            );
          }
        }

        // Cek apakah storeID sudah tersimpan di SharedPreferences
        StoreModel.getCurrentProfile().then((value) {
          if (!mounted) return;
          // User belum set StoreID
          if (value == null) {
            context.push("/setup");
          } else {
            _setStatus("Loading stock data from designated server");
            var storeCode = value.code;
            ProductStockModel.fetchServerStock(storeCode!).then((stocks) async {
              // Update stock di local database
              try {
                _setStatus("Applying stock data to local database");
                await ProductStockModel.updateServerStock(stocks);

                _setStatus(
                  "Successfully loaded stock data from designated server",
                );
                SyncUtils.sync();

                // Ambil cart yang belum selesai
                CartModel.fetchCartsCount().then((count) {
                  if (!mounted) return;
                  Provider.of<CartNotifier>(context, listen: false)
                      .setCartCount(count);
                }).catchError((error, st) {
                  LoggerUtils().log(
                    "Gagal fetch cart count",
                    LogType.error,
                    error: error,
                    stackTrace: st,
                  );
                });
                if (mounted) context.push("/main");
              } catch (error, st) {
                _setStatus("Failed loading stock data from designated server");
                LoggerUtils().log(
                  "Gagal apply stock data ke local database",
                  LogType.error,
                  error: error,
                  stackTrace: st,
                );
              }
            }).catchError((error, st) {
              _setStatus(
                "Loading stock data from designated server encountered an error",
              );
              LoggerUtils().log(
                "Gagal fetch stock dari server",
                LogType.error,
                error: error,
                stackTrace: st,
              );
            });
          }
        }).catchError((error, st) {
          LoggerUtils().log(
            "Gagal ambil current profile",
            LogType.error,
            error: error,
            stackTrace: st,
          );
        });
      }).catchError((error, st) {
        LoggerUtils().log(
          "Gagal sync migration dari server",
          LogType.error,
          error: error,
          stackTrace: st,
        );
        _setStatus("Failed to connect to designated server");
      });
    } catch (error, st) {
      LoggerUtils().log(
        "Gagal connect ke local database",
        LogType.error,
        error: error,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 161, 121, 220),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/IconReverted.webp",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "CSTYLE CASHIER APPLICATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Version 3.0.9.1",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    loadingStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
