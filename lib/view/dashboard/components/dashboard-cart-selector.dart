import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartSelector extends StatelessWidget {
  const CartSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (_, value, __) {
        return value.selectedCart == null
            ? Container()
            : ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(value.selectedCart!.products[index].reference),
                    subtitle:
                        Text(value.selectedCart!.products[index].description),
                    trailing: Text(
                      value.selectedCart!.products[index].quantity.toString(),
                    ),
                  );
                },
                itemCount: value.selectedCart == null
                    ? 0
                    : value.selectedCart!.products.length,
              );
      },
    );
  }
}
