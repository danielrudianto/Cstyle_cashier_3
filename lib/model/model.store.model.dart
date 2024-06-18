import 'package:cstyle_cashier_3/model/db.store.model.dart';

class StoreModel {
  final String name;
  final String address;
  final String code;

  StoreModel({
    required this.name,
    required this.address,
    required this.code,
  });

  Future<StoreModel> create() async {
    var result =
        await SQLStoreModel(name: name, address: address, code: code).create();
    if (result == null) {
      throw Exception("Failed to create new store");
    } else {
      return StoreModel(
          name: result.name, address: result.address, code: result.code);
    }
  }

  static Future<StoreModel?> checkStoreUID(String code) async {
    try {
      var stores = await SQLStoreModel.checkStoreUID(code);
      if (stores == null) return null;
      return StoreModel(
        name: stores.name,
        address: stores.address,
        code: code,
      );
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
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
