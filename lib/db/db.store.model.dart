import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLStoreModel {
  int? id;
  String name;
  String address;
  String code;
  String phoneNumber;

  SQLStoreModel({
    this.id,
    required this.name,
    required this.address,
    required this.code,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'code': code,
      'phoneNumber': phoneNumber,
    };
  }

  factory SQLStoreModel.fromMap(Map<String, dynamic> map) {
    return SQLStoreModel(
      name: map['name'],
      address: map['address'],
      code: map['code'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Future<SQLStoreModel?> create() async {
    final db = await DatabaseUtils().database;
    try {
      await db.delete("store", where: "code = ?", whereArgs: [code]);
      var storeID = await db.insert("store", toMap());

      if (storeID == 0) {
        throw Exception("Failed to create store");
      } else {
        return SQLStoreModel(
          name: name,
          address: address,
          code: code,
          phoneNumber: phoneNumber,
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<SQLStoreModel?> getCurrentProfile() async {
    try {
      final db = await DatabaseUtils().database;
      var result = await db.query("store", limit: 1, offset: 0);
      if (result.isNotEmpty) {
        return SQLStoreModel.fromMap(result.first);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<SQLStoreModel?> checkStoreUID(String uid) async {
    if (RegExp(r"^[0-9a-fA-F]{32}$").hasMatch(uid)) {
      var response =
          await ApiUtils().getRequest("cashier/check/$uid", {}, null);
      return SQLStoreModel.fromMap(response);
    } else {
      throw Exception("Invalid Store UID");
    }
  }
}
