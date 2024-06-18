import 'package:cstyle_cashier_3/model/db.product.model.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLCartModel {
  int? id;
  int itemID;
  int quantity;
  num price;
  num discount;
  int cartCodeID;
  SQLProductModel? product;

  SQLCartModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.cartCodeID,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'cartCodeID': cartCodeID,
      'product': product?.toMap(),
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
      product: SQLProductModel.fromMap(map['product']),
    );
  }

  static Future<List<SQLCartModel>> fetchByCodeID(int id) async {
    var db = await DatabaseUtils().database;
    var result = await db.rawQuery(
        "SELECT cart.id, cart.itemID, cart.quantity, cart.price, cart.discount, cart.cartCodeID, product.reference, product.description, product.brand, product.type, product.barcode FROM cart JOIN product ON cart.itemID = product.id WHERE cartCodeID = $id");

    return result.map((e) => SQLCartModel.fromMap(e)).toList();
  }
}
