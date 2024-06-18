import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLMigrationModel {
  int? id;
  int migrationVersion;
  DateTime? createdAt;
  List<String>? commands;

  SQLMigrationModel({
    this.id,
    required this.migrationVersion,
    this.createdAt,
    this.commands,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'migration_version': migrationVersion,
    };
  }

  factory SQLMigrationModel.fromMap(Map<String, dynamic> map) {
    return SQLMigrationModel(
      id: map['id'],
      migrationVersion: int.parse(map['migration_version']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static Future<SQLMigrationModel?> getLastMigrationVersion() async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "migration",
      limit: 1,
      offset: 0,
      orderBy: "migration_version DESC",
    );

    if (result.isEmpty) {
      // Never been synced before
      return null;
    } else {
      return SQLMigrationModel.fromMap(result.first);
    }
  }
}
