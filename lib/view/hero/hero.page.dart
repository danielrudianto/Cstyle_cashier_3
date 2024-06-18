import 'package:cstyle_cashier_3/model/model.migration.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  String loadingStatus = "Initializing connection to database.";

  @override
  void initState() {
    connectAndSync();
    super.initState();
  }

  void connectAndSync() async {
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
                LogType.info);
            if (lastMigrationVersion == 0) {
              // If never synced, insert migration data
              await DatabaseUtils().runCommands([
                "INSERT INTO migration (migration_version) VALUES (${value.migrationVersion});"
              ]);
            } else if (lastMigrationVersion != value.migrationVersion) {
              await DatabaseUtils().runCommands([
                "INSERT INTO migration (migration_version) VALUES (${value.migrationVersion});"
              ]);
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
            context.push("/dashboard");
          }
        }).catchError((error) {
          LoggerUtils().log(error.toString(), LogType.error);
        });
      }).catchError((error) {
        LoggerUtils().log(error.toString(), LogType.error);
      });
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(loadingStatus),
    );
  }
}
