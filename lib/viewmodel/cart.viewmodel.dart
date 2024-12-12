import 'dart:math';

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

  Future<int?> createNewCart() async {
    var random = Random();
    var name =
        "B-CS-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, "0")}-";
    for (var i = 0; i < 8; i++) {
      name += random.nextInt(10).toString();
    }

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
      LoggerUtils().log(error.toString(), LogType.error);
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
                element.quantity *
                    (element.price * (100 - element.discount) / 100000)
                        .floor() *
                    1000);

    notifyListeners();
  }

  Future<int?> checkout(String? memberID, List<Map<String, dynamic>> payments,
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

    try {
      var billCodeID = await BillCodeModelCreate(
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

      return billCodeID;
    } catch (error) {
      throw Exception(error);
    }
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
