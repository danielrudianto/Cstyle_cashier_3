import 'package:cstyle_cashier_3/db/db.bill.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.bill_payment.model.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-payment.model.dart';
import 'package:cstyle_cashier_3/model/model.bill.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/database.utils.dart';
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

  /// Menyimpan satu penjualan: nota, baris barang, pembayaran, dan pengurangan
  /// stok.
  ///
  /// ================== KENAPA INI SATU TRANSAKSI ==================
  ///
  /// Bentuk sebelumnya menulis keempatnya secara terpisah, TIDAK menunggu
  /// hasilnya, lalu diakhiri `return null` yang berjalan sebelum satu pun
  /// tulisan selesai. Akibatnya pemanggil selalu menerima null seketika dan
  /// melanjutkan seolah semuanya beres — mencetak struk, menghapus keranjang,
  /// menutup layar — padahal penulisannya masih berjalan dan bisa gagal.
  ///
  /// Kegagalannya pun tidak ke mana-mana: ia dilempar dari dalam .catchError
  /// yang sudah lepas dari pemanggil, jadi tidak pernah sampai ke layar. Dan
  /// karena baris bill_code-nya tidak jadi ada, penjualan itu juga tidak
  /// muncul sebagai "belum tersinkron" — ia hilang tanpa jejak.
  ///
  /// Sekarang keempatnya berada dalam satu transaksi SQLite: berhasil
  /// seluruhnya atau tidak sama sekali. Pembatalan manual yang dulu ada
  /// dibuang — itu memang pekerjaan transaksi, dan pembatalan itu sendiri bisa
  /// gagal tanpa menyentuh stok yang telanjur berkurang.
  ///
  /// Nilai baliknya kini id nota yang sebenarnya. Kalau gagal, ia MELEMPAR,
  /// dan pemanggil wajib menangkapnya sebelum mencetak struk.
  Future<int> create() async {
    /// Baris yang sama persis — barang, harga, DAN diskon — digabung supaya
    /// stoknya dikurangi sekali dan strukmya tidak memuat baris kembar.
    /// Harga berbeda tetap menjadi dua baris, karena memang harganya berbeda.
    final List<BillModelCreate> modifiedBills = [];
    double totalPrice = 0.0;

    for (final bill in bills) {
      final kembar = modifiedBills.where((x) =>
          x.itemID == bill.itemID &&
          x.price == bill.price &&
          x.discount == bill.discount);

      if (kembar.isEmpty) {
        modifiedBills.add(bill);
      } else {
        kembar.first.quantity += bill.quantity;
      }

      /// Dibulatkan ke bawah per baris ke kelipatan seribu, sama seperti yang
      /// dilakukan server saat menyusun laporan. Kalau salah satunya diubah,
      /// keduanya harus ikut.
      totalPrice +=
          ((bill.price * (100 - bill.discount) * bill.quantity / 100) ~/ 1000) *
              1000;
    }

    /// Kelebihan bayar dipotong dari pembayaran tunai, karena tunai yang
    /// menghasilkan kembalian.
    final double totalPayments =
        payments.fold(0.0, (sum, e) => sum + e.amount);

    if (totalPayments > totalPrice) {
      final index =
          payments.indexWhere((e) => e.paymentMethod == "Cash");

      /// indexWhere mengembalikan -1 bila tidak ada pembayaran tunai, dan
      /// payments[-1] melempar RangeError — tepat saat pelanggan sedang
      /// menunggu. Kelebihan bayar non-tunai memang tidak lazim, tetapi voucher
      /// yang nilainya melebihi belanja sudah cukup memicunya.
      ///
      /// Bila tidak ada tunai, kelebihannya dibiarkan tercatat apa adanya.
      /// Memutuskan apa yang seharusnya terjadi — ditolak, dibulatkan, atau
      /// dicatat sebagai kembalian non-tunai — adalah keputusan yang perlu
      /// disepakati lebih dulu, bukan diputuskan di sini.
      if (index != -1) {
        payments[index].amount =
            payments[index].amount - (totalPayments - totalPrice);
      }
    }

    final db = await DatabaseUtils().database;

    return db.transaction<int>((txn) async {
      final billCodeID = await SQLBillCodeModelCreate(
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
      ).createIn(txn);

      await SQLBillModelCreate.createAll(
        txn,
        modifiedBills
            .map((e) => SQLBillModelCreate(
                  itemID: e.itemID,
                  quantity: e.quantity,
                  price: e.price,
                  discount: e.discount,
                  billCodeID: billCodeID,
                ))
            .toList(),
      );

      await SQLBillPaymentModelCreate.createAll(
        txn,
        payments
            .map((e) => SQLBillPaymentModelCreate(
                  billCodeID: billCodeID,
                  paymentMethod: e.paymentMethod,
                  amount: e.amount,
                ))
            .toList(),
      );

      /// Ditunggu satu per satu. Bentuk lamanya memakai forEach dengan callback
      /// async, jadi pengurangan stok tidak ditunggu sama sekali dan berjalan
      /// di luar segala penjagaan.
      for (final item in modifiedBills) {
        await SQLProductModel.updateStockIn(txn, item.itemID, item.quantity);
      }

      return billCodeID;
    });
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
