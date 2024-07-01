class BillModel {
  int? id;
  String itemID;
  int quantity;
  double price;
  double discount;

  BillModel({
    this.id,
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
  });
}

class BillModelCreate {
  String itemID;
  int quantity;
  double price;
  double discount;

  BillModelCreate({
    required this.itemID,
    required this.quantity,
    required this.price,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemID': itemID,
      'quantity': quantity,
      'price': price,
      'discount': discount,
    };
  }

  factory BillModelCreate.fromMap(Map<String, dynamic> map) {
    return BillModelCreate(
      itemID: map['itemID'],
      quantity: map['quantity'],
      price: map['price'],
      discount: map['discount'],
    );
  }
}

class BillModelPrint {
  String reference;
  String description;
  String brand;
  String type;
  double price;
  double discount;
  int quantity;

  BillModelPrint({
    required this.reference,
    required this.description,
    required this.brand,
    required this.type,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'description': description,
      'brand': brand,
      'type': type,
      'price': price,
      'discount': discount,
      'quantity': quantity,
    };
  }

  factory BillModelPrint.fromMap(Map<String, dynamic> map) {
    return BillModelPrint(
      reference: map['reference'],
      description: map['description'],
      brand: map['brand'],
      type: map['type'],
      price: map['price'],
      discount: map['discount'],
      quantity: map['quantity'],
    );
  }
}
