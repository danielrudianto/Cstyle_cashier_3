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
  String note;

  StockTransferModel({
    this.id,
    this.name,
    required this.storeID,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'storeID': storeID,
      'items': items.map((x) => x.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory StockTransferModel.fromMap(Map<String, dynamic> map) {
    return StockTransferModel(
      id: map['id'],
      name: map['name'],
      storeID: map['storeID'],
      items: [],
      createdBy: map['createdBy']['name'],
      createdAt: DateTime.parse(map['createdAt']),
      note: map['note'] ?? "",
    );
  }

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
        "requestTo": storeID,
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

  static Future<void> send(Map<String, dynamic> data) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      await ApiUtils().postRequest("cashier/stock-transfer/send", data,
          Options(headers: {"store": store?.code}));
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> receive(String id, String userCode) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      await ApiUtils().postRequest("cashier/stock-transfer/receive", {"id": id},
          Options(headers: {"store": store?.code, "employee-code": userCode}));
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> reject(String id, String userCode, String note) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      await ApiUtils().postRequest(
          "cashier/stock-transfer/reject",
          {"id": id, "rejectNote": note},
          Options(headers: {"store": store?.code, "employee-code": userCode}));
    } catch (e) {
      throw Exception(e);
    }
  }
}

class StockTransferFetchmodel {
  String? id;
  final String name;
  final Map<String, dynamic>? requestFrom;
  final Map<String, dynamic>? requestTo;
  final List<StockTransferFetchItemModel> items;
  final String createdBy;
  DateTime createdAt;
  final String note;

  StockTransferFetchmodel({
    this.id,
    required this.name,
    required this.requestFrom,
    required this.requestTo,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'requestFrom': requestFrom,
      'items': items.map((x) => x.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory StockTransferFetchmodel.fromMap(Map<String, dynamic> map) {
    return StockTransferFetchmodel(
      id: map['_id'],
      name: map['name'],
      requestFrom: map['requestFrom'],
      requestTo: map['requestTo'],
      items: [],
      createdBy: map['createdBy']['name'],
      createdAt: DateTime.parse(map['createdAt']),
      note: map['note'] ?? "",
    );
  }

  factory StockTransferFetchmodel.fromMapWItems(Map<String, dynamic> map) {
    return StockTransferFetchmodel(
      id: map['_id'],
      name: map['name'],
      requestFrom: map['requestFrom'],
      requestTo: map['requestTo'],
      items: List<StockTransferFetchItemModel>.from(
          map['items'].map((x) => StockTransferFetchItemModel.fromMap(x))),
      createdBy: map['createdBy']['name'],
      createdAt: DateTime.parse(map['createdAt']),
      note: map['note'] ?? "",
    );
  }

  static Future<Map<String, dynamic>> fetchUnsent(int page) async {
    var store = await StoreModel.getCurrentProfile();
    var response = await ApiUtils().getRequest(
        "cashier/stock-transfer/unsent",
        {"page": page},
        Options(
          headers: {"store": store?.code},
        ));

    var data = response['data'];

    return {
      "data": List<StockTransferFetchmodel>.from(
          data.map((x) => StockTransferFetchmodel.fromMap(x))),
      "count": response['count']
    };
  }

  static Future<Map<String, dynamic>> fetchUnreceived(int page) async {
    var store = await StoreModel.getCurrentProfile();
    var response = await ApiUtils().getRequest(
        "cashier/stock-transfer/unreceived",
        {"page": page},
        Options(
          headers: {"store": store?.code},
        ));

    var data = response['data'];

    return {
      "data": List<StockTransferFetchmodel>.from(
          data.map((x) => StockTransferFetchmodel.fromMap(x))),
      "count": response['count']
    };
  }

  static Future<Map<String, dynamic>> fetchCreated(int page) async {
    var store = await StoreModel.getCurrentProfile();
    var response = await ApiUtils().getRequest(
        "cashier/stock-transfer/created",
        {"page": page},
        Options(
          headers: {"store": store?.code},
        ));

    var data = response['data'];

    return {
      "data": List<StockTransferFetchmodel>.from(
          data.map((x) => StockTransferFetchmodel.fromMap(x))),
      "count": response['count']
    };
  }

  static Future<StockTransferFetchmodel> fetchByID(String id) async {
    var store = await StoreModel.getCurrentProfile();
    var response = await ApiUtils().getRequest(
        "cashier/stock-transfer/$id",
        {},
        Options(
          headers: {"store": store?.code},
        ));

    return StockTransferFetchmodel.fromMapWItems(response);
  }
}

class StockTransferItemModel {
  String itemID;
  int quantity;

  StockTransferItemModel({
    required this.itemID,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemID': itemID,
      'quantity': quantity,
    };
  }

  factory StockTransferItemModel.fromMap(Map<String, dynamic> map) {
    return StockTransferItemModel(
      itemID: map['itemID'],
      quantity: map['quantity'],
    );
  }
}

class StockTransferFetchItemModel {
  String id;
  String reference;
  String description;
  int quantity;

  StockTransferFetchItemModel({
    required this.id,
    required this.reference,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'quantity': quantity,
    };
  }

  factory StockTransferFetchItemModel.fromMap(Map<String, dynamic> map) {
    return StockTransferFetchItemModel(
      id: map['itemID']['_id'],
      reference: map['itemID']['reference'],
      description: map['itemID']['description'],
      quantity: map['quantity'],
    );
  }
}
