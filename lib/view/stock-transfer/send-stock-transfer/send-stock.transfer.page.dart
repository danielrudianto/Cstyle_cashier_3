import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/select-employee.dart';
import 'package:cstyle_cashier_3/view/clip-path/trapezoid.clip-path.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/components/top-stock-transfer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SendStockTransferPage extends StatefulWidget {
  const SendStockTransferPage({super.key});

  @override
  State<SendStockTransferPage> createState() => _SendStockTransferPageState();
}

class _SendStockTransferPageState extends State<SendStockTransferPage> {
  bool isSubmitting = false;

  StockTransferFetchmodel? stockTransferModel;

  _openStockTransferSelector() {
    router.push("/inventory/stock-transfer/unsent").then((value) {
      if (value != null) {
        setState(() {
          stockTransferModel = value as StockTransferFetchmodel;
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  _sendStockTransfer() {
    showDialog<UserModel?>(
        context: context,
        builder: (context) {
          return const Dialog(
            child: SelectEmployee(),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          isSubmitting = true;
        });

        StockTransferModel.send({
          "id": stockTransferModel!.id,
          "items": stockTransferModel!.items.map((e) {
            return {
              "itemID": e.id,
              "quantity": e.quantity,
            };
          }).toList(),
        }).then((value) {
          stockTransferModel!.items.forEach((x) async {
            await SQLProductModel.updateStock(x.id, x.quantity);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Stock transfer successfully sent")));

          setState(() {
            stockTransferModel = null;
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }).whenComplete(() {
          setState(() {
            isSubmitting = false;
          });
        });
      }
    });
  }

  List<Widget> buildStockTransferText() {
    if (stockTransferModel == null) {
      return [const Text("Stock transfer data not selected")];
    } else {
      return [
        Text(
          stockTransferModel!.name,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
            "Requested from: ${stockTransferModel?.requestFrom == null ? 'Office' : stockTransferModel?.requestFrom!['name']}"),
        Text("Requested by: ${stockTransferModel!.createdBy}"),
        const SizedBox(
          height: 15,
        ),
        Divider(
          color: Colors.grey.shade300,
        ),
        const SizedBox(
          height: 15,
        ),
        buildStockTransferTable()!,
      ];
    }
  }

  Widget? buildStockTransferTable() {
    if (stockTransferModel == null) {
      return null;
    } else {
      return Table(
        // border only horizontal
        border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
        children: [
          TableRow(children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: const Text("Reference"),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: const Text("Description"),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              child: const Text("Quantity"),
            ),
          ]),
          for (var item in stockTransferModel!.items)
            TableRow(children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: Text(item.reference),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: Text(item.description),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: Text(
                    "${NumberFormat.decimalPattern().format(item.quantity)} pcs"),
              ),
            ]),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopStockTransfer(),
          SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ClipPath(
                  clipper: TrapezoidClipPath(),
                  child: Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 211, 212, 253),
                    height: 420,
                  ),
                ),
                ClipPath(
                  clipper: InversedTrapezoidClipPath(),
                  child: Container(
                    width: double.infinity,
                    color: const Color.fromARGB(180, 124, 136, 248),
                    height: 420,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getContainerSize(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                router.pop();
                              }),
                          const Text(
                            "Send stock transfer",
                            style: TextStyle(
                              color: Color.fromARGB(255, 4, 30, 73),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Radius 10
                          borderRadius: BorderRadius.circular(10),
                          // elevation
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      Color.fromARGB(255, 201, 170, 252),
                                  child: Text("1"),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Select stock transfer",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              // dark blue background
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 0, 32, 92),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  // padding vertical 15, horizontal 35
                                ),
                              ),
                              onPressed: _openStockTransferSelector,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 35,
                                  vertical: 10,
                                ),
                                child: Text(
                                  "Select stock transfer",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Radius 10
                          borderRadius: BorderRadius.circular(10),
                          // elevation
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Color.fromARGB(0, 0, 0, 0).withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      Color.fromARGB(255, 201, 170, 252),
                                  child: Text("2"),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Send stock transfer",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ...buildStockTransferText(),
                            const SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                ElevatedButton(
                                  // dark blue background
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 32, 92),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      // padding vertical 15, horizontal 35
                                    ),
                                  ),
                                  onPressed:
                                      stockTransferModel == null || isSubmitting
                                          ? null
                                          : _sendStockTransfer,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 35,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      "Send stock transfer",
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
