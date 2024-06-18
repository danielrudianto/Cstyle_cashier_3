class SQLBillPaymentModel {
  int? id;
  int billCodeId;
  String paymentMethodId;
  double amount;

  SQLBillPaymentModel({
    this.id,
    required this.billCodeId,
    required this.paymentMethodId,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_code_id': billCodeId,
      'payment_method_id': paymentMethodId,
      'amount': amount,
    };
  }

  factory SQLBillPaymentModel.fromMap(Map<String, dynamic> map) {
    return SQLBillPaymentModel(
      id: map['id'],
      billCodeId: map['bill_code_id'],
      paymentMethodId: map['payment_method_id'],
      amount: map['amount'],
    );
  }
}
