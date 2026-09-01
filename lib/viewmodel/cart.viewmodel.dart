import 'dart:math';

import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.cart_code.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-payment.model.dart';
import 'package:cstyle_cashier_3/model/model.bill.model.dart';
import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/foundation.dart';

class CartNotifier extends ChangeNotifier {
  CartModel? _selectedCart;
  CartModel? get selectedCart => _selectedCart;

  int _cartCount = 0;
  int get cartCount => _cartCount;

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  void setCartCount(int count) {
    _cartCount = count;
    notifyListeners();
  }

  void selectCart(CartModel cart) {
    _selectedCart = cart;
    notifyListeners();

    updatePrice();
  }

  void deselectCart() {
    _selectedCart = null;
    notifyListeners();
  }

  /// Panjang bagian acak pada nomor nota.
  ///
  /// DULU DELAPAN.
  ///
  /// Nomor nota dibuat di sini, di perangkat masing-masing, tanpa bertanya ke
  /// server — memang harus begitu, kasir wajib tetap jalan saat internet mati.
  /// Konsekuensinya keunikannya bersandar sepenuhnya pada peluang.
  ///
  /// Dengan delapan digit ruangnya 10^8. Enam toko menghasilkan sekitar 7.950
  /// nota sebulan, dan pada ruang sebesar itu peluang ada dua yang kembar
  /// mencapai 27% PER BULAN — bukan sekali dalam sekian tahun.
  ///
  /// Dengan dua belas digit ruangnya sepuluh ribu kali lebih besar dan
  /// peluangnya turun ke sekitar 0,003% per bulan.
  ///
  /// Bentuk nomornya sengaja TIDAK berubah — tetap "B-CS-TAHUN-BULAN-" diikuti
  /// deretan angka — supaya struk dan laporan yang sudah ada tidak perlu ikut
  /// menyesuaikan.
  static const int _panjangAcakNomorNota = 12;

  /// Nomor nota baru yang dijamin belum dipakai PERANGKAT INI.
  ///
  /// Kedua tabel diperiksa — cart_code dan bill_code — karena nomornya lahir
  /// di keranjang lalu pindah ke nota saat dibayar; kembar dengan salah satu
  /// saja sudah membuat insert-nya gagal. Keduanya UNIQUE di SQLite, jadi
  /// tanpa pemeriksaan ini nomor kembar tidak lolos — ia MELEDAK: insert-nya
  /// dilempar, tertangkap catch di bawah, dan kasir menekan tombol transaksi
  /// baru tanpa terjadi apa-apa dan tanpa penjelasan.
  ///
  /// Kembar antar perangkat tidak bisa diperiksa dari sini (tidak ada
  /// jaminan jaringan); itu urusan panjang acaknya di atas, dan sisanya
  /// ditangkap pembeda tabrakan di sisi server saat sinkronisasi.
  Future<String> _namaNotaBaru() async {
    /*
      Random.secure(), bukan Random(). Random() biasa disemai dari waktu, dan
      beberapa perangkat yang menyala bersamaan setiap pagi bisa mulai dari
      semaian yang berdekatan — persis keadaan yang paling tidak diinginkan
      pada nomor yang harus unik antar perangkat.
    */
    final random = Random.secure();
    final sekarang = DateTime.now();
    final awalan =
        "B-CS-${sekarang.year}-${sekarang.month.toString().padLeft(2, "0")}-";

    /*
      Tiga kali percobaan, bukan while(true): kalau tiga nomor acak dari ruang
      10^12 kembar semua, yang rusak bukan keberuntungan melainkan basis
      datanya, dan berputar selamanya hanya menyembunyikan itu. Percobaan
      terakhir dipakai apa adanya — paling buruk kembali ke perilaku lama,
      insert yang gagal dengan tercatat.
    */
    var name = "";
    for (var percobaan = 0; percobaan < 3; percobaan++) {
      name = awalan;
      for (var i = 0; i < _panjangAcakNomorNota; i++) {
        name += random.nextInt(10).toString();
      }
      final dipakai = await SQLCartCodeModel.adaDenganNama(name) ||
          await SQLBillCodeModel.adaDenganNama(name);
      if (!dipakai) return name;
    }
    return name;
  }

