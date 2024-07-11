import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class StockTransferModel {
  // storeID can be string | null
  String? id;
  String? name;
  final String? storeID;
  final List<StockTransferItemModel> items;
  final String createdBy;
  DateTime createdAt;
  final String note;

  StockTransferModel({
    this.id,
    this.name,
    required this.storeID,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    required this.note,
  });

  create() async {
    var store = await StoreModel.getCurrentProfile();
    if (store == null) {
      throw Exception("Store not found");
    }

    return ApiUtils().postRequest(
      "cashier/stock-transfer",
      {
        // date to be YYYY-MM-DD
        "date": createdAt.toIso8601String().split("T")[0],
        "requestFrom": store.id,
        "requesetTo": storeID,
        "item": items
            .map((e) => {
                  "id": e.itemID,
                  "quantity": e.quantity,
                })
            .toList(),
        "userID": createdBy,
        "note": note,
      },
      Options(
        headers: {"store": store.code},
      ),
    );
  }
}

class StockTransferItemModel {
  String itemID;
  int quantity;

  StockTransferItemModel({
    required this.itemID,
    required this.quantity,
  });
}
