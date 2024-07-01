import 'dart:convert';

import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLCartModel {
  int? id;
  String itemID;
  int quantity;
  double price;
  double discount;
  int cartCodeID;

  SQLCartModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.cartCodeID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'cartCodeID': cartCodeID,
    };
  }

  factory SQLCartModel.fromMap(Map<String, dynamic> map) {
    return SQLCartModel(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      cartCodeID: map['cartCodeID'],
    );
  }

  static Future<int> addProduct(ProductModel product, int cartID) async {
    final db = await DatabaseUtils().database;
    try {
      var id = await db.insert("cart", {
        "itemID": product.id,
        "quantity": 1,
        "price": product.price,
        "discount": 0,
        "cartCodeID": cartID,
      });

      if (id == 0) {
        throw Exception("Failed to add product to cart");
      }
      return id;
    } catch (error) {
      throw Exception("Error adding product to cart: $error");
    }
  }

  static Future<void> updateQuantityDiscount(
      int id, int quantity, double discount) async {
    final db = await DatabaseUtils().database;
    try {
      var count = await db.update(
        "cart",
        {
          "quantity": quantity,
          "discount": discount,
        },
        where: "id = ?",
        whereArgs: [id],
      );

      if (count == 0) {
        throw Exception("Failed to update product in cart");
      }
    } catch (error) {
      throw Exception("Error updating product in cart: $error");
    }
  }

  static Future<void> deleteByID(int id) async {
    final db = await DatabaseUtils().database;
    try {
      var count = await db.delete("cart", where: "id = ?", whereArgs: [id]);
      if (count == 0) {
        throw Exception("Failed to delete product from cart");
      }
    } catch (error) {
      throw Exception("Error deleting product from cart: $error");
    }
  }

  static Future<List<SQLCartModel>> fetchByCartCodeID(int id) async {
    var db = await DatabaseUtils().database;
    var result = await db.query(
      "cart",
      where: "cartCodeID = ?",
      whereArgs: [id],
    );
    return result.map((e) => SQLCartModel.fromMap(e)).toList();
  }
}

class SQLCartModelPrint extends SQLCartModel {
  String reference;
  String description;
  String brand;
  String type;

  SQLCartModelPrint({
    int? id,
    required String itemID,
    required int quantity,
    required double price,
    required double discount,
    required int cartCodeID,
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
  }) : super(
          id: id,
          itemID: itemID,
          quantity: quantity,
          price: price,
          discount: discount,
          cartCodeID: cartCodeID,
        );

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
    });
    return map;
  }

  factory SQLCartModelPrint.fromMap(Map<String, dynamic> map) {
    return SQLCartModelPrint(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      cartCodeID: map['cartCodeID'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
    );
  }

  static Future<List<SQLCartModelPrint>> fetchByCodeID(int id) async {
    final db = await DatabaseUtils().database;
    var result = await db.rawQuery(
      "SELECT cart.id, cart.itemID, cart.quantity, cart.price, cart.discount, cart.cartCodeID, product.reference, product.description, product.brand, product.type "
      "FROM cart "
      "JOIN product ON cart.itemID = product.mongoID "
      "WHERE cart.cartCodeID = ?",
      [id],
    );

    return result.map((e) => SQLCartModelPrint.fromMap(e)).toList();
  }
}
