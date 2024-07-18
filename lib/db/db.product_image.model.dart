import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLProductImageModel {
  int? id;
  String productId;
  String imageUrl;

  SQLProductImageModel({
    this.id,
    required this.productId,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
    };
  }

  factory SQLProductImageModel.fromMap(Map<String, dynamic> map) {
    return SQLProductImageModel(
      id: map['id'],
      productId: map['productID'],
      imageUrl: map['imageUrl'],
    );
  }

  static Future<List<SQLProductImageModel>> fetchByItemID(String id) async {
    try {
      final db = await DatabaseUtils().database;
      var result = await db
          .query("product_image", where: "productID = ?", whereArgs: [id]);
      return result.map((e) => SQLProductImageModel.fromMap(e)).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
