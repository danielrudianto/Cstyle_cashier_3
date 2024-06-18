import 'package:cstyle_cashier_3/model/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-payment.model.dart';
import 'package:cstyle_cashier_3/model/model.bill.model.dart';

class BillCodeModel {
  int id;
  DateTime date;
  String name;
  String memberID;
  List<BillModel> bill;
  List<BillPayment> payment;

  BillCodeModel({
    required this.id,
    required this.date,
    required this.name,
    required this.memberID,
    required this.bill,
    required this.payment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'name': name,
      'memberID': memberID,
      'bill': bill,
      'payment': payment,
    };
  }

  factory BillCodeModel.fromMap(Map<String, dynamic> map) {
    return BillCodeModel(
      id: map['id'],
      date: map['date'],
      name: map['name'],
      memberID: map['memberID'],
      bill: map['bill'],
      payment: map['payment'],
    );
  }

  static Future<List<BillCodeModel>> fetchUnsyncedBills() async {
    try {
      var bills = await SQLBillCodeModel.fetchUnsyncedBills();
      return bills.map((x) {
        return BillCodeModel(
            id: x.id!,
            date: DateTime.parse(x.date),
            name: x.name,
            memberID: x.memberID ?? "",
            bill: [],
            payment: []);
      }).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}
