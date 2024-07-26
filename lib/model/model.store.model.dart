import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class StoreModel {
  String? id;
  final String name;
  final String address;
  String? code;
  String? phoneNumber;

  StoreModel({
    this.id,
    required this.name,
    required this.address,
    this.code,
    this.phoneNumber,
  });

  Future<StoreModel> create() async {
    var result = await SQLStoreModel(
      name: name,
      address: address,
      code: code!,
      phoneNumber: phoneNumber!,
    ).create();
    if (result == null) {
      throw Exception("Failed to create new store");
    } else {
      return StoreModel(
        name: result.name,
        address: result.address,
        code: result.code,
        phoneNumber: result.phoneNumber,
      );
    }
  }

  static Future<StoreModel> checkStoreUID(String code) async {
    try {
      var store = await SQLStoreModel.checkStoreUID(code);
      if (store == null) {
        throw Exception("Failed to create new store");
      } else {
        return StoreModel(
          name: store.name,
          address: store.address,
          code: code,
          phoneNumber: store.phoneNumber,
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<StoreModel?> getCurrentProfile() async {
    try {
      var store = await SQLStoreModel.getCurrentProfile();
      if (store == null) {
        return null;
      } else {
        return StoreModel(
            name: store.name,
            address: store.address,
            code: store.code,
            phoneNumber: store.phoneNumber);
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<StoreModel>> fetchStores() async {
    try {
      var store = await getCurrentProfile();
      var stores = await ApiUtils().getRequest(
          "cashier/stores",
          {},
          Options(headers: {
            "store": store?.code,
          }));

      return List<StoreModel>.from(stores.map((store) => StoreModel(
            id: store["_id"],
            name: store["name"],
            address: store["address"],
            code: store["code"],
            phoneNumber: store["phoneNumber"],
          )));
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<num>> fetchStats(int period) async {
    try {
      var store = await getCurrentProfile();
      var stats = await ApiUtils().getRequest(
          "cashier/stats",
          {"period": period},
          Options(headers: {
            "store": store?.code,
          }));
      return List<num>.from(stats);
    } catch (error) {
      throw Exception(error);
    }
  }
}
