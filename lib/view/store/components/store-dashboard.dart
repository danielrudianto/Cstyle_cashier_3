import 'dart:io';

import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/view/store/components/stat-card.component.dart';
import 'package:cstyle_cashier_3/viewmodel/theme.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({super.key});

  @override
  State<StoreDashboard> createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  TextEditingController codeEditingController = TextEditingController();
  bool isLoading = false;

  int newMemberCount = 0;
  int memberCount = 0;
  int billCount = 0;
  int billValue = 0;
  DateTime? lastUpdated;

  late Brightness brightness;

  Printer? printer;
  StoreModel? storeModel;

  _preUpdateStats(int period) async {
    // Check for storage
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var lastSynced = prefs.getString("last_synced:$period") == null
        ? null
        : DateTime.parse(prefs.getString("last_synced:$period")!);
    // check if online
    final result = await InternetAddress.lookup('google.com');
    var isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    if ((lastSynced == null ||
            lastSynced
                .isBefore(DateTime.now().subtract(const Duration(hours: 1)))) &&
        isOnline) {
      _fetchUpdateStats(period).then((value) {
        prefs.setString("last_synced:$period", DateTime.now().toString());
        prefs.setInt("new_member_count:$period", value[0]);
        prefs.setInt("member_count:$period", value[1]);
        prefs.setInt("bill_count:$period", value[2]);
        prefs.setInt("bill_value:$period", value[3]);

        setState(() {
          lastUpdated = DateTime.parse(prefs.getString("last_synced:$period")!);
          newMemberCount = prefs.getInt("new_member_count:$period") ?? 0;
          memberCount = prefs.getInt("member_count:$period") ?? 0;
          billCount = prefs.getInt("bill_count:$period") ?? 0;
          billValue = prefs.getInt("bill_value:$period") ?? 0;
          isLoading = false;
        });
      });
    } else {
      setState(() {
        lastUpdated = DateTime.parse(prefs.getString("last_synced:$period")!);
        newMemberCount = prefs.getInt("new_member_count:$period") ?? 0;
        memberCount = prefs.getInt("member_count:$period") ?? 0;
        billCount = prefs.getInt("bill_count:$period") ?? 0;
        billValue = prefs.getInt("bill_value:$period") ?? 0;
        isLoading = false;
      });
    }
  }

  _fetchUpdateStats(int period) {
    return StoreModel.fetchStats(period);
  }

  _showHelpDialog(String title, String description) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: 450,
              height: 200,
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                // border radius
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 15),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    Future.delayed(
        const Duration(
          milliseconds: 300,
        ), () {
      _preUpdateStats(1);

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
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 25,
        ),
        Text(
          "Welcome to your store page",
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "Currently operating on ${storeModel == null ? "" : storeModel!.name}",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Here you can check out your sales performance, track registered members, and monitor overall store activity.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 25,
        ),
        Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 35,
              horizontal: 15,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your store stats",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // select
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dropdownMenuTheme: DropdownMenuThemeData(
                                menuStyle: MenuStyle(
                                  elevation: WidgetStateProperty.all(8.0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                            child: DropdownMenu<int>(
                              // menu background color
                              initialSelection: 1,
                              onSelected: (value) {
                                if (value != null) {
                                  _preUpdateStats(value);
                                }
                              },
                              // white background
                              inputDecorationTheme: InputDecorationTheme(
                                filled: false,
                                contentPadding: const EdgeInsets.all(10.0),
                                // borer
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // color
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  // color
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                labelStyle:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              width: 0.4 *
                                  ResponsiveUtils.getContainerSize(context),
                              label: const Text("Assessment period"),
                              dropdownMenuEntries: [
                                {"label": "Today", "value": 1},
                                {"label": "Last 7 days", "value": 7},
                                {"label": "Last 30 days", "value": 30},
                                {"label": "Overall", "value": -1}
                              ].map((e) {
                                return DropdownMenuEntry(
                                  label: e["label"] as String,
                                  value: e["value"] as int,
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 15,
                                      ),
                                    ),
                                    textStyle: WidgetStateProperty.all(
                                      Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
                                      Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Last synced at ${lastUpdated == null ? "Never" : DateFormat("dd/MM/yyyy HH:mm").format(lastUpdated!)}",
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color!
                                          .withValues(alpha: 0.5),
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          "You can change the periode of your assessment here. By default it will be the today's assessment.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      StatCard(
                        number: NumberFormat.compact().format(newMemberCount),
                        title: "New member count",
                        description: "New members registered in your store",
                        onPressed: () {
                          _showHelpDialog("New member count.",
                              "Here are the members registered in your store for the last 30 days.");
                        },
                      ),
                      StatCard(
                        number: NumberFormat.compact().format(memberCount),
                        title: "Member count",
                        description: "Members registered in your store",
                        onPressed: () {
                          _showHelpDialog("Total member count.",
                              "Here are the total registered members in your store overall.");
                        },
                      ),
                      StatCard(
                        number: NumberFormat.compact().format(billCount),
                        title: "Bills count",
                        description: "Bills created and uploaded to the server",
                        onPressed: () {
                          _showHelpDialog("Bills count",
                              "Sales invoice / bill generated from this store that has been synchronized to CSTYLE private server. This sync process is done every certain amount of minutes from the application.");
                        },
                      ),
                      StatCard(
                        number: NumberFormat.compact().format(billValue),
                        title: "Bills value",
                        description: "Bills created and uploaded to the server",
                        onPressed: () {
                          _showHelpDialog("Bills value",
                              "Sales invoice / bill value generated from this store that has been synchronized to CSTYLE private server. This sync process is done every certain amount of minutes from the application.");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        /*
          BINGKAI PELANGI DIBUANG.

          Kartu ini dulu dikelilingi gradien biru-sian-merah muda setebal
          2,5 piksel — satu-satunya tempat di seluruh aplikasi yang memakai
          warna-warna itu, dan tidak satu pun di antaranya berarti apa-apa.
          Akibatnya menyinkronkan stok tampil sebagai hal paling meriah di
          halaman ini, di atas angka penjualan sekalipun.

          Yang menonjol seharusnya isinya, bukan bingkainya. Sekarang ia
          memakai permukaan dan garis rambut yang sama dengan kartu lain;
          satu-satunya warna di sini tinggal tombolnya, yang memang tempat
          tindakannya berada.
        */
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sync stock",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Pulls the latest stock figures from the server. Needs an "
                  "internet connection.",
                  /* Penjelasan, bukan isi: diredupkan dan dikecilkan. */
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  height: 25,
                ),
                /*
                  Dulu InkWell membungkus sebuah Container bergaris yang
                  KELIHATAN seperti tombol tanpa berperilaku seperti tombol:
                  tanpa keadaan sorot, tanpa umpan balik tekan, tanpa kursor
                  tangan. Sekarang tombol sungguhan, dan temanya yang memberi
                  keempatnya sekaligus.
                */
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(150, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      var storeModel = await StoreModel.getCurrentProfile();
                      String storeCode = storeModel!.code!;
                      await ProductStockModel.fetchServerStock(storeCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Stock overridden successfully",
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Failed to override stock",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Sync now"),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 35,
              horizontal: 15,
            ),
            child: Consumer<ThemeNotifier>(builder: (_, value, __) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Theme setting",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    /*
                      Dulu RadioListTile<Brightness> dengan groupValue berbunyi
                      "terang kalau light, selain itu gelap". Mode "ikut sistem"
                      tidak punya wakil di situ, jadi ia tampil sebagai "Dark"
                      terpilih walaupun layarnya sedang terang.

                      Sekarang bertipe ThemeMode dan ketiga keadaannya diwakili
                      apa adanya, termasuk "ikut sistem" yang sebelumnya tidak
                      bisa dicapai sama sekali — penjelasannya di
                      viewmodel/theme.viewmodel.dart.
                    */
                    RadioListTile<ThemeMode>(
                      title: Text(
                        'Follow system',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      groupValue: value.themeMode,
                      value: ThemeMode.system,
                      onChanged: (_) =>
                          Provider.of<ThemeNotifier>(context, listen: false)
                              .setSystemScheme(),
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(
                        'Light',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      groupValue: value.themeMode,
                      value: ThemeMode.light,
                      onChanged: (_) =>
                          Provider.of<ThemeNotifier>(context, listen: false)
                              .setLightScheme(),
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(
                        'Dark',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      groupValue: value.themeMode,
                      value: ThemeMode.dark,
                      onChanged: (_) =>
                          Provider.of<ThemeNotifier>(context, listen: false)
                              .setDarkScheme(),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Card(
          color: Theme.of(context).cardColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 35,
              horizontal: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 5,
                  width: double.infinity,
                ),
                Text(
                  "Printer setting",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: 15,
                ),
                if (printer == null) ...[
                  Text(
                    "No printer is set. Please set your printer to enable printing.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () async {
                      Printing.pickPrinter(context: context)
                          .then((selectedPrinter) {
                        if (selectedPrinter == null) {
                          return;
                        } else if (selectedPrinter.isAvailable == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Printer is currently not available")));
                          return;
                        } else {
                          setState(() {
                            printer = selectedPrinter;
                          });

                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString("printer:url", selectedPrinter.url);
                            prefs.setString(
                                "printer:name", selectedPrinter.name);
                          });
                        }
                      });
                    },
                    child: Container(
                      // width fit
                      width: 150,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      // border 1 px solid #ccc
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Set printer",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    "Printer: ${printer!.name}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      Printing.pickPrinter(context: context)
                          .then((selectedPrinter) {
                        if (selectedPrinter != null) {
                          if (selectedPrinter.isAvailable == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Printer is currently not available"),
                              ),
                            );
                          } else {
                            setState(() {
                              printer = selectedPrinter;
                            });

                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                  "printer:url", selectedPrinter.url);
                              prefs.setString(
                                  "printer:name", selectedPrinter.name);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Printer has been changed successfully"),
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      // border 1 px solid #ccc
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Change printer",
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        // button to logout from application
        InkWell(
          onTap: () async {
            /*
              Dulu then().catchError(). Penangkap galatnya tidak pernah
              mengembalikan nilai, sementara rantainya bertipe Never karena
              exit(0) tidak pernah kembali — analyzer menandainya, dan pesan
              "Failed to logout" pun tidak pernah benar-benar tampil.

              Bentuk try/catch juga membuat penjagaan mounted mungkin: tanpa
              itu, context dipakai sesudah await pada widget yang bisa saja
              sudah dilepas.
            */
            final messenger = ScaffoldMessenger.of(context);

            try {
              await StoreModel.removeCurrentProfile();
              exit(0);
            } catch (error) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("Failed to logout"),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 35,
            ),
            color: Theme.of(context).canvasColor,
            child: Text(
              "Logout",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}
