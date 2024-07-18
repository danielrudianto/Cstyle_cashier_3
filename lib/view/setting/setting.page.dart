import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
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
  StoreModel? storeModel;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      var storedPrinter = prefs.getString('printer:url') == null
          ? null
          : Printer(
              url: prefs.getString("printer:url")!,
              name: prefs.getString("printer:name")!,
            );

      setState(() {
        printer = storedPrinter;
      });
    });
    StoreModel.getCurrentProfile().then((store) {
      setState(() {
        storeModel = store;
      });
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
                  width: ResponsiveUtils.getContainerSize(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Application Settings",
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
                        "Set up the fundamental settings of the application.",
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
                              "Change Store",
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
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: ResponsiveUtils.getContainerSize(context),
              child: ExpansionPanelList.radio(
                initialOpenPanelValue: 0,
                children: [
                  ExpansionPanelRadio(
                    value: 0,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        child: Text("Printer setting"),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.grey.shade400,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              printer == null
                                  ? "Printer has not been set up. Please set up the printer first."
                                  : printer!.name,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Printing.pickPrinter(context: context)
                                    .then((selectedPrinter) {
                                  if (selectedPrinter == null) {
                                    return;
                                  } else if (selectedPrinter.isAvailable ==
                                      false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Printer is currently not available")));
                                    return;
                                  } else {
                                    setState(() {
                                      printer = selectedPrinter;
                                    });

                                    SharedPreferences.getInstance()
                                        .then((prefs) {
                                      prefs.setString(
                                          "printer:url", selectedPrinter.url);
                                      prefs.setString(
                                          "printer:name", selectedPrinter.name);
                                    });
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 35,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: const Color.fromARGB(255, 0, 32, 92),
                                ),
                                child: const Text(
                                  "Set up default printer.",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanelRadio(
                    value: 1,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Application setting"),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Text('Currently operating ${storeModel?.name}'),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(storeModel?.address ?? "N/A"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ExpansionPanelRadio(
                    value: 2,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Manual override"),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Please be cautious when doing an override.'),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  String storeCode = storeModel!.code!;
                                  await ProductStockModel.fetchServerStock(
                                      storeCode);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Stock overridden successfully",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to override stock",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 35,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: const Color.fromARGB(255, 0, 32, 92),
                                ),
                                child: const Text(
                                  "Override Stock",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
