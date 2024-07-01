import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLBillPaymentModel {
  int? id;
  int billCodeID;
  String paymentMethod;
  double amount;

  SQLBillPaymentModel({
    this.id,
    required this.billCodeID,
    required this.paymentMethod,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billCodeID': billCodeID,
      'paymentMethod': paymentMethod,
      'amount': amount,
    };
  }

  factory SQLBillPaymentModel.fromMap(Map<String, dynamic> map) {
    return SQLBillPaymentModel(
      id: map['id'],
      billCodeID: map['billCodeID'],
      paymentMethod: map['paymentMethod'],
      amount: map['amount'],
    );
  }

  static Future<List<Map<String, Object?>>> fetchByBillCodeID(int id) async {
    final db = await DatabaseUtils().database;
    var result =
        await db.rawQuery("SELECT * FROM bill_payment WHERE billCodeID = $id");
    return result;
  }

  static Future<void> create(List<SQLBillPaymentModel> payments) async {
    try {
      await DatabaseUtils().runCommands(payments.map((e) {
        return "INSERT INTO bill_payment (billCodeID, paymentMethod, amount) VALUES (${e.billCodeID}, '${e.paymentMethod}', ${e.amount})";
      }).toList());
    } catch (error) {
      throw Exception(error);
    }
  }
}

class SQLBillPaymentModelCreate extends SQLBillPaymentModel {
  SQLBillPaymentModelCreate({
    required super.billCodeID,
    required super.paymentMethod,
    required super.amount,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'paymentMethod': paymentMethod,
      'amount': amount,
    };
  }

  factory SQLBillPaymentModelCreate.fromMap(Map<String, dynamic> map) {
    return SQLBillPaymentModelCreate(
      billCodeID: map['billCodeID'],
      paymentMethod: map['paymentMethod'],
      amount: map['amount'],
    );
  }

  static create(List<SQLBillPaymentModelCreate> payments) async {
    try {
      await DatabaseUtils().runCommands(payments.map((e) {
        return "INSERT INTO bill_payment (billCodeID, paymentMethod, amount) VALUES (${e.billCodeID}, '${e.paymentMethod}', ${e.amount})";
      }).toList());
    } catch (error) {
      throw Exception(error);
    }
  }
}

class SQLBillPaymentModelPrint extends SQLBillPaymentModel {
  SQLBillPaymentModelPrint({
    required super.billCodeID,
    required super.paymentMethod,
    required super.amount,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'paymentMethod': paymentMethod,
      'amount': amount,
    };
  }

  factory SQLBillPaymentModelPrint.fromMap(Map<String, dynamic> map) {
    return SQLBillPaymentModelPrint(
      billCodeID: map['billCodeID'],
      paymentMethod: map['paymentMethod'],
      amount: map['amount'],
    );
  }

  static Future<List<SQLBillPaymentModelPrint>> fetchByBillCodeID(
      int id) async {
    final db = await DatabaseUtils().database;
    var result =
        await db.rawQuery("SELECT * FROM bill_payment WHERE billCodeID = $id");
    return result.map((e) => SQLBillPaymentModelPrint.fromMap(e)).toList();
  }
}

class SQLBillPaymentModelSync {
  int billCodeID;
  String paymentMethod;
  double amount;

  SQLBillPaymentModelSync({
    required this.billCodeID,
    required this.paymentMethod,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'paymentMethod': paymentMethod,
      'amount': amount,
    };
  }

  factory SQLBillPaymentModelSync.fromMap(Map<String, dynamic> map) {
    return SQLBillPaymentModelSync(
      billCodeID: map['billCodeID'],
      paymentMethod: map['paymentMethod'],
      amount: map['amount'],
    );
  }

  static Future<List<SQLBillPaymentModelSync>> fetchByBillCodeIDs(
      List<int> ids) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT * FROM bill_payment WHERE billCodeID IN (${ids.join(",")})");
    return result.map((e) => SQLBillPaymentModelSync.fromMap(e)).toList();
  }
}
