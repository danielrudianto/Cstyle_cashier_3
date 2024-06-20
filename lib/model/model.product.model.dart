import 'package:cstyle_cashier_3/model/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.product-image.model.dart';

class ProductModel {
  int id;
  String reference;
  String description;
  String brand;
  String type;
  String? barcode;
  num price;
  num? stock;
  List<ProductImageModel>? images;

  ProductModel({
    required this.id,
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
    this.barcode,
    required this.price,
    this.stock,
    this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'barcode': barcode,
      'price': price,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
      barcode: map['barcode'],
      price: map['price'],
      stock: map['stock'],
    );
  }

  static Future<List<ProductModel>> fetch(
      List<String> selectedTypes, String keyword, int page) async {
    List<ProductModel> result = [];
    var products =
        await SQLProductModel.fetchByKeyword(selectedTypes, keyword, page);
    var productImages =
        await ProductImageModel.fetchByItemIDs(products.map((x) {
      return x.id!;
    }).toList());

    for (var i = 0; i < products.length; i++) {
      result.add(ProductModel(
        id: products[i].id!,
        reference: products[i].reference,
        description: products[i].description,
        brand: products[i].brand,
        type: products[i].type,
        barcode: products[i].barcode,
        price: products[i].price,
        stock: products[i].stock,
        images: productImages
            .where((x) => x.productId == products[i].mongoId!)
            .toList(),
      ));
    }

    return result;
  }

  static Future<ProductModel?> fetchByBarcode(String barcode) async {
    var products = await SQLProductModel.fetchByBarcode(barcode);
    if (products.isEmpty) return null;
    var productImages =
        await ProductImageModel.fetchByItemIDs([products[0].id!]);
    return ProductModel(
      id: products[0].id!,
      reference: products[0].reference,
      description: products[0].description,
      brand: products[0].brand,
      type: products[0].type,
      barcode: products[0].barcode,
      price: products[0].price,
      stock: products[0].stock,
      images: productImages
          .where((x) => x.productId == products[0].mongoId!)
          .toList(),
    );
  }
}
