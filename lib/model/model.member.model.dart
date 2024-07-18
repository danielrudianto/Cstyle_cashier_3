import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';
import 'package:cstyle_cashier_3/view/store/store.page.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class MemberModel {
  String? id;
  String code;
  String name;
  String phoneNumber;
  String email;
  String? nationality;
  DateTime? birthday;
  int points;
  language lang;
  String createdBy;

  MemberModel({
    this.id,
    required this.code,
    required this.name,
    this.nationality,
    required this.email,
    required this.phoneNumber,
    this.birthday,
    required this.points,
    required this.lang,
    required this.createdBy,
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
      id: map['_id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      nationality: map['nationality'],
      birthday: map['birthday'],
      points: map['points']?.toInt() ?? 0,
      lang: map['language'] == "EN" ? language.EN : language.ID,
      createdBy: map['createdBy'] ?? '',
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

  create() async {
    try {
      var store = await SQLStoreModel.getCurrentProfile();
      var membership = await ApiUtils().postRequest(
          "cashier/membership",
          {
            "code": code,
            "name": name,
            "phoneNumber": phoneNumber == "" ? null : phoneNumber,
            "email": email == "" ? null : email,
            "nationality": nationality,
            "birthday": birthday == null
                ? null
                : DateFormat("yyyy-MM-dd").format(birthday!),
            "points": points,
            "language": lang.name,
            "createdBy": createdBy,
          },
          Options(headers: {"store": store!.code}));

      return membership;
    } catch (error) {
      throw Exception(error);
    }
  }
}
