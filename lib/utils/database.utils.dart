import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  // Connect to database
  static final DatabaseUtils _instance = DatabaseUtils._internal();
  static Database? _database;

  factory DatabaseUtils() {
    return _instance;
  }

  DatabaseUtils._internal();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationSupportDirectory();
    String path = join(documentsDirectory.path, "cstyle (DO NOT DELETE).db");
    return await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bill_code (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        memberID TEXT,
        createdBy TEXT NOT NULL,
        createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        is_delete INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        deletedBy TEXT DEFAULT NULL,
        deletedAt TEXT DEFAULT NULL,
        mongoID TEXT UNIQUE NOT NULL,
        syncedAt DATETIME DEFAULT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bill (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemID TEXT NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity >= 1),
        price REAL NOT NULL,
        discount REAL NOT NULL,
        bill_code_id INTEGER,
        FOREIGN KEY (bill_code_id) REFERENCES bill_code (id)
        FOREIGN KEY (itemID) REFERENCES product (mongoID)
      )
    ''');

    await db.execute('''
      CREATE TABLE bill_payment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_code_id INTEGER,
        payment_method_id TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (bill_code_id) REFERENCES bill_code (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        description TEXT NOT NULL,
        brand TEXT NOT NULL,
        type TEXT NOT NULL,
        barcode TEXT,
        price REAL NOT NULL,
        brandID TEXT NOT NULL,
        typeID TEXT NOT NULL,
        mongoID TEXT UNIQUE NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE product_image (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productID TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        FOREIGN KEY (productID) REFERENCES product (mongoID)
      )
    ''');

    await db.execute('''
      CREATE TABLE migration (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        migration_version TEXT,
        createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userID TEXT UNIQUE NOT NULL,
        employeeCode TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_code (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        memberID TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemID TEXT NOT NULL,
        quantity INTEGER NOT NULL CHECK (quantity >= 1),
        price REAL NOT NULL,
        discount REAL NOT NULL,
        cart_code_id INTEGER,
        FOREIGN KEY (cart_code_id) REFERENCES cart_code (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE store (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL
      )
      ''');
  }

  Future runCommands(List<String> command) async {
    final db = await database;
    command.insert(0, "BEGIN TRANSACTION;");
    command.add("COMMIT;");
    return await db.execute(command.join(" "));
  }

  Future runCommand(String command) async {
    final db = await database;
    return await db.execute(command);
  }
}
