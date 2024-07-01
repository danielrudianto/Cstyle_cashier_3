import 'package:cstyle_cashier_3/db/db.user.model.dart';

class UserModel {
  String id;
  String code;
  String name;

  UserModel({
    required this.id,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
    );
  }

  static Future<UserModel?> fetchByCode(String code) async {
    try {
      var user = await SQLUserModel.fetchByCode(code);
      return user != null
          ? UserModel(
              id: user.userID,
              name: user.name,
              code: user.code,
            )
          : null;
    } catch (error) {
      throw Exception(error);
    }
  }
}
