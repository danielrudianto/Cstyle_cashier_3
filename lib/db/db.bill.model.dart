import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLBillModel {
  int? id;
  String itemID;
  int quantity;
  double price;
  double discount;
  int billCodeID;

  SQLBillModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.billCodeID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'billCodeID': billCodeID,
    };
  }

  factory SQLBillModel.fromMap(Map<String, dynamic> map) {
    return SQLBillModel(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      billCodeID: map['billCodeID'],
    );
  }

  static Future<List<SQLBillModel>> fetchByBillCodeIDs(List<int> ids) async {
    final db = await DatabaseUtils().database;

    var result =
        await db.query("bill", where: "billCodeID IN (${ids.join(",")})");
    return result.map((e) => SQLBillModel.fromMap(e)).toList();
  }
}

class SQLBillModelPrint extends SQLBillModel {
  String reference;
  String description;
  String brand;
  String type;

  SQLBillModelPrint({
    required super.id,
    required super.itemID,
    required super.quantity,
    required super.price,
    required super.discount,
    required super.billCodeID,
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'billCodeID': billCodeID,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
    };
  }

  factory SQLBillModelPrint.fromMap(Map<String, dynamic> map) {
    return SQLBillModelPrint(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      billCodeID: map['billCodeID'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
    );
  }

  static Future<List<SQLBillModelPrint>> fetchByBillCodeID(int id) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT bill.id, bill.itemID, bill.quantity, bill.price, bill.discount, bill.billCodeID, product.reference, product.description, product.brand, product.type FROM bill JOIN product ON bill.itemID = product.mongoID WHERE billCodeID = $id");
    return result.map((e) {
      return SQLBillModelPrint.fromMap(e);
    }).toList();
  }
}

class SQLBillSync {
  int quantity;
  String mongoID;
  SQLBillSync({required this.quantity, required this.mongoID});

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'mongoID': mongoID,
    };
  }

  factory SQLBillSync.fromMap(Map<String, dynamic> map) {
    return SQLBillSync(
      quantity: map['quantity'],
      mongoID: map['mongoID'],
    );
  }

  static Future<List<SQLBillSync>> fetchSumOfUnsychronizedStock() async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT SUM(quantity) AS quantity, product.mongoID FROM bill JOIN product ON bill.itemID = product.id JOIN bill_code ON bill.billCodeID = bill_code.id WHERE bill_code.isSynced = 0 GROUP BY product.mongoID");

    return result.toList().map((e) {
      return SQLBillSync.fromMap(e);
    }).toList();
  }
}

class SQLBillModelCreate {
  String itemID;
  int quantity;
  double price;
  double discount;
  int billCodeID;

  SQLBillModelCreate({
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.billCodeID,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'billCodeID': billCodeID,
    };
  }

  factory SQLBillModelCreate.fromMap(Map<String, dynamic> map) {
    return SQLBillModelCreate(
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      billCodeID: map['billCodeID'],
    );
  }

  static Future<void> create(List<SQLBillModelCreate> bills) async {
    try {
      await DatabaseUtils().runCommands(bills.map((e) {
        return "INSERT INTO bill (itemID, quantity, price, discount, billCodeID) VALUES ('${e.itemID}', ${e.quantity}, ${e.price}, ${e.discount}, ${e.billCodeID});";
      }).toList());
    } catch (error) {
      throw Exception(error);
    }
  }
}

class SQLBillModelSync {
  int billCodeID;
  int quantity;
  double price;
  double discount;
  String itemID;

  SQLBillModelSync({
    required this.billCodeID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.itemID,
  });

  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'itemID': itemID,
    };
  }

  factory SQLBillModelSync.fromMap(Map<String, dynamic> map) {
    return SQLBillModelSync(
      billCodeID: map['billCodeID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      itemID: map['itemID'],
    );
  }

  static Future<List<SQLBillModelSync>> fetchByBillCodeIDs(
      List<int> ids) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT bill.quantity, bill.price, bill.discount, bill.itemID, bill.billCodeID FROM bill WHERE billCodeID IN (${ids.join(",")})");
    return result.toList().map((e) {
      return SQLBillModelSync.fromMap(e);
    }).toList();
  }
}
