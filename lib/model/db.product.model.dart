import 'package:cstyle_cashier_3/model/db.product_image.model.dart';
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
  String? mongoId;
  double price;
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
    this.mongoId,
    this.images,
    required this.price,
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
      'mongoId': mongoId,
      'price': price
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
      mongoId: map['mongoId'],
      price: map['price'],
    );
  }

  static Future<List<SQLProductModel>> fetchByBarcode(String barcode) async {
    final db = await DatabaseUtils().database;
    var result =
        await db.query("product", where: "barcode = ?", whereArgs: [barcode]);

    return result.map((e) => SQLProductModel.fromMap(e)).toList();
  }

  static Future<List<SQLProductModel>> fetchByKeyword(
      String keyword, int page) async {
    final db = await DatabaseUtils().database;
    var result = await db.query("product",
        where: "reference LIKE ? OR description LIKE ?",
        limit: 10,
        offset: (page - 1) * 10,
        whereArgs: ["%$keyword%", "%$keyword%"]);
    return result.map((e) => SQLProductModel.fromMap(e)).toList();
  }

  static Future<List<String>> fetchProductTypes() async {
    final db = await DatabaseUtils().database;
    var result =
        await db.rawQuery("SELECT DISTINCT(type) AS type FROM product");
    return result.map((e) => e['type'] as String).toList();
  }
}
