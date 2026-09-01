import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillViewPage extends StatefulWidget {
  final String id;
  const BillViewPage({super.key, required this.id});

  @override
  State<BillViewPage> createState() => _BillViewPageState();
}

class _BillViewPageState extends State<BillViewPage> {
  bool isLoading = true;
  bool isOpened = false;
  BillCodeModelFetch? billCode;

  fetchData() {
    BillCodeModelFetch.fetchByID(widget.id).then((value) {
      setState(() {
        billCode = value;
        isLoading = false;
      });
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      Navigator.pop(context);
    });
  }

  closeDialog(String? data) {
    setState(() {
      isOpened = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      router.pop(data);
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: "Close",
                  onPressed: () {
                    closeDialog(null);
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            Text(
              "Name",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              billCode!.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Date",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(billCode!.date),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Member",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              billCode?.memberID == null
                  ? "Non-member"
                  : billCode!.memberID.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Items",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 15,
            ),
            Table(
              // only want horizontal borders without vertical ones
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                verticalInside: const BorderSide(
                  color: Colors.transparent,
                ),
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                left: const BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                right: const BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              // vertical align middle
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text("Product",
                          style: Theme.of(context).textTheme.labelLarge),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Price",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Discount",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Quantity",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Total",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...billCode!.items!.map((x) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(x.itemID.reference,
                                style: Theme.of(context).textTheme.bodySmall),
                            Text(x.itemID.description,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ')
                              .format(x.price),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ')
                              .format(x.price -
                                  ((x.price - x.discount) / 1000).floor() *
                                      1000),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(x.quantity.toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ')
                              .format(
                                  ((x.price - x.discount) * x.quantity / 1000)
                                          .floor() *
                                      1000),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }),
                TableRow(
                  // total
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text("",
                          style: Theme.of(context).textTheme.labelLarge),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Total",
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ')
                            .format(
                          billCode!.items!
                              .map((x) =>
                                  ((x.price - x.discount) * x.quantity / 1000)
                                      .floor() *
                                  1000)
                              .reduce((value, element) => value + element),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Payments",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 15,
            ),
            Table(
              // only want horizontal borders without vertical ones
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                verticalInside: const BorderSide(
                  color: Colors.transparent,
                ),
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                left: const BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                right: const BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Method",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Amount",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...billCode!.payment!.map((x) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          // x.type to title case
                          x.type[0].toUpperCase() + x.type.substring(1),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                            NumberFormat.currency(locale: 'id', symbol: 'Rp ')
                                .format(x.amount),
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
