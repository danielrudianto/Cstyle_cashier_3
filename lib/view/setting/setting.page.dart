import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Printer? printer;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      var storedPrinter = prefs.getString('printer:url') == null
          ? null
          : Printer(
              url: prefs.getString("printer:url")!,
              name: prefs.getString("printer:name")!,
              location: prefs.getString("printer:location")!,
            );

      setState(() {
        printer = storedPrinter;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Setting Page"),
          Text("Default printer"),
          printer == null ? Text("No printer selected") : Text(printer!.name),
          ElevatedButton(
            onPressed: () {
              Printing.pickPrinter(context: context).then((value) {
                if (value != null) {
                  setState(() {
                    printer = value;
                  });
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString("printer:url", value.url);
                    prefs.setString("printer:name", value.name);
                    prefs.setString("printer:location", value.location ?? "");
                  });
                }
              }).catchError((error) {
                LoggerUtils().log(error.toString(), LogType.error);
              });
            },
            child: Text("Set up printer"),
          )
        ],
      ),
    );
  }
}
