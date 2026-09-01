import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLCartCodeModel {
  int? id;
  String name;
  String date;
  String? memberID;

  /// Jumlah satuan barang di dalam keranjang ini.
  ///
  /// Hanya terisi oleh [fetchCarts]; jalur lain tidak membutuhkannya dan
  /// tidak membayar biaya menghitungnya.
  final int jumlahUnit;

  /// Total keranjang ini, dihitung dengan rumus yang sama persis dengan
  /// yang dipakai layar kasir.
  final double total;

  SQLCartCodeModel({
    this.id,
    required this.name,
    required this.date,
    this.memberID,
    this.jumlahUnit = 0,
    this.total = 0,
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
      jumlahUnit: (map['jumlahUnit'] as int?) ?? 0,
      total: ((map['total'] as num?) ?? 0).toDouble(),
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

  /// Nota tertahan, LENGKAP dengan ringkasan isinya.
  ///
  /// Dulu SELECT * dari cart_code saja, sehingga panel nota tertahan hanya
  /// punya nomor dan tanggal untuk ditampilkan — dan enam nota pada hari yang
  /// sama praktis tidak bisa dibedakan.
  ///
  /// Penjumlahan totalnya SENGAJA mengulang rumus di CartNotifier.updatePrice:
  /// tiap baris dibulatkan ke bawah ke ribuan terdekat, baru dijumlahkan.
  /// Menjumlahkan dulu lalu membulatkan menghasilkan angka yang berbeda, dan
  /// nota yang menampilkan total berbeda dari yang dibayar adalah cacat yang
  /// jauh lebih mahal daripada panel yang kosong.
  ///
  /// CAST ke INTEGER di SQLite memotong ke arah nol, yang sama dengan floor
  /// untuk nilai positif — dan harga tidak pernah negatif di sini.
  static Future<List<SQLCartCodeModel>> fetchCarts() async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery('''
      SELECT
        cart_code.*,
        COALESCE(SUM(cart.quantity), 0) AS jumlahUnit,
        COALESCE(SUM(
          CAST(cart.quantity * cart.price * (100 - cart.discount) / 100000
               AS INTEGER) * 1000
        ), 0) AS total
      FROM cart_code
      LEFT JOIN cart ON cart.cartCodeID = cart_code.id
      GROUP BY cart_code.id
      ORDER BY cart_code.id DESC
    ''');

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

  /// Apakah sebuah nama sudah dipakai keranjang mana pun.
  ///
  /// Ada karena [fetchByName] MELEMPAR saat tidak ketemu — tepat untuk
  /// mengambil, canggung untuk sekadar bertanya ada atau tidak.
  static Future<bool> adaDenganNama(String name) async {
    final db = await DatabaseUtils().database;
    var result = await db.query(
      "cart_code",
      columns: ["id"],
      where: "name = ?",
      whereArgs: [name],
      limit: 1,
    );
    return result.isNotEmpty;
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
