import 'package:cstyle_cashier_3/model/db.cart_code.model.dart';
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

  static Future<void> addProduct(ProductModel product, int cartID) async {
    // Check if ID is null, then we have to create a new cart
    var db = await DatabaseUtils().database;
    db.insert("cart", {
      "itemID": product.id,
      "quantity": 1,
      "price": product.price,
      "discount": 0,
      "cart_code_id": cartID,
    });
  }

  static Future<void> addExistingProduct(
      int productID, int cartID, int? finalQuantity) async {
    var db = await DatabaseUtils().database;
    var existingProduct = await db.query("cart",
        where: "itemID = ? AND cart_code_id = ?",
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

  static Future<void> deleteByID(int id) async {
    var db = await DatabaseUtils().database;
    try {
      await db.execute('''BEGIN;
      DELETE FROM cart WHERE cart_code_id = $id;
      DELETE FROM cart_code WHERE id = $id;
      COMMIT;''');
    } catch (error) {
      throw Exception(error);
    }
  }

  void removeProduct(ProductModel product) {}

  void clearCart() {
    products.clear();
  }
}
