class BillPaymentModel {
  int? id;
  int? billCodeID;
  double amount;
  String paymentMethod;

  BillPaymentModel({
    this.id,
    this.billCodeID,
    required this.amount,
    required this.paymentMethod,
  });
}

class BillPaymentModelCreate {
  int? billCodeID;
  double amount;
  String paymentMethod;

  BillPaymentModelCreate({
    this.billCodeID,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
  }

  factory BillPaymentModelCreate.fromMap(Map<String, dynamic> map) {
    return BillPaymentModelCreate(
      billCodeID: map['billCodeID'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
    );
  }
}

class BillPaymentModelPrint {
  int? billCodeID;
  double amount;
  String paymentMethod;

  BillPaymentModelPrint({
    this.billCodeID,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'billCodeID': billCodeID,
      'amount': amount,
      'paymentMethod': paymentMethod,
    };
  }

  factory BillPaymentModelPrint.fromMap(Map<String, dynamic> map) {
    return BillPaymentModelPrint(
      billCodeID: map['billCodeID'],
      amount: map['amount'],
      paymentMethod: map['paymentMethod'],
    );
  }
}
