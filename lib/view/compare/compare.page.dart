import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Compare products"),
      ),
      body: Consumer<CompareNotifier>(builder: (_, value, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveUtils.getContainerSize(context),
              height: double.infinity,
              child: value.selectedComparisson.length == 3
                  ? Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Reference",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].reference,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].reference,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[2].reference,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Description",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[2].description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Brand",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].brand,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].brand,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[2].brand,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Type",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].type,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].type,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[2].type,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Price",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                NumberFormat.decimalPattern()
                                    .format(value.selectedComparisson[0].price),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                NumberFormat.decimalPattern()
                                    .format(value.selectedComparisson[1].price),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                NumberFormat.decimalPattern()
                                    .format(value.selectedComparisson[2].price),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Reference",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].reference,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].reference,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Description",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Brand",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].brand,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].brand,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Type",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[0].type,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                value.selectedComparisson[1].type,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Price",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                NumberFormat.decimalPattern()
                                    .format(value.selectedComparisson[0].price),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                NumberFormat.decimalPattern()
                                    .format(value.selectedComparisson[1].price),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }
}
