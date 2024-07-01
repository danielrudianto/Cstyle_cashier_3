import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';
import 'package:dio/dio.dart';

class MemberModel {
  String id;
  String code;
  String name;
  String phoneNumber;
  String email;
  String? nationality;
  DateTime? birthday;
  int points;

  MemberModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.nationality,
    this.birthday,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'nationality': nationality,
      'birthday': birthday,
      'points': points,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      nationality: map['nationality'],
      birthday: map['birthday'],
      points: map['points']?.toInt() ?? 0,
    );
  }

  static Future<MemberModel?> fetchByCode(String code) async {
    try {
      var store = await SQLStoreModel.getCurrentProfile();
      var membership = await ApiUtils().getRequest(
          "cashier/membership/code/$code",
          {},
          Options(headers: {"store": store!.code}));

      if (membership == null) {
        return null;
      } else {
        return MemberModel.fromMap(membership);
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
