import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocalHistoryPage extends StatefulWidget {
  const LocalHistoryPage({super.key});

  @override
  State<LocalHistoryPage> createState() => _LocalHistoryPageState();
}

class _LocalHistoryPageState extends State<LocalHistoryPage> {
  List<BillCodeModelFetchLocal> bills = [];
  int count = 0;
  int page = 1;

  _fetchBill() async {
    try {
      var fetchedBills = await BillCodeModelFetchLocal.fetch(
        page,
      );

      setState(() {
        bills = fetchedBills['data'] as List<BillCodeModelFetchLocal>;
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
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            "Local History",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          leading: IconButton(
            tooltip: "Back",
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Column(
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
                /*
                  Garisnya dulu DOBEL: TableBorder di bawah ini plus garis
                  baris bawaan DataTable dari Theme.dividerColor — dua garis
                  bertumpuk yang terbaca sebagai satu garis tebal. Garis
                  bawaannya dimatikan lewat tema, dan yang tinggal satu
                  memakai token pemisah apa adanya.
                */
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    // Jalur yang benar-benar dibaca DataTable pada Material 3.
                    dividerTheme:
                        const DividerThemeData(color: Colors.transparent),
                  ),
                  child: DataTable(
                      showCheckboxColumn: false,
                      dividerThickness: 0,
                      // border color only horizontal
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Theme.of(context).dividerColor,
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
                            "ID",
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
                      rows: bills.isEmpty
                          ? []
                          : bills.map((bill) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      DateFormat("dd MMM yyyy")
                                          .format(bill.date),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      bill.name,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      bill.memberID == null
                                          ? "NO"
                                          : bill.memberID!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      bill.mongoID == null
                                          ? "Not synced"
                                          : bill.mongoID!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat("dd MMM yyyy HH:mm")
                                          .format(bill.date),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              );
                            }).toList()),
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
      ),
    );
  }
}
