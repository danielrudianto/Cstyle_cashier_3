import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.product-image.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class ProductModel {
  String id;
  String reference;
  String description;
  String brand;
  String type;
  String? barcode;
  double price;
  int? stock;
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
        id: products[i].mongoID!,
        reference: products[i].reference,
        description: products[i].description,
        brand: products[i].brand,
        type: products[i].type,
        barcode: products[i].barcode,
        price: products[i].price,
        stock: products[i].stock,
        images: productImages
            .where((x) => x.productId == products[i].mongoID!)
            .toList(),
      ));
    }

    return result;
  }

  static Future<ProductModel?> fetchByBarcode(String barcode) async {
    try {
      var products = await SQLProductModel.fetchByBarcode(barcode);
      return ProductModel.fromMap(products.toMap());
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<bool> checkStock(Map<String, int> modifiedCartItems) async {
    var products =
        await SQLProductModel.fetchByItemIDs(modifiedCartItems.keys.toList());
    for (var modifiedCartItem in modifiedCartItems.entries) {
      var stock =
          products.firstWhere((x) => x.mongoID == modifiedCartItem.key).stock;

      if (stock < modifiedCartItem.value) {
        return false;
      }
    }
    return true;
  }

  static Future<List<ProductModel>> fetchServerProducts(
      int page, String? storeID, String keyword) async {
    var store = await StoreModel.getCurrentProfile();
    var result = await ApiUtils().postRequest(
        "cashier/product",
        {
          "page": page,
          "targetStoreID": storeID == "0" ? null : storeID,
          "keyword": keyword,
        },
        Options(headers: {
          "store": store?.code,
        }));

    List<ProductModel> products = [];
    for (var i = 0; i < result['data'].length; i++) {
      products.add(ProductModel(
        id: result['data'][i]['item']['_id'],
        reference: result['data'][i]['item']['reference'],
        description: result['data'][i]['item']['description'],
        brand: result['data'][i]['item']['brand'],
        type: result['data'][i]['item']['type'],
        price: double.parse(result['data'][i]['item']['price'].toString()),
        stock: result['data'][i]['quantity'],
      ));
    }

    return products;
  }
}

class ProductModelStockTransfer extends ProductModel {
  int quantity;

  ProductModelStockTransfer({
    required String id,
    required String reference,
    required String description,
    required String brand,
    required String type,
    String? barcode,
    required double price,
    required int stock,
    required this.quantity,
  }) : super(
          id: id,
          reference: reference,
          description: description,
          brand: brand,
          type: type,
          barcode: barcode,
          price: price,
          stock: stock,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'quantity': quantity,
    };
  }
}
