import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class ProductStockModel {
  String mongoID;
  int stock;

  ProductStockModel({
    required this.mongoID,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'mongoId': mongoID,
      'stock': stock,
    };
  }

  factory ProductStockModel.fromMap(Map<String, dynamic> map) {
    return ProductStockModel(
      mongoID: map['mongoID'],
      stock: map['stock'],
    );
  }

  static Future<List<ProductStockModel>> fetchServerStock(
      String storeCode) async {
    try {
      var response = await ApiUtils().getRequest(
          "cashier/products/stock", {}, Options(headers: {"store": storeCode}));

      // return response.map((e) => ProductStockModel.fromMap(e)).toList();
      List<ProductStockModel> result = [];
      response.forEach((e) {
        result.add(
          ProductStockModel(
            mongoID: e['mongoID'],
            stock: e['stock'] as int,
          ),
        );
      });

      await SQLProductModel.updateStockBulk(result);

      return result;
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> updateServerStock(List<ProductStockModel> data) async {
    try {
      // Use server stock as base
      await SQLProductStock.updateServerStock(
        data.map((e) {
          return SQLProductStock(
            mongoID: e.mongoID,
            stock: e.stock,
          );
        }).toList(),
      );
      var existingData = await SQLBillSync.fetchSumOfUnsychronizedStock();
      await SQLProductStock.updateCurrentStock(
        existingData.map((e) {
          return SQLProductStock(
            mongoID: e.mongoID,
            stock: e.quantity,
          );
        }).toList(),
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}

class ProductStockFetchModel {
  List<ProductStockFetchItemModel> data;
  List<StoreModel> stores;
  int count;

  ProductStockFetchModel({
    required this.data,
    required this.stores,
    required this.count,
  });

  // static Future<List<ProductStockModel>> checkServerStock(
  static Future<ProductStockFetchModel> checkServerStock(
      int page, String keyword) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      var result = await ApiUtils().postRequest(
        "/cashier/products/stock",
        {
          "page": page,
          "keyword": keyword,
        },
        Options(headers: {
          "store": store?.code,
        }),
      );

      List<StoreModel> stores = [
        StoreModel(
          id: null,
          name: "OFFICE",
          address: "Jalan Kerobokan no. 87A, Denpasar",
        )
      ];
      List<ProductStockFetchItemModel> data = [];

      result['store'].forEach((x) {
        stores.add(
          StoreModel(
            name: x['name'],
            address: x['address'],
            id: x['_id'],
          ),
        );
      });

      result['data'].forEach((x) {
        data.add(ProductStockFetchItemModel.fromMap(x));
      });
      var count = result['count'] as int;
      return ProductStockFetchModel(data: data, stores: stores, count: count);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class ProductStockFetchItemModel {
  String id;
  String reference;
  String description;
  String brand;
  String type;
  List<ProductStockFetchStoreModel> stock;

  ProductStockFetchItemModel({
    required this.id,
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'stock': stock,
    };
  }

  factory ProductStockFetchItemModel.fromMap(Map<String, dynamic> map) {
    List<ProductStockFetchStoreModel> stocks = [];
    map['stock'].forEach((x) {
      stocks.add(ProductStockFetchStoreModel(
          storeID: x['storeID'], quantity: x['quantity']));
    });
    return ProductStockFetchItemModel(
      id: map['id'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
      stock: stocks,
    );
  }
}

class ProductStockFetchStoreModel {
  String? storeID;
  int quantity;

  ProductStockFetchStoreModel({
    this.storeID,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'quantity': quantity,
    };
  }

  factory ProductStockFetchStoreModel.fromMap(Map<String, dynamic> map) {
    return ProductStockFetchStoreModel(
      storeID: map['storeID'],
      quantity: map['quantity'],
    );
  }
}
