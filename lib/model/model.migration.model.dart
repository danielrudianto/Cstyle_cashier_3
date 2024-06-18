import 'package:cstyle_cashier_3/model/db.migration.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';

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
      var response = await ApiUtils().postRequest(
          "migration", {"last_migration_version": lastMigrationVersion});

      // The response should be the form of {version: ___, commands: [string]}
      return MigrationModel(
          migrationVersion: response["version"],
          commands:
              (response["commands"] as List).map((x) => x.toString()).toList());
    } catch (error) {
      throw Exception(error.toString());
    }
  }
}
