import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLUserModel {
  int? id;
  String userID;
  String code;
  String name;

  SQLUserModel({
    this.id,
    required this.userID,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userID': userID,
      'code': code,
    };
  }

  factory SQLUserModel.fromMap(Map<String, dynamic> map) {
    return SQLUserModel(
      id: map['id'],
      userID: map['userID'],
      code: map['code'],
      name: map['name'],
    );
  }

  static Future<SQLUserModel?> fetchByCode(String code) async {
    try {
      final db = await DatabaseUtils().database;
      var result = await db.query(
        "user",
        where: "code = ?",
        whereArgs: [code],
        limit: 1,
        offset: 0,
      );
      if (result.isEmpty) {
        return null;
      } else {
        return SQLUserModel.fromMap(result.first);
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
