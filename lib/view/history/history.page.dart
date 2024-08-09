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
    return null;
  }

  Future<void> print(String name, Printer printer) async {
    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (format) => PrintingUtils.generatePDF(name),
    );
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          "History",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