  Future<int?> createNewCart() async {
    final name = await _namaNotaBaru();

    try {
      var cart = await CartModel(
              name: name, products: [], totalPrice: 0.0, date: DateTime.now())
          .create();
      selectCart(cart);
      updatePrice();
      notifyListeners();
      setCartCount(cartCount + 1);
      return cart.id;
    } catch (error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  Future<void> createNewProduct(ProductModel product) async {
    try {
      var cartItem = await CartModel.addProduct(product, _selectedCart!.id!);
      _selectedCart!.products.add(cartItem);
      updatePrice();
      notifyListeners();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> createExistingProduct(String productID) async {
    var products = _selectedCart!.products;
    var index = products.indexWhere((element) => element.itemID == productID);
    if (index == -1) {
      throw Exception("Product not found");
    } else {
      _selectedCart!.products[index].quantity++;
      await CartModel.addExistingProduct(productID, _selectedCart!.id!, null);
      updatePrice();
      notifyListeners();
    }
  }

  Future<void> deleteCartByID(int id) async {
    try {
      await CartModel.deleteByID(id);
      deselectCart();
      setCartCount(cartCount - 1);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCurrentCart() async {
    try {
      await CartModel.deleteByID(_selectedCart!.id!);
      setCartCount(cartCount - 1);
      notifyListeners();
      deselectCart();
    } catch (error) {
      throw Exception(error);
    }
  }

  int checkExistingProduct(String itemID) {
    return _selectedCart!.products
        .where((element) => element.itemID == itemID)
        .length;
  }

  Future<void> updateQuantityDiscount(
      int index, int quantity, double discount) async {
    var product = selectedCart!.products[index];
    try {
      await CartModel.updateQuantityDiscount(product.id!, quantity, discount);
      selectedCart!.products[index].quantity = quantity;
      selectedCart!.products[index].discount = discount;

      updatePrice();
      notifyListeners();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteProductFromCart(int index) async {
    if (selectedCart == null) {
      throw Exception("Cart not found");
    } else {
      var product = selectedCart!.products[index];
      await CartModel.deleteItemByID(product.id!);
      selectedCart!.products.removeAt(index);

      if (selectedCart!.products.isEmpty) {
        await CartModel.deleteByID(selectedCart!.id!);
        setCartCount(cartCount - 1);
        deselectCart();
        updatePrice();
        notifyListeners();
      } else {
        updatePrice();
      }
    }
  }

  Future<void> clearCart() async {
    try {
      await CartModel.deleteByID(selectedCart!.id!);
      setCartCount(cartCount - 1);
      deselectCart();
      notifyListeners();
    } catch (error) {
      throw Exception(error);
    }
  }

  void updatePrice() {
    _totalPrice = selectedCart == null
        ? 0.0
        : selectedCart!.products.fold(
            0,
            (sum, element) =>
                sum +
                (element.quantity *
                            element.price *
                            (100 - element.discount) /
                            100000)
                        .floor() *
                    1000);

    notifyListeners();
  }

  /// Menyimpan penjualan dan mengembalikan id notanya.
  ///
  /// Dulu bertipe int? karena create() memang selalu mengembalikan null —
  /// penulisannya tidak ditunggu. Sekarang ia mengembalikan id yang sebenarnya,
  /// atau MELEMPAR bila penyimpanannya gagal. Pemanggil wajib menangkapnya
  /// sebelum mencetak struk.
  Future<int> checkout(String? memberID, List<Map<String, dynamic>> payments,
      String createdBy) async {
    if (selectedCart == null) {
      throw Exception("Cart not found");
    }

    if (selectedCart!.products.isEmpty) {
      throw Exception("Cart is empty");
    }

    if (selectedCart!.id == null) {
      throw Exception("Cart not found");
    }

    if (payments.isEmpty) {
      throw Exception("Payment is empty");
    }

    return BillCodeModelCreate(
        date: DateTime.now(),
        name: selectedCart!.name,
        memberID: memberID,
        bills: selectedCart!.products.map((e) {
          return BillModelCreate(
            itemID: e.itemID,
            quantity: e.quantity,
            price: e.price,
            discount: e.discount,
          );
        }).toList(),
        payments: payments.map((e) {
          return BillPaymentModelCreate(
            amount: double.parse(e['amount'].toString()),
            paymentMethod: e['method'],
          );
        }).toList(),
      createdBy: createdBy,
    ).create();
  }

  Future<List<CartModel>> getCarts() async {
    try {
      List<CartModel> carts = await CartModel.fetchCarts();
      return carts;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> checkStock() {
    if (selectedCart == null) {
      return Future.value(false);
    }

    if (selectedCart!.products.isEmpty) {
      return Future.value(false);
    }

    Map<String, int> listCheckStock = {};

    // for each products
    for (var product in selectedCart!.products) {
      if (listCheckStock.containsKey(product.itemID)) {
        listCheckStock[product.itemID] =
            listCheckStock[product.itemID]! + product.quantity;
      } else {
        listCheckStock[product.itemID] = product.quantity;
      }
    }

    // Check stock
    return ProductModel.checkStock(listCheckStock);
  }

  int checkProductQuantity(String id) {
    if (selectedCart == null) {
      return 0;
    }

    if (selectedCart!.products.isEmpty) {
      return 0;
    }

    if (selectedCart!.products
        .where((element) => element.itemID == id)
        .isEmpty) {
      return 0;
    }

// The products has more than 1 item with the same ID
    return selectedCart!.products
        .where((element) => element.itemID == id)
        .fold(0, (sum, element) => sum + element.quantity);
  }
}
