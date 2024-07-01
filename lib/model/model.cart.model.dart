import 'dart:convert';

import 'package:cstyle_cashier_3/db/db.cart.model.dart';
import 'package:cstyle_cashier_3/db/db.cart_code.model.dart';
import 'package:cstyle_cashier_3/model/model.cart-item.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class CartModel {
  final int? id;
  final DateTime date;
  final String name;
  final String? memberID;
  final List<CartItemModel> products;
  final double totalPrice;

  CartModel({
    required this.name,
    required this.date,
    required this.products,
    required this.totalPrice,
    this.id,
    this.memberID,
  });

  Future<CartModel> create() async {
    var date = DateTime.now();
    var result = await SQLCartCodeModel(
            name: name, date: date.toString(), memberID: null)
        .create();

    if (result == null) {
      throw Exception("Failed to create new cart");
    } else {
      return CartModel(
          id: result.id,
          name: result.name,
          date: DateTime.parse(result.date),
          products: [],
          totalPrice: 0);
    }
  }

  static Future<int> fetchCartsCount() async {
    var carts = await SQLCartCodeModel.fetchCarts();
    return carts.length;
  }

  static Future<List<CartModel>> fetchCarts() async {
    var carts = await SQLCartCodeModel.fetchCarts();
    return carts.map((e) {
      return CartModel(
        id: e.id,
        name: e.name,
        date: DateTime.parse(e.date),
        products: [],
        totalPrice: 0,
      );
    }).toList();
  }

  static Future<CartItemModel> addProduct(
      ProductModel product, int cartID) async {
    try {
      var cartItemID = await SQLCartModel.addProduct(product, cartID);
      return CartItemModel(
        quantity: 1,
        discount: 0,
        id: cartItemID,
        itemID: product.id,
        reference: product.reference,
        description: product.description,
        price: product.price,
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> addExistingProduct(
      String productID, int cartID, int? finalQuantity) async {
    final db = await DatabaseUtils().database;
    var existingProduct = await db.query("cart",
        where: "itemID = ? AND cartCodeID = ?",
        whereArgs: [productID, cartID],
        limit: 1,
        offset: 0);

    if (existingProduct.isNotEmpty) {
      // Update the first entry
      var quantity = existingProduct[0]["quantity"] as int;
      var id = existingProduct[0]["id"] as int;

      db.update(
        "cart",
        {
          "quantity": finalQuantity ?? quantity + 1,
        },
        where: "id = ?",
        whereArgs: [id],
      );
    } else {
      throw Exception("Failed to add existing product");
    }
  }

  static Future<void> deleteItemByID(int id) async {
    await SQLCartModel.deleteByID(id);
  }

  static Future<void> deleteByID(int id) async {
    final db = await DatabaseUtils().database;
    try {
      SQLCartCodeModel.delete(id);
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<void> updateQuantityDiscount(
      int id, int quantity, double discount) async {
    await SQLCartModel.updateQuantityDiscount(id, quantity, discount);
  }

  void removeProduct(ProductModel product) {}

  void clearCart() {
    products.clear();
  }

  static Future<CartModel> fetchByID(int id) async {
    var cartCode = await SQLCartCodeModel.fetchByID(id);
    var cartItems = await SQLCartModelPrint.fetchByCodeID(id);

    return CartModel(
      id: id,
      date: DateTime.parse(cartCode.date),
      name: cartCode.name,
      products: cartItems.map((e) {
        return CartItemModel(
          id: e.id,
          itemID: e.itemID,
          quantity: e.quantity,
          discount: e.discount,
          price: e.price,
          reference: e.reference,
          description: e.description,
        );
      }).toList(),
      totalPrice: cartItems.fold(
          0,
          (previousValue, element) =>
              previousValue +
              (element.price * (100 - element.discount) / 100) *
                  element.quantity),
    );
  }
}
