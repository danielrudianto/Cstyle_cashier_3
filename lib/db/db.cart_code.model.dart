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
    final db = await DatabaseUtils().database;
    int id = await db.insert("cart_code", toMap());
    if (id == 0) {
      throw Exception("Faild to create cart code");
    } else {
      return SQLCartCodeModel(
        id: id,
        name: name,
        date: date,
        memberID: memberID,
      );
    }
  }

  static Future<List<SQLCartCodeModel>> fetchCarts() async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "cart_code",
      orderBy: "id DESC",
    );

    return result.map((e) => SQLCartCodeModel.fromMap(e)).toList();
  }

  Future<List<SQLCartCodeModel>> getList() async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "cart_code",
      orderBy: "id DESC",
    );

    return result.map((e) => SQLCartCodeModel.fromMap(e)).toList();
  }

  static Future<int> getCount() async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery("SELECT COUNT(*) AS count FROM cart_code");

    if (result.isNotEmpty) {
      var count = int.parse(result.first["count"].toString());
      return count;
    } else {
      return 0;
    }
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseUtils().database;
    try {
      await db.transaction((txn) async {
        await txn.delete("cart", where: "cartCodeID = ?", whereArgs: [id]);
        await txn.delete("cart_code", where: "id = ?", whereArgs: [id]);
      });
    } catch (error) {
      throw Exception("Failed to delete cart code with ID $id: $error");
    }
  }

  static Future<SQLCartCodeModel> fetchByID(int id) async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "cart_code",
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw Exception("Cart not found");
    } else {
      return SQLCartCodeModel.fromMap(result.first);
    }
  }

  static Future<SQLCartCodeModel> fetchByName(String name) async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "cart_code",
      where: "name = ?",
      whereArgs: [name],
    );

    if (result.isEmpty) {
      throw Exception("Cart not found");
    } else {
      return SQLCartCodeModel.fromMap(result.first);
    }
  }
}
