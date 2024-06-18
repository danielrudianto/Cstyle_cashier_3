import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:flutter/material.dart';

class DashboardGridList extends StatelessWidget {
  final List<ProductModel> products;
  final Function onAddProduct;
  const DashboardGridList({
    super.key,
    required this.products,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            onAddProduct(products[index]);
          },
          title: Text(products[index].type),
        );
      },
    );
  }
}
