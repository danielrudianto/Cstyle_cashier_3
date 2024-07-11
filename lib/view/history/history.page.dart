import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/printing.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int page = 1;
  List<BillCodeModel> bills = [];
  int billCount = 0;

  Future<void> _loadData() async {
    BillCodeModel.fetchHistory(page).then((value) {
      setState(() {
        bills = value;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  Future<Printer?> prePrint(String name) async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString("printer:name") == null ||
        prefs.getString("printer:url") == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Default printer is not found. Please select a printer"),
      ));

      var printer = await Printing.pickPrinter(context: context);
      if (printer != null) {
        print(name, printer);
      }
    } else {
      var printer = Printer(url: prefs.getString("printer:url")!);
      if (!printer.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Printer is not available"),
        ));

        var printer = await Printing.pickPrinter(context: context);
        if (printer != null) {
          print(name, printer);
        }
      } else {
        print(name, printer);
      }
    }
  }

  Future<void> print(String name, Printer printer) async {
    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (format) => PrintingUtils.generatePDF(name),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 300), () {
      _loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                        "History",
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
                        "View your transaction history here",
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
                        onTap: () {},
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
                              "Get today's daily report",
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
            SizedBox(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                child: Column(
                  children: [
                    bills.isEmpty
                        ? const Text("Data not found")
                        : ListView(
                            shrinkWrap: true,
                            children: bills.map((x) {
                              return ListTile(
                                onTap: () {
                                  router
                                      .push("/history/" + x.id.toString())
                                      .then((value) {
                                    if (value == "print") {
                                      prePrint(x.name);
                                    }
                                  });
                                },
                                contentPadding: const EdgeInsets.only(
                                  top: 10,
                                  left: 5,
                                  right: 5,
                                  bottom: 10,
                                ),
                                shape: const Border(
                                  bottom: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                title: Text(x.name),
                                subtitle: Text(
                                    DateFormat('dd MMM yyyy').format(x.date)),
                                leading: x.mongoID != null
                                    ? Icon(Icons.sync)
                                    : Icon(
                                        Icons.sync_disabled_outlined,
                                      ),
                              );
                            }).toList(),
                          ),
                    // pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (page > 1) {
                              setState(() {
                                page--;
                              });
                              _loadData();
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text("$page"),
                        const SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          onPressed: () {
                            if (bills.length == 10) {
                              setState(() {
                                page++;
                              });
                              _loadData();
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
