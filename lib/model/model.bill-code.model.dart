import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_payment.model.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-payment.model.dart';
import 'package:cstyle_cashier_3/model/model.bill.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

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

  static Future<BillCodeModel?> fetchLastBillCode() async {
    try {
      var billCode = await SQLBillCodeModel.fetchLastBillCode();
      if (billCode == null) {
        return null;
      } else {
        return BillCodeModel(
          id: billCode.id,
          date: billCode.date,
          name: billCode.name,
          memberID: billCode.memberID,
          mongoID: billCode.mongoID,
          createdBy: billCode.createdBy,
        );
      }
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

  Future<int?> create() async {
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

      totalPrice +=
          ((bill.price * (100 - bill.discount) * bill.quantity / 100) ~/ 1000) *
              1000;
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

    SQLBillCodeModelCreate(
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
    ).create().then((billCodeID) {
      // promise all
      Future.wait<void>([
        SQLBillModelCreate.create(modifiedBills.map((e) {
          return SQLBillModelCreate(
            itemID: e.itemID,
            quantity: e.quantity,
            price: e.price,
            discount: e.discount,
            billCodeID: billCodeID,
          );
        }).toList()),
        SQLBillPaymentModelCreate.create(payments.map((e) {
          return SQLBillPaymentModelCreate(
            billCodeID: billCodeID,
            paymentMethod: e.paymentMethod,
            amount: e.amount,
          );
        }).toList()),
      ]).then((_) {
        modifiedBills.forEach((x) async {
          await SQLProductModel.updateStock(x.itemID, x.quantity);
        });

        return billCodeID;
      }).catchError((error) {
        // Delete the bill code if there's an error
        SQLBillCodeModel.delete(billCodeID).then((_) {
          throw Exception(error);
        }).catchError((error) {
          throw Exception(error);
        });
      });
    }).catchError((error) {
      throw Exception(error);
    });
    return null;
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

  static updateSync(String name, String id) {
    return SQLBillCodeModel.updateUnsyncedBill(id, name);
  }
}

class BillCodeModelFetch {
  DateTime date;
  DateTime createdAt;
  String name;
  String id;
  BillCodeCreatedByModel createdBy;
  BillCodeMembershipModel? memberID;
  List<BillCodeItemModelFetch>? items;
  List<BillCodePaymentModelFetch>? payment;

  BillCodeModelFetch({
    required this.date,
    required this.createdAt,
    required this.name,
    required this.id,
    required this.createdBy,
    required this.memberID,
    this.items,
    this.payment,
  });

  factory BillCodeModelFetch.fromMap(Map<String, dynamic> map) {
    return BillCodeModelFetch(
      date: DateTime.parse(map['date']),
      name: map['name'],
      id: map['_id'],
      createdBy: BillCodeCreatedByModel.fromMap(map['createdBy']),
      createdAt: DateTime.parse(map['createdAt']),
      memberID: map['memberID'] == null
          ? null
          : BillCodeMembershipModel(
              name: map['memberID']['name'],
              code: map['memberID']['code'],
            ),
      items: map['items'] == null
          ? null
          : (map['items'] as List).map((x) {
              return BillCodeItemModelFetch.fromMap(x);
            }).toList(),
      payment: map['payment'] == null
          ? null
          : (map['payment'] as List).map((x) {
              return BillCodePaymentModelFetch.fromMap(x);
            }).toList(),
    );
  }

  static Future<Map<String, dynamic>> fetchHistory(int page) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      var bills = await ApiUtils().getRequest(
          "cashier/bills",
          {
            "page": page,
          },
          Options(headers: {
            "store": store!.code,
          }));

      return {
        "data": (bills['data'] as List).map((x) {
          return BillCodeModelFetch(
            date: DateTime.parse(x['date']),
            name: x['name'],
            id: x['_id'],
            createdBy: BillCodeCreatedByModel.fromMap(x['createdBy']),
            createdAt: DateTime.parse(x['createdAt']),
            memberID: x['memberID'] == null
                ? null
                : BillCodeMembershipModel(
                    name: x['memberID']['name'],
                    code: x['memberID']['code'],
                  ),
          );
        }).toList(),
        "count": bills['count'],
      };
    } catch (error) {
      throw Exception(error);
    }
  }

  static Future<BillCodeModelFetch> fetchByID(String id) async {
    try {
      var store = await StoreModel.getCurrentProfile();
      var bill = await ApiUtils().getRequest(
          "cashier/bills/$id",
          {},
          Options(headers: {
            "store": store!.code,
          }));

      return BillCodeModelFetch.fromMap(bill);
    } catch (error) {
      throw Exception(error);
    }
  }
}

class BillCodeMembershipModel {
  String name;
  String code;

  BillCodeMembershipModel({
    required this.name,
    required this.code,
  });
}

class BillCodeCreatedByModel {
  String name;

  BillCodeCreatedByModel({
    required this.name,
  });

  factory BillCodeCreatedByModel.fromMap(Map<String, dynamic> map) {
    return BillCodeCreatedByModel(
      name: map['name'],
    );
  }

  // To map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

class BillCodeItemModelFetch {
  BillCodItemModelItemIDFetch itemID;
  double price;
  double discount;
  int quantity;

  BillCodeItemModelFetch({
    required this.itemID,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  factory BillCodeItemModelFetch.fromMap(Map<String, dynamic> map) {
    return BillCodeItemModelFetch(
      itemID: BillCodItemModelItemIDFetch.fromMap(map['itemID']),
      // price was in integer, how to make it double?
      price: double.parse(map['price'].toString()),
      discount: double.parse(map['discount'].toString()),
      quantity: map['quantity'],
    );
  }
}

class BillCodItemModelItemIDFetch {
  String reference;
  String description;

  BillCodItemModelItemIDFetch({
    required this.reference,
    required this.description,
  });

  factory BillCodItemModelItemIDFetch.fromMap(Map<String, dynamic> map) {
    return BillCodItemModelItemIDFetch(
      reference: map['reference'],
      description: map['description'],
    );
  }
}

class BillCodePaymentModelFetch {
  String type;
  num amount;

  BillCodePaymentModelFetch({
    required this.type,
    required this.amount,
  });

  factory BillCodePaymentModelFetch.fromMap(Map<String, dynamic> map) {
    return BillCodePaymentModelFetch(
      type: map['type'],
      amount: map['amount'],
    );
  }
}

class BillCodeModelFetchLocal {
  int? id;
  DateTime date;
  String name;
  String? memberID;
  String? mongoID;
  String createdBy;
  DateTime createdAt;

  BillCodeModelFetchLocal({
    this.id,
    required this.date,
    required this.name,
    this.memberID,
    this.mongoID,
    required this.createdBy,
    required this.createdAt,
  });

  static Future<Map<String, dynamic>> fetch(int page) async {
    try {
      var bills = await SQLBillCodeModel.fetch(page);
      var count = await SQLBillCodeModel.count();
      return {
        "data": bills.map((e) {
          return BillCodeModelFetchLocal(
            id: e.id,
            name: e.name,
            date: e.date,
            createdAt: e.createdAt,
            createdBy: e.createdBy,
            memberID: e.memberID,
            mongoID: e.mongoID,
          );
        }).toList(),
        "count": count,
      };
    } catch (error) {
      throw Exception(error);
    }
  }
}
