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

  @override
  void didChangeDependencies() {
    checkDateTime().then((_) async {
      await connectAndSync();
    }).catchError((error) {
      LoggerUtils().log("Error on checking date and time", LogType.error);
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    checkDateTime().then((_) async {
      await connectAndSync();
    }).catchError((error) {
      LoggerUtils().log("Error on checking date and time", LogType.error);
    });
    super.initState();
  }

  Future<void> connectAndSync() async {
    setState(() {
      loadingStatus = "Connecting to local database";
    });
    try {
      await DatabaseUtils().database;
      LoggerUtils().log("Database connected", LogType.info);
      setState(() {
        loadingStatus = "Database connected";
      });

      final lastMigrationVersion =
          await MigrationModel.getLastMigrationVersion();
      MigrationModel.syncMigration(lastMigrationVersion).then((value) async {
        setState(() {
          loadingStatus = "Migration obtained, applying to local database.";
        });

        if (value.commands!.isNotEmpty) {
          try {
            for (var command in value.commands!) {
              await DatabaseUtils().runCommand(command);
            }
            LoggerUtils().log(
              "${value.commands!.length} commands successfully ran 🚀🚀🚀",
              LogType.info,
            );
            loadingStatus = "Migration applied to local database.";
            if (lastMigrationVersion == 0 ||
                lastMigrationVersion != value.migrationVersion) {
              await MigrationModel(
                migrationVersion: value.migrationVersion,
                createdAt: DateTime.now(),
              ).create();

              loadingStatus = "Migration applied to local database.";
            }
          } catch (error) {
            LoggerUtils().log(error.toString(), LogType.error);
          }
        }

        // Next check on shared preferences is storeID already stored in SharedPreferences
        StoreModel.getCurrentProfile().then((value) {
          // User has not yet set StoreID
          if (value == null) {
            context.push("/setup");
          } else {
            setState(() {
              loadingStatus = "Loading stock data from designated server";
            });
            var storeCode = value.code;
            ProductStockModel.fetchServerStock(storeCode!).then((stocks) async {
              // Update local database stock
              try {
                setState(() {
                  loadingStatus = "Applying stock data to local database";
                });
                await ProductStockModel.updateServerStock(stocks);

                setState(() {
                  loadingStatus =
                      "Successfully loaded stock data from designated server";
                });
                SyncUtils.sync();

                // Get incompleted carts
                CartModel.fetchCartsCount().then((count) {
                  Provider.of<CartNotifier>(context, listen: false)
                      .setCartCount(count);
                }).catchError((error) {
                  LoggerUtils().log(error.toString(), LogType.error);
                });
                context.push("/main");
              } catch (error) {
                setState(() {
                  loadingStatus =
                      "Failed loading stock data from designated server";
                });
                LoggerUtils().log(error.toString(), LogType.error);
              }
            }).catchError((error) {
              setState(() {
                loadingStatus =
                    "Loading stock data from designated server encountered an error";
              });
              LoggerUtils().log(error.toString(), LogType.error);
            });
          }
        }).catchError((error) {
          LoggerUtils().log(error.toString(), LogType.error);
        });
      }).catchError((error) {
        LoggerUtils().log(error.toString(), LogType.error);
        setState(() {
          loadingStatus = "Failed to connect to designated server";
        });
      });
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
    }
  }

  Future<void> checkDateTime() async {
    setState(() {
      loadingStatus = "Checking time with our online services.";
    });

    try {
      DateTime ntpTime = await NTP.now();
      print(ntpTime);
      DateTime localTime = DateTime.now();

      setState(() {
        if ((ntpTime.difference(localTime).inSeconds).abs() > 30) {
          LoggerUtils().log(
            "Time difference is ${ntpTime.difference(localTime).inSeconds.abs()}",
            LogType.error,
          );
          setState(() {
            loadingStatus =
                "Time difference is too large. Please set your time and date appropriately.";
            throw Exception("Time missmatch");
          });
        } else {
          loadingStatus = "Time is synced.";
        }
      });
    } catch (e) {
      LoggerUtils().log(
          "Time sync process is error. Please try again later.", LogType.error);

      setState(() {
        loadingStatus = "Error fetching time.";
      });

      throw Exception(e);
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
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "CSTYLE CASHIER APPLICATION",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Version 2.0.1",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    loadingStatus,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
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
