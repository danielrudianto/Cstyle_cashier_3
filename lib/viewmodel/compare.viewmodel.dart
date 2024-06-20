import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:flutter/material.dart';

class CompareNotifier extends ChangeNotifier {
  List<ProductModel> items = [];

  final List<ProductModel> _selectedComparisson = [];
  List<ProductModel> get selectedComparisson => _selectedComparisson;

  void selectProduct(ProductModel product) {
    if (selectedComparisson.length >= 3) {
      _selectedComparisson.removeAt(0);
    }

    _selectedComparisson.add(product);
    notifyListeners();
  }

  void deselectProduct(int id) {
    _selectedComparisson.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void clear() {
    _selectedComparisson.clear();
    notifyListeners();
  }

  hasProduct(int id) {
    return _selectedComparisson.any((element) => element.id == id);
  }
}
