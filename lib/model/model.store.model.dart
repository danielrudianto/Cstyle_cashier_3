import 'package:cstyle_cashier_3/db/db.store.model.dart';

class StoreModel {
  final String name;
  final String address;
  final String code;
  final String phoneNumber;

  StoreModel({
    required this.name,
    required this.address,
    required this.code,
    required this.phoneNumber,
  });

  Future<StoreModel> create() async {
    var result = await SQLStoreModel(
      name: name,
      address: address,
      code: code,
      phoneNumber: phoneNumber,
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
}
