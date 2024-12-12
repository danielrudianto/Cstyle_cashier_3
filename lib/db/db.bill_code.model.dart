import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_payment.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLBillCodeModel {
  int? id;
  String name;
  DateTime date;
  String? memberID;
  String createdBy;
  DateTime createdAt;
  int isDeleted;
  int isSynced;
  String? deletedBy;
  DateTime? deletedAt;
  String? mongoID;
  DateTime? syncedAt;

  SQLBillCodeModel({
    this.id,
    required this.name,
    required this.date,
    this.memberID,
    required this.createdBy,
    required this.createdAt,
    this.isDeleted = 0,
    this.isSynced = 0,
    this.deletedBy,
    this.deletedAt,
    this.mongoID,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'memberID': memberID,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt?.toIso8601String(),
      'mongoID': mongoID,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory SQLBillCodeModel.fromMap(Map<String, dynamic> map) {
    return SQLBillCodeModel(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      memberID: map['memberID'],
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt']),
      isDeleted: map['isDeleted'],
      isSynced: map['isSynced'],
      deletedBy: map['deletedBy'],
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      mongoID: map['mongoID'],
      syncedAt:
          map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
    );
  }

  static Future<List<SQLBillCodeModel>> fetchUnsyncedBills() async {
    var database = await DatabaseUtils().database;
    var result = await database.query(
      "bill_code",
      orderBy: "id DESC",
      where: "isDeleted = 0 AND isSynced = 0 AND errorMessage IS NULL",
    );

    return result.map((e) => SQLBillCodeModel.fromMap(e)).toList();
  }

  static Future<SQLBillCodeModel?> fetchLastBillCode() async {
    var database = await DatabaseUtils().database;
    var result = await database.query(
      "bill_code",
      orderBy: "id DESC",
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    } else {
      return SQLBillCodeModel.fromMap(result.first);
    }
  }

  static Future<List<SQLBillCodeModel>> fetchProblematicBills() async {
    var database = await DatabaseUtils().database;
    var result = await database.query(
      "bill_code",
      orderBy: "id DESC",
      where: "isDeleted = 0 AND isSynced = 0 AND errorMessage IS NOT NULL",
    );

    return result.map((e) => SQLBillCodeModel.fromMap(e)).toList();
  }

  static Future<SQLBillCodeModel> fetchByID(int id) async {
    final db = await DatabaseUtils().database;

    var result = await db.query("bill_code", where: "id = ?", whereArgs: [id]);
    if (result.isEmpty) {
      throw Exception("Bill not found");
    }

    return SQLBillCodeModel.fromMap(result.first);
  }

  static Future<SQLBillCodeModel> fetchByName(String name) async {
    final db = await DatabaseUtils().database;
    var result =
        await db.query("bill_code", where: "name = ?", whereArgs: [name]);

    if (result.isEmpty) {
      throw Exception("Bill not found");
    } else {
      var billCode = result.first;
      return SQLBillCodeModel.fromMap(billCode);
    }
  }

  static updateUnsyncedBill(String id, String name) async {
    final db = await DatabaseUtils().database;
    var result = await db.update(
        "bill_code",
        {
          "syncedAt": DateTime.now().toString(),
          "isSynced": 1,
          "mongoID": id,
        },
        where: "name = ?",
        whereArgs: [name]);
    return result;
  }

  static Future<List<SQLBillCodeModel>> fetch(int page) async {
    final db = await DatabaseUtils().database;
    var result = await db.query("bill_code",
        orderBy: "id DESC", limit: 10, offset: (page - 1) * 10);

    return result.map((e) => SQLBillCodeModel.fromMap(e)).toList();
  }

  static Future<int> count() async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery("SELECT COUNT(*) AS count FROM bill_code");
    return result.isEmpty ? 0 : result.first['count'] as int;
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseUtils().database;
    await db.delete("bill", where: "billCodeID = ?", whereArgs: [id]);
    await db.delete("bill_payment", where: "billCodeID = ?", whereArgs: [id]);
    var result = await db.delete("bill_code", where: "id = ?", whereArgs: [id]);

    return result;
  }
}

class SQLBillCodeModelCreate extends SQLBillCodeModel {
  SQLBillCodeModelCreate({
    required super.name,
    required super.date,
    super.memberID,
    required super.createdBy,
    required super.createdAt,
    super.isDeleted = 0,
    super.isSynced = 0,
    super.deletedBy,
    super.deletedAt,
    super.mongoID,
    super.syncedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'memberID': memberID,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt?.toIso8601String(),
      'mongoID': mongoID,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory SQLBillCodeModelCreate.fromMap(Map<String, dynamic> map) {
    return SQLBillCodeModelCreate(
      name: map['name'],
      date: DateTime.parse(map['date']),
      memberID: map['memberID'],
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt']),
      isDeleted: map['isDeleted'],
      isSynced: map['isSynced'],
      deletedBy: map['deletedBy'],
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      mongoID: map['mongoID'],
      syncedAt:
          map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
    );
  }

  Future<int> create() async {
    try {
      final db = await DatabaseUtils().database;
      var billCodeID = await db.insert("bill_code", toMap());
      if (billCodeID != 0) {
        return billCodeID;
      } else {
        throw Exception("Failed to create bill code");
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}

class SQLBillCodeModelPrint extends SQLBillCodeModel {
  List<SQLBillPaymentModelPrint> payments;
  List<SQLBillModelPrint> bills;
  String createdByName;

  SQLBillCodeModelPrint({
    required this.payments,
    required this.bills,
    required this.createdByName,
    required super.name,
    required super.date,
    super.memberID,
    super.mongoID,
    required super.createdBy,
    required super.createdAt,
    required super.id,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'memberID': memberID,
      'mongoID': mongoID,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'payments': payments.map((x) => x.toMap()).toList(),
      'bills': bills.map((x) => x.toMap()).toList(),
    };
  }

  factory SQLBillCodeModelPrint.fromMap(Map<String, dynamic> map) {
    return SQLBillCodeModelPrint(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      memberID: map['memberID'],
      mongoID: map['mongoID'],
      createdBy: map['createdBy'],
      createdByName: map['createdByName'],
      payments: [],
      bills: [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static Future<SQLBillCodeModelPrint> fetchByName(String name) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT bill_code.id, bill_code.name, bill_code.date, bill_code.memberID, bill_code.mongoID, bill_code.createdBy, user.name AS createdByName, bill_code.createdAt FROM bill_code JOIN user ON bill_code.createdBy = user.code WHERE bill_code.name = '$name'");

    if (result.isEmpty) {
      throw Exception("Bill not found");
    } else {
      try {
        var billCode = SQLBillCodeModelPrint.fromMap(result.first);
        var items = await SQLBillModelPrint.fetchByBillCodeID(billCode.id!);
        var payments =
            await SQLBillPaymentModelPrint.fetchByBillCodeID(billCode.id!);

        billCode.bills = items;
        billCode.payments = payments;

        return billCode;
      } catch (error) {
        throw Exception(error);
      }
    }
  }

  static Future<SQLBillCodeModelPrint> fetchByID(int id) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT bill_code.id, bill_code.name, bill_code.date, bill_code.memberID, bill_code.mongoID, bill_code.createdBy, user.name AS createdByName, bill_code.createdAt FROM bill_code JOIN user ON bill_code.createdBy = user.code WHERE bill_code.id = $id");

    if (result.isEmpty) {
      throw Exception("Bill not found");
    } else {
      try {
        var billCode = SQLBillCodeModelPrint.fromMap(result.first);
        var items = await SQLBillModelPrint.fetchByBillCodeID(billCode.id!);
        var payments =
            await SQLBillPaymentModelPrint.fetchByBillCodeID(billCode.id!);

        billCode.bills = items;
        billCode.payments = payments;

        return billCode;
      } catch (error) {
        throw Exception(error);
      }
    }
  }
}

class SQLBillSyncModel {
  int? id;
  String name;
  DateTime date;
  String? memberID;
  String createdBy;
  DateTime createdAt;
  String? mongoID;
  DateTime? syncedAt;
  List<SQLBillPaymentModelSync> payments;
  List<SQLBillModelSync> bills;

  SQLBillSyncModel({
    this.id,
    required this.name,
    required this.date,
    this.memberID,
    required this.createdBy,
    required this.createdAt,
    this.mongoID,
    this.syncedAt,
    required this.payments,
    required this.bills,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'memberID': memberID,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'mongoID': mongoID,
      'payments': payments.map((x) => x.toMap()).toList(),
      'bills': bills.map((x) => x.toMap()).toList(),
    };
  }

  factory SQLBillSyncModel.fromMap(Map<String, dynamic> map) {
    return SQLBillSyncModel(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      memberID: map['memberID'],
      createdBy: map['createdBy'],
      createdAt: DateTime.parse(map['createdAt']),
      mongoID: map['mongoID'],
      syncedAt:
          map['syncedAt'] == null ? null : DateTime.parse(map['syncedAt']),
      payments: [],
      bills: [],
    );
  }

  static Future<List<SQLBillSyncModel>> fetchUnsyncedBills() async {
    try {
      final db = await DatabaseUtils().database;
      final result = await db.rawQuery(
          "SELECT bill_code.*, user.userID as createdBy FROM bill_code JOIN user ON bill_code.createdBy = user.code WHERE isSynced = 0 AND isDeleted = 0");

      var ids = result.map((e) => e['id'] as int).toList();

      if (ids.isEmpty) {
        return [];
      }

      // Wait for both futures to complete
      final values = await Future.wait([
        SQLBillPaymentModelSync.fetchByBillCodeIDs(ids),
        SQLBillModelSync.fetchByBillCodeIDs(ids)
      ]);

      var payments = values[0] as List<SQLBillPaymentModelSync>;
      var bills = values[1] as List<SQLBillModelSync>;

      var response = result.map((e) => SQLBillSyncModel.fromMap(e)).toList();

      for (var item in response) {
        item.payments =
            payments.where((element) => element.billCodeID == item.id).toList();
        item.bills =
            bills.where((element) => element.billCodeID == item.id).toList();
      }

      return response;
    } catch (error) {
      throw Exception(error);
    }
  }
}
