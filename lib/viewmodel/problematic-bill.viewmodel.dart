import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:flutter/material.dart';

class ProblematicBillViewModel extends ChangeNotifier {
  List<BillCodeModel> _problematicBills = [];
  List<BillCodeModel> get problematicBills => _problematicBills;

  Future<void> fetchProblematicBills() async {
    _problematicBills = await BillCodeModel.fetchProblematicBills();
    notifyListeners();
  }

  Future<void> addProblematicBills(BillCodeModel bills) async {
    _problematicBills.add(bills);
    notifyListeners();
  }

  Future<void> removeProblematicBill(BillCodeModel bill) async {
    _problematicBills.removeWhere((e) => e.mongoID == bill.mongoID);
  }
}
