class CartItemModel {
  int? id;
  String itemID;
  int quantity;
  double discount;
  double price;
  String reference;
  String description;

  CartItemModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.discount,
    required this.price,
    required this.reference,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemID': itemID,
      'quantity': quantity,
      'discount': discount,
      'price': price,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      itemID: map['itemID'],
      quantity: map['quantity'],
      discount: map['discount'],
      price: map['price'],
      reference: map['reference'],
      description: map['description'],
    );
  }
}
