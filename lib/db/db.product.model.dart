import 'package:cstyle_cashier_3/db/db.product_image.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLProductModel {
  int? id;
  String reference;
  String description;
  String brand;
  String type;
  String? barcode;
  String typeID;
  String brandID;
  String? mongoID;
  double price;
  int stock;
  List<SQLProductImageModel>? images;

  SQLProductModel({
    this.id,
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
    this.barcode,
    required this.typeID,
    required this.brandID,
    this.mongoID,
    this.images,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'barcode': barcode,
      'typeID': typeID,
      'brandID': brandID,
      'mongoID': mongoID,
      'price': price,
      'stock': stock,
    };
  }

  factory SQLProductModel.fromMap(Map<String, dynamic> map) {
    return SQLProductModel(
      id: map['id'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
      barcode: map['barcode'],
      typeID: map['typeID'],
      brandID: map['brandID'],
      mongoID: map['mongoID'],
      price: map['price'],
      stock: map['stock'],
    );
  }

  static Future<SQLProductModel> fetchByBarcode(String barcode) async {
    try {
      final db = await DatabaseUtils().database;
      var result = await db.query("product",
          where: "barcode = ?", whereArgs: [barcode], limit: 1, offset: 0);

      if (result.isNotEmpty) {
        return SQLProductModel.fromMap(result.first);
      } else {
        throw Exception("Product not found");
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<SQLProductModel>> fetchByKeyword(
      List<String> selectedTypes, String keyword, int page) async {
    final db = await DatabaseUtils().database;
    if (selectedTypes.isEmpty) {
      var result = await db.query("product",
          where: "reference LIKE ? OR description LIKE ?",
          limit: 25,
          offset: (page - 1) * 25,
          whereArgs: ["%$keyword%", "%$keyword%"]);
      return result.map((e) => SQLProductModel.fromMap(e)).toList();
    } else {
      var result = await db.query("product",
          where:
              "type IN (${selectedTypes.map((x) => "'${x.replaceAll("'", "'''")}'").join(",")}) AND (reference LIKE ? OR description LIKE ?)",
          limit: 25,
          offset: (page - 1) * 25,
          whereArgs: ["%$keyword%", "%$keyword%"]);
      return result.map((e) => SQLProductModel.fromMap(e)).toList();
    }
  }

  static Future<void> updateStock(String itemID, int quantity) async {
    var db = await DatabaseUtils().database;
    try {
      await db.rawUpdate(
          "UPDATE product SET stock = stock - ? WHERE mongoID = ?;",
          [quantity, itemID]);
    } catch (error) {
      throw Exception(error);
    }
  }
}

class SQLProductType {
  String name;

  SQLProductType({required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory SQLProductType.fromMap(Map<String, dynamic> map) {
    return SQLProductType(
      name: map['name'],
    );
  }

  static Future<List<SQLProductType>> fetchProductTypes() async {
    final db = await DatabaseUtils().database;
    var result =
        await db.rawQuery("SELECT DISTINCT(type) AS name FROM product");
    return result.map((e) => SQLProductType.fromMap(e)).toList();
  }
}

class SQLProductStock {
  String mongoID;
  int stock;
  SQLProductStock({required this.mongoID, required this.stock});

  Map<String, dynamic> toMap() {
    return {
      'mongoID': mongoID,
      'stock': stock,
    };
  }

  factory SQLProductStock.fromMap(Map<String, dynamic> map) {
    return SQLProductStock(
      mongoID: map['mongoID'],
      stock: map['stock'],
    );
  }

  static Future<void> updateServerStock(List<SQLProductStock> data) async {
    List<String> commands = [];
    commands.add("UPDATE product SET stock = 0;");

    for (var item in data) {
      commands.add(
          "UPDATE product SET stock = ${item.stock} WHERE mongoId = '${item.mongoID}';");
    }

    try {
      await DatabaseUtils().runCommands(commands);
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> updateCurrentStock(List<SQLProductStock> data) async {
    List<String> commands = [];

    for (var item in data) {
      commands.add(
          "UPDATE product SET stock = stock - ${item.stock} WHERE mongoId = '${item.mongoID}';");
    }
  }
}
