import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/history/components/bill-view.page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BillCodeModelFetch> bills = [];
  int count = 0;
  int page = 1;

  _fetchBill() async {
    try {
      var fetchedBills = await BillCodeModelFetch.fetchHistory(
        page,
      );

      setState(() {
        bills = fetchedBills['data'] as List<BillCodeModelFetch>;
        count = fetchedBills['count'];
      });
    } catch (e) {
      LoggerUtils().log("Error", LogType.error,
          error: e, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch data"),
        ),
      );
    }
  }

  @override
  void initState() {
    _fetchBill();
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
                      "Date",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Name",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Member ID",
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
                rows: bills.isEmpty == true
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
                    : bills
                        .map(
                          (bill) => DataRow(
                            onSelectChanged: (value) {
                              if (value == true) {
                                // open bottom sheet
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        width: 400,
                                        padding: const EdgeInsets.all(20),
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pop("view");
                                              },
                                              leading: Icon(
                                                Icons.view_array,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                              ),
                                              title: Text(
                                                "View bill",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).then((value) {
                                  if (value == 'view') {
                                    // open view bill page
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          // minimum width
                                          content: SizedBox(
                                            width: 800,
                                            child: BillViewPage(id: bill.id),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                });
                              }
                            },
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat("dd MMM yyyy").format(bill.date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  bill.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  bill.memberID == null
                                      ? "NO"
                                      : bill.memberID!.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  bill.createdBy.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat("dd MMM yyyy HH:mm")
                                      .format(bill.createdAt),
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
          pageSize: 20,
          dataCount: count,
          onPageChange: (newPage) {
            setState(() {
              page = newPage + 1;
            });
            _fetchBill();
          },
        ),
      ],
    );
  }
}
