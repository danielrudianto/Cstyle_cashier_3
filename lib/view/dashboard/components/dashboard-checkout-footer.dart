import 'package:cstyle_cashier_3/components/checkout-card/checkout-card.dart';
import 'package:cstyle_cashier_3/components/dashed-line/dashed-line.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardCheckoutFooter extends StatelessWidget {
  final num value;
  const DashboardCheckoutFooter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, -5),
              ),
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          margin: const EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 25,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat("#,##0.00").format(
                        value,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text(
              //         "Subtotal",
              //         style: Theme.of(context).textTheme.bodyLarge,
              //       ),
              //     ),
              //     Expanded(
              //       child: Text(
              //         NumberFormat("#,##0.##").format(
              //           value / 1.11,
              //         ),
              //         style: Theme.of(context).textTheme.bodyLarge,
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text(
              //         "Tax",
              //         style: Theme.of(context).textTheme.bodyLarge,
              //       ),
              //     ),
              //     Expanded(
              //       child: Text(
              //         NumberFormat("#,##0.##").format(
              //           value - value / 1.11,
              //         ),
              //         style: Theme.of(context).textTheme.bodyLarge,
              //         textAlign: TextAlign.right,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 350,
              height: 25,
              decoration: BoxDecoration(color: Colors.transparent, boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ]),
              child: CustomPaint(
                painter: CheckoutCard(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            SizedBox(
              width: 325,
              height: 1,
              child: CustomPaint(
                painter: DashedLineHelper(),
                size: const Size(300, 1),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.all(
            20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Total",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: Text(
                  NumberFormat("#,##0.00").format(
                    value,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // style to have padding
                  onPressed: () {
                    // Check the stock first
                    Provider.of<CartNotifier>(context, listen: false)
                        .checkStock()
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Insufficient stock, please check the cart!"),
                          ),
                        );
                      } else {
                        router.push("/checkout");
                      }
                    });
                    // router.push("/checkout");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 50,
                    ),
                    // radius
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Checkout"),
                ),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<CartNotifier>(
                    context,
                    listen: false,
                  ).deselectCart();
                },
                icon: Icon(
                  Icons.archive,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<CartNotifier>(
                    context,
                    listen: false,
                  ).deleteCurrentCart();
                },
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
