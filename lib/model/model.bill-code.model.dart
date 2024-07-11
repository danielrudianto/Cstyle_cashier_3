import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_payment.model.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-payment.model.dart';
import 'package:cstyle_cashier_3/model/model.bill.model.dart';

class BillCodeModel {
  int? id;
  DateTime date;
  String name;
  String? memberID;
  String? mongoID;
  String createdBy;

  BillCodeModel({
    this.id,
    required this.date,
    required this.name,
    this.memberID,
    this.mongoID,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'name': name,
      'memberID': memberID,
      'mongoID': mongoID,
      'createdBy': createdBy,
    };
  }

  factory BillCodeModel.fromMap(Map<String, dynamic> map) {
    return BillCodeModel(
      id: map['id'],
      date: map['date'],
      name: map['name'],
      memberID: map['memberID'],
      mongoID: map['mongoID'],
      createdBy: map['createdBy'],
    );
  }

  static Future<List<BillCodeModel>> fetchUnsyncedBills() async {
    try {
      var bills = await SQLBillCodeModel.fetchUnsyncedBills();
      return bills.map((x) {
        return BillCodeModel(
          id: x.id!,
          date: x.date,
          name: x.name,
          memberID: x.memberID,
          createdBy: x.createdBy,
        );
      }).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<BillCodeModel>> fetchProblematicBills() async {
    try {
      var bills = await SQLBillCodeModel.fetchProblematicBills();
      return bills.map((x) {
        return BillCodeModel(
          id: x.id!,
          date: x.date,
          name: x.name,
          memberID: x.memberID,
          createdBy: x.createdBy,
        );
      }).toList();
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<BillCodeModel?> fetchByName(String name) async {
    try {
      var billCode = await SQLBillCodeModel.fetchByName(name);
      return BillCodeModel(
        id: billCode.id,
        date: billCode.date,
        name: billCode.name,
        memberID: billCode.memberID,
        mongoID: billCode.mongoID,
        createdBy: billCode.createdBy,
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<List<BillCodeModel>> fetchHistory(int page) async {
    try {
      var bills = await SQLBillCodeModel.fetch(page);
      return bills.map((x) {
        return BillCodeModel(
          id: x.id!,
          date: x.date,
          name: x.name,
          memberID: x.memberID,
          createdBy: x.createdBy,
          mongoID: x.mongoID,
        );
      }).toList();
    } catch (error) {
      throw Exception(error);
    }
  }
}

class BillCodeModelCreate extends BillCodeModel {
  List<BillPaymentModelCreate> payments;
  List<BillModelCreate> bills;

  BillCodeModelCreate({
    required super.date,
    required super.name,
    required super.memberID,
    required super.createdBy,
    required this.payments,
    required this.bills,
  });

  Future<void> create() async {
    List<BillModelCreate> modifiedBills = [];
    double totalPrice = 0.0;
    // First we have to combine if bill has the same itemID, price, and discount
    for (var bill in bills) {
      var found = false;
      for (var modifiedBill in modifiedBills) {
        if (modifiedBill.itemID == bill.itemID &&
            modifiedBill.price == bill.price &&
            modifiedBill.discount == bill.discount) {
          modifiedBill.quantity += bill.quantity;
          found = true;
          break;
        }
      }
      if (!found) {
        modifiedBills.add(bill);
      }

      totalPrice += (bill.price * (100 - bill.discount) / 100) * bill.quantity;
    }

    // Next we're going to deduct the cash payments based on the changes
    double totalPayments = payments.fold(
      0.0,
      (sum, element) => sum + element.amount,
    );

    if (totalPayments > totalPrice) {
      var index =
          payments.indexWhere((element) => element.paymentMethod == "Cash");

      payments[index].amount =
          payments[index].amount - (totalPayments - totalPrice);
    }

    try {
      var billCodeID = await SQLBillCodeModelCreate(
        name: name,
        date: DateTime.parse(date.toIso8601String().substring(0, 10)),
        memberID: memberID,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        mongoID: null,
        isSynced: 0,
        isDeleted: 0,
        deletedBy: null,
        deletedAt: null,
      ).create();

      // After obtaining valid billCodeID, then create the bills and payments
      await SQLBillModelCreate.create(modifiedBills.map((e) {
        return SQLBillModelCreate(
          itemID: e.itemID,
          quantity: e.quantity,
          price: e.price,
          discount: e.discount,
          billCodeID: billCodeID,
        );
      }).toList());

      await SQLBillPaymentModelCreate.create(payments.map((e) {
        return SQLBillPaymentModelCreate(
          billCodeID: billCodeID,
          paymentMethod: e.paymentMethod,
          amount: e.amount,
        );
      }).toList());

      modifiedBills.forEach((x) async {
        await SQLProductModel.updateStock(x.itemID, x.quantity);
      });
    } catch (error) {
      throw Exception(error);
    }
  }
}

class BillCodeModelPrint extends BillCodeModel {
  String createdByName;
  List<BillModelPrint> bills;
  List<BillPaymentModelPrint> payments;

  BillCodeModelPrint({
    required super.date,
    required super.name,
    required super.memberID,
    required super.createdBy,
    required this.createdByName,
    required this.bills,
    required this.payments,
  });

  static Future<BillCodeModelPrint> fetchByName(String name) async {
    try {
      var billCode = await SQLBillCodeModelPrint.fetchByName(name);
      return BillCodeModelPrint(
        date: billCode.date,
        name: billCode.name,
        memberID: billCode.memberID,
        createdBy: billCode.createdBy,
        createdByName: billCode.createdByName,
        bills: billCode.bills.map((e) {
          return BillModelPrint(
            reference: e.reference,
            description: e.description,
            brand: e.brand,
            type: e.type,
            price: e.price,
            discount: e.discount,
            quantity: e.quantity,
          );
        }).toList(),
        payments: billCode.payments.map((e) {
          return BillPaymentModelPrint(
              amount: e.amount, paymentMethod: e.paymentMethod);
        }).toList(),
      );
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<BillCodeModelPrint> fetchByID(int id) async {
    try {
      var billCode = await SQLBillCodeModelPrint.fetchByID(id);
      return BillCodeModelPrint(
        date: billCode.date,
        name: billCode.name,
        memberID: billCode.memberID,
        createdBy: billCode.createdBy,
        createdByName: billCode.createdByName,
        bills: billCode.bills.map((e) {
          return BillModelPrint(
            reference: e.reference,
            description: e.description,
            brand: e.brand,
            type: e.type,
            price: e.price,
            discount: e.discount,
            quantity: e.quantity,
          );
        }).toList(),
        payments: billCode.payments.map((e) {
          return BillPaymentModelPrint(
              amount: e.amount, paymentMethod: e.paymentMethod);
        }).toList(),
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}

class BillCodeModelSync {
  String name;
  String id;

  BillCodeModelSync({
    required this.name,
    required this.id,
  });

  factory BillCodeModelSync.fromMap(Map<String, dynamic> map) {
    return BillCodeModelSync(
      name: map['name'],
      id: map['_id'],
    );
  }

  // To map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      '_id': id,
    };
  }

  updateSync() async {
    try {
      await SQLBillCodeModel.updateUnsyncedBill(id, name);
    } catch (error) {
      throw Exception(error);
    }
  }
}
