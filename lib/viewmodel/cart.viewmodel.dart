import 'dart:math';

import 'package:cstyle_cashier_3/model/model.cart-item.model.dart';
import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/foundation.dart';

class CartNotifier extends ChangeNotifier {
  CartModel? _selectedCart;
  CartModel? get selectedCart => _selectedCart;

  int cartCount = 0;

  void selectCart(CartModel cart) {
    _selectedCart = cart;
    notifyListeners();
  }

  void deselectCart() {
    _selectedCart = null;
    notifyListeners();
  }

  Future<int?> createNewCart() async {
    var random = Random();
    var name =
        "B-CS-${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, "0")}";
    for (var i = 0; i < 8; i++) {
      name += random.nextInt(10).toString();
    }

    try {
      var cart = await CartModel(
              name: name, products: [], totalPrice: 0.0, date: DateTime.now())
          .create();
      selectCart(cart);
      return cart.id;
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
      return null;
    }
  }

  Future<void> createNewProduct(CartItemModel product) async {
    try {
      _selectedCart!.products.add(product);
      await CartModel.addProduct(product, _selectedCart!.id!);
      notifyListeners();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> createExistingProduct(int productID) async {
    var products = _selectedCart!.products;
    var index = products.indexWhere((element) => element.id == productID);
    if (index == -1) {
      throw Exception("Product not found");
    } else {
      _selectedCart!.products[index].quantity++;
      await CartModel.addExistingProduct(productID, _selectedCart!.id!, null);
      notifyListeners();
    }
  }

  Future<void> deleteCartByID(int id) async {
    try {
      CartModel.deleteByID(id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCurrentCart() async {
    try {
      await CartModel.deleteByID(_selectedCart!.id!);
      cartCount = cartCount - 1;
      deselectCart();
    } catch (error) {
      throw Exception(error);
    }
  }

  int checkExistingProduct(int itemID) {
    return _selectedCart!.products
        .where((element) => element.id == itemID)
        .length;
  }
}
