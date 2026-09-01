import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/list-stock-transfer/components/list-stock-transfer-detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListStockTransfer extends StatefulWidget {
  const ListStockTransfer({super.key});

  @override
  State<ListStockTransfer> createState() => _ListStockTransferState();
}

class _ListStockTransferState extends State<ListStockTransfer> {
  List<StockTransferFetchmodel> stockTransfers = [];
  int count = 0;
  int page = 1;

  _fetchStockTransfer() async {
    var fetchedStockTransfers = await StockTransferFetchmodel.fetchCreated(
      page,
    );

    setState(() {
      stockTransfers = fetchedStockTransfers['data'];
      count = fetchedStockTransfers['count'];
    });
  }

  @override
  void initState() {
    _fetchStockTransfer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 221,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                showCheckboxColumn: false,
                dividerThickness: 0.25,
                // border color only horizontal
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                  verticalInside: BorderSide.none,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      "Name",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Request From",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Request To",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Created by",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Created at",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
                rows: stockTransfers.isEmpty == true
                    ? [
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "No data",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const DataCell(
                              Text(""),
                            ),
                            const DataCell(
                              Text(""),
                            ),
                            const DataCell(
                              Text(""),
                            ),
                            const DataCell(
                              Text(""),
                            ),
                          ],
                        ),
                      ]
                    : stockTransfers
                        .map(
                          (stockTransfer) => DataRow(
                            selected: false,
                            onSelectChanged: (value) {
                              // show dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Stock Transfer Detail"),
                                    content: ListStockTransferDetail(
                                      id: stockTransfer.id!,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            cells: [
                              DataCell(
                                Text(
                                  stockTransfer.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  stockTransfer.requestFrom == null
                                      ? "Office"
                                      : stockTransfer.requestFrom!['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  stockTransfer.requestTo == null
                                      ? "Office"
                                      : stockTransfer.requestTo!['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  stockTransfer.createdBy,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat("dd MMM yyyy HH:mm")
                                      .format(stockTransfer.createdAt),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
        PaginationComponent(
          pageIndex: page - 1,
          pageSize: 10,
          dataCount: count,
          onPageChange: (newPage) {
            setState(() {
              page = newPage + 1;
            });
            _fetchStockTransfer();
          },
        ),
      ],
    );
  }
}
