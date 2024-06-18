import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLCartCodeModel {
  int? id;
  String name;
  String date;
  String? memberID;

  SQLCartCodeModel({
    this.id,
    required this.name,
    required this.date,
    this.memberID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'memberID': memberID,
    };
  }

  factory SQLCartCodeModel.fromMap(Map<String, dynamic> map) {
    return SQLCartCodeModel(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      memberID: map['memberID'],
    );
  }

  Future<SQLCartCodeModel?> create() async {
    var db = await DatabaseUtils().database;
    db.insert("cart_code",
        {"name": name, "date": DateTime.now().toString(), "memberID": null});

    var cart =
        await db.query("cart_code", limit: 1, offset: 0, orderBy: "id DESC");

    if (cart.isEmpty) {
      return null;
    } else {
      return SQLCartCodeModel.fromMap(cart.first);
    }
  }

  Future<List<SQLCartCodeModel>> getList() async {
    var database = await DatabaseUtils().database;
    var result = await database.query("cart_code", orderBy: "id DESC");

    return result.map((e) => SQLCartCodeModel.fromMap(e)).toList();
  }

  Future<int> getCount() async {
    var database = await DatabaseUtils().database;
    var result =
        await database.rawQuery("SELECT COUNT(*) AS count FROM cart_code");

    if (result.isNotEmpty) {
      var count = int.parse(result.first["count"].toString());
      return count;
    } else {
      return 0;
    }
  }

  static Future<void> delete(int id) async {
    var database = await DatabaseUtils().database;
    try {
      await database.execute(
          "BEGIN; DELETE FROM cart WHERE cart_code_id = $id; DELETE FROM cart_code WHERE id = $id; COMMIT;");
    } catch (error) {
      rethrow;
    }
  }
}
