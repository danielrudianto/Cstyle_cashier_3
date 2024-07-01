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
      productId: map['productId'],
      imageUrl: map['imageUrl'],
    );
  }

  static Future<List<SQLProductImageModel>> fetchByItemIDs(
      List<int> ids) async {
    List<SQLProductImageModel> result = [];
    final db = await DatabaseUtils().database;
    db
        .query(
      "product_image",
      where: "productId in (${ids.join(',')})",
    )
        .then(
      (value) {
        result = value
            .map((e) => SQLProductImageModel.fromMap(e))
            .toList()
            .cast<SQLProductImageModel>();
      },
    );
    return result;
  }
}
