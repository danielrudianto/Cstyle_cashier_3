import 'package:cstyle_cashier_3/db/db.product.model.dart';

class ProductTypeModel {
  String name;

  ProductTypeModel({
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory ProductTypeModel.fromMap(Map<String, dynamic> map) {
    return ProductTypeModel(
      name: map['name'],
    );
  }

  static Future<List<ProductTypeModel>> getList() async {
    var result = await SQLProductType.fetchProductTypes();
    return result.map((e) => ProductTypeModel(name: e.name)).toList();
  }
}
