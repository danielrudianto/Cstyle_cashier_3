import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLBillCodeModel {
  int? id;
  String name;
  String date;
  String? memberID;
  String createdBy;
  DateTime createdAt;
  int isDelete;
  int isSynced;
  String? deletedBy;
  String? deletedAt;
  String? mongoID;
  DateTime? syncedAt;

  SQLBillCodeModel({
    this.id,
    required this.name,
    required this.date,
    this.memberID,
    required this.createdBy,
    required this.createdAt,
    this.isDelete = 0,
    this.isSynced = 0,
    this.deletedBy,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'memberID': memberID,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'is_delete': isDelete,
      'is_synced': isSynced,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt,
    };
  }

  factory SQLBillCodeModel.fromMap(Map<String, dynamic> map) {
    return SQLBillCodeModel(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      memberID: map['memberID'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
      isDelete: map['is_delete'],
      isSynced: map['is_synced'],
      deletedBy: map['deletedBy'],
      deletedAt: map['deletedAt'],
    );
  }

  static Future<List<SQLBillCodeModel>> fetchUnsyncedBills() async {
    var database = await DatabaseUtils().database;
    var result = await database.query(
      "bill_code",
      orderBy: "id DESC",
      where: "is_delete = 0 AND is_synced = 0",
    );

    return result.map((e) => SQLBillCodeModel.fromMap(e)).toList();
  }
}

class BillCodeSyncModel {
  int id;
  String mongoID;

  BillCodeSyncModel({
    required this.id,
    required this.mongoID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mongoID': mongoID,
    };
  }

  factory BillCodeSyncModel.fromMap(Map<String, dynamic> map) {
    return BillCodeSyncModel(
      id: map['id'],
      mongoID: map['mongoID'],
    );
  }

  static Future<void> update(int id, String mongoID) async {
    var database = await DatabaseUtils().database;
    try {
      await database.update(
        "bill_code",
        {
          "is_synced": 1,
          "mongoID": mongoID,
          "syncedAt": DateTime.now(),
        },
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}
