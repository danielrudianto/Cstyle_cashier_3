import 'package:cstyle_cashier_3/db/db.migration.model.dart';
import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class MigrationModel {
  int? id;
  int migrationVersion;
  DateTime? createdAt;
  List<String>? commands;

  MigrationModel({
    this.id,
    required this.migrationVersion,
    this.createdAt,
    this.commands,
  });

  static Future<int> getLastMigrationVersion() async {
    var migration = await SQLMigrationModel.getLastMigrationVersion();
    return migration == null ? 0 : migration.migrationVersion;
  }

  static Future<MigrationModel> syncMigration(int lastMigrationVersion) async {
    try {
      var store = await SQLStoreModel.getCurrentProfile();
      var response = await ApiUtils().postRequest(
          "migration",
          {"last_migration_version": lastMigrationVersion},
          Options(headers: {"store": store?.code}));

      // The response should be the form of {version: ___, commands: [string]}
      return MigrationModel(
          migrationVersion: response["migrationVersion"],
          commands:
              (response["commands"] as List).map((x) => x.toString()).toList());
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  Future<void> create() async {
    try {
      await SQLMigrationModel(
        migrationVersion: migrationVersion,
        createdAt: DateTime.now(),
      ).create();
    } catch (error) {
      throw Exception(error);
    }
  }
}
