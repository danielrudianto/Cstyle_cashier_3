import 'package:cstyle_cashier_3/components/checkout-card/checkout-card.dart';
import 'package:cstyle_cashier_3/components/dashed-line/dashed-line.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                      "Subtotal",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat("#,##0.##").format(
                        value / 1.11,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tax",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat("#,##0.##").format(
                        value - value / 1.11,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
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
            Container(
              width: 325,
              height: 1,
              child: CustomPaint(
                painter: DashedLineHelper(),
                size: Size(300, 1),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  NumberFormat("#,##0.00").format(
                    value,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                  ),
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
          child: ElevatedButton(
            // style to have padding

            onPressed: () {
              router.push("/checkout");
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
        )
      ],
    );
  }
}
