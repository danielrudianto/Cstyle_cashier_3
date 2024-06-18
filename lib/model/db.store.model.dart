import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLStoreModel {
  int? id;
  String name;
  String address;
  String code;

  SQLStoreModel({
    this.id,
    required this.name,
    required this.address,
    required this.code,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'code': code,
    };
  }

  factory SQLStoreModel.fromMap(Map<String, dynamic> map) {
    return SQLStoreModel(
      name: map['name'],
      address: map['address'],
      code: map['code'],
    );
  }

  Future<SQLStoreModel?> create() async {
    final db = await DatabaseUtils().database;
    try {
      var storeID = await db.insert("store", {
        "name": name,
        "address": address,
        "code": code,
      });

      if (storeID == 0) {
        return null;
      } else {
        return SQLStoreModel(
          name: name,
          address: address,
          code: code,
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<SQLStoreModel?> getCurrentProfile() async {
    final db = await DatabaseUtils().database;
    var result = await db.query("store", limit: 1, offset: 0);
    if (result.isNotEmpty) {
      return SQLStoreModel.fromMap(result.first);
    } else {
      return null;
    }
  }

  static Future<SQLStoreModel?> checkStoreUID(String uid) async {
    if (RegExp(r"^[0-9a-fA-F]{32}$").hasMatch(uid)) {
      var response = await ApiUtils().getRequest("cashier/check/$uid");
      return SQLStoreModel.fromMap(response);
    } else {
      throw Exception("Invalid Store UID");
    }
  }
}
