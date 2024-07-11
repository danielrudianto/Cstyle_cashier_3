import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/select-employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color.fromARGB(255, 151, 158, 249),
            height: 300,
            child: Center(
              child: SizedBox(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Inventory Management",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 32, 92),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Manage your stock transfers here",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 32, 92),
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // Create button
                    GestureDetector(
                      onTap: () {
                        router.push("/inventory/stock-transfer/create");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color.fromARGB(255, 0, 32, 92),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 10,
                          ),
                          child: Text(
                            "Create stock transfer",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
