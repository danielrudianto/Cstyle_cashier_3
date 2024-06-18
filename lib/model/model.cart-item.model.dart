import 'package:cstyle_cashier_3/model/model.product.model.dart';

class CartItemModel extends ProductModel {
  int quantity;
  double discount;

  CartItemModel({
    required this.quantity,
    required this.discount,
    required super.id,
    required super.reference,
    required super.description,
    required super.brand,
    required super.type,
    super.barcode,
    required super.price,
    super.images,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'barcode': barcode,
      'price': price,
      'quantity': quantity,
      'discount': discount,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
      barcode: map['barcode'],
      price: map['price'],
      quantity: map['quantity'],
      discount: map['discount'],
    );
  }
}
