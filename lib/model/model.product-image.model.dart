import 'package:cstyle_cashier_3/db/db.product_image.model.dart';

class ProductImageModel {
  int id;
  String imageUrl;
  String productId;

  ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'productId': productId,
    };
  }

  factory ProductImageModel.fromMap(Map<String, dynamic> map) {
    return ProductImageModel(
      id: map['id'],
      imageUrl: map['imageUrl'],
      productId: map['productId'],
    );
  }

  static Future<List<ProductImageModel>> fetchByItemIDs(List<int> ids) async {
    try {
      var images = await SQLProductImageModel.fetchByItemIDs(ids);
      return images.map((x) {
        return ProductImageModel(
          id: x.id!,
          imageUrl: x.imageUrl,
          productId: x.productId,
        );
      }).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
