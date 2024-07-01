import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
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
          "cashier/stock", {}, Options(headers: {"store": storeCode}));

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
