import 'package:cstyle_cashier_3/utils/database.utils.dart';

class SQLBillModel {
  int? id;
  String itemID;
  int quantity;
  double price;
  double discount;
  int billCodeId;

  SQLBillModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.billCodeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'bill_code_id': billCodeId,
    };
  }

  factory SQLBillModel.fromMap(Map<String, dynamic> map) {
    return SQLBillModel(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
      billCodeId: map['bill_code_id'],
    );
  }

  static Future<List<SQLBillModel>> fetchByBillCodeIDs(List<int> ids) async {
    var db = await DatabaseUtils().database;

    var result =
        await db.query("bill", where: "bill_code_id IN (${ids.join(",")})");
    return result.map((e) => SQLBillModel.fromMap(e)).toList();
  }
}
