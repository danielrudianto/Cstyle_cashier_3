import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillViewPage extends StatefulWidget {
  final int id;
  const BillViewPage({super.key, required this.id});

  @override
  State<BillViewPage> createState() => _BillViewPageState();
}

class _BillViewPageState extends State<BillViewPage> {
  bool isLoading = true;
  bool isOpened = false;
  BillCodeModelPrint? billCode;

  fetchData() {
    BillCodeModelPrint.fetchByID(widget.id).then((value) {
      setState(() {
        billCode = value;
        isLoading = false;
      });
    });
  }

  closeDialog(String? data) {
    setState(() {
      isOpened = false;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      router.pop(data);
    });
  }

  @override
  void initState() {
    fetchData();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        isOpened = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        closeDialog(null);
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: isOpened ? 1 : 0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(50, 0, 0, 0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                height: 0.8 * MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      10,
                    ),
                    topRight: Radius.circular(
                      10,
                    ),
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      closeDialog("print");
                                    },
                                    icon: Icon(Icons.print),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      closeDialog(null);
                                    },
                                    icon: Icon(Icons.close),
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
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Table(
                                // only want horizontal borders without vertical ones
                                border: const TableBorder(
                                  horizontalInside: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  verticalInside: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  top: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  left: BorderSide(
                                    color: Colors.transparent,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  right: BorderSide(
                                    color: Colors.transparent,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text("Product",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          "Price",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          "Quantity",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          "Total",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...billCode!.bills.map((x) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(x.reference,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge),
                                              Text(x.description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            NumberFormat.currency(
                                                    locale: 'id', symbol: 'Rp ')
                                                .format(x.price),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(x.quantity.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              textAlign: TextAlign.center),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            NumberFormat.currency(
                                                    locale: 'id', symbol: 'Rp ')
                                                .format((x.price *
                                                        (100 - x.discount) /
                                                        100) *
                                                    x.quantity),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Payments",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Table(
                                // only want horizontal borders without vertical ones
                                border: const TableBorder(
                                  horizontalInside: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  verticalInside: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  top: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black54,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  left: BorderSide(
                                    color: Colors.transparent,
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                  ),
                                  right: BorderSide(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          "Amount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...billCode!.payments.map((x) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            x.paymentMethod,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp ')
                                                  .format(x.amount),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
