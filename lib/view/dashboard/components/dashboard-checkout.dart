import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-checkout-footer.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardCheckout extends StatefulWidget {
  const DashboardCheckout({super.key});

  @override
  State<DashboardCheckout> createState() => _DashboardCheckoutState();
}

class _DashboardCheckoutState extends State<DashboardCheckout> {
  _updatePriceDiscount(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 400,
                padding: const EdgeInsets.all(0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    // border radius only top
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const Column(
                    children: <Widget>[
                      //form field
                      Flexible(
                        child: TextField(
                          // label Price
                          // decoration outlineInputBorder
                          decoration: InputDecoration(
                            labelText: "Price",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextField(
                          // label Price
                          // decoration outlineInputBorder
                          decoration: InputDecoration(
                            labelText: "Price",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(builder: (_, value, __) {
      return Container(
        padding: const EdgeInsets.all(15),
        width: 400,
        // left border 1px solid grey
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: value.selectedCart == null ||
                value.selectedCart!.products.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 50,
                  ),
                  Text(
                    "Cart is empty",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.selectedCart!.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    DateFormat("dd/MM/yyyy").format(value.selectedCart!.date),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                            onTap: () {
                              _updatePriceDiscount(index);
                            },
                            title: Text(
                              value.selectedCart!.products[index].reference,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.selectedCart!.products[index]
                                      .description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        value.selectedCart!.products[index]
                                                    .discount ==
                                                0
                                            ? NumberFormat.decimalPattern()
                                                .format(value.selectedCart!
                                                    .products[index].price)
                                            : NumberFormat.decimalPattern()
                                                .format(
                                                value.selectedCart!
                                                        .products[index].price -
                                                    (value
                                                            .selectedCart!
                                                            .products[index]
                                                            .price *
                                                        value
                                                            .selectedCart!
                                                            .products[index]
                                                            .discount /
                                                        100),
                                              ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      "x${value.selectedCart!.products[index].quantity}",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ));
                      },
                      itemCount: value.selectedCart!.products.length,
                    ),
                  ),
                  DashboardCheckoutFooter(value: value.totalPrice),
                ],
              ),
      );
    });
  }
}
