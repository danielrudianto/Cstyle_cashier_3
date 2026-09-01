import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/printing.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardTypeSelector extends StatefulWidget {
  final List<String> productTypes;
  final List<String> selectedTypes;
  final Function onUpdateSelectedTypes;
  final Function onSearch;
  final Function onFocus;
  final Function onUnfocus;

  const DashboardTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.productTypes,
    required this.onUpdateSelectedTypes,
    required this.onSearch,
    required this.onFocus,
    required this.onUnfocus,
  });

  @override
  State<DashboardTypeSelector> createState() => DashboardTypeSelectorState();
}

class DashboardTypeSelectorState extends State<DashboardTypeSelector> {
  late FocusNode searchFocusNode;

  @override
  void initState() {
    searchFocusNode = FocusNode();
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        widget.onFocus();
      } else {
        widget.onUnfocus();
      }
    });
    super.initState();
  }

  Future<Printer?> checkPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("printer:name") == null ||
        prefs.getString("printer:url") == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Default printer is not found. Please select a printer"),
      ));
    } else {
      var selectedPrinter = Printer(
          url: prefs.getString("printer:url")!,
          name: prefs.getString("printer:name")!);

      if (selectedPrinter.isAvailable) {
        return selectedPrinter;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Default printer is not available. Please select a printer"),
        ));
      }
    }
    return null;
  }

  /// Gaya label penyaring; yang belum terpilih diredupkan.
  ///
  /// Tinggi barisnya disebut karena beberapa nama tipe membungkus ke dua baris
  /// ("CLEARO / CARTRIDGES"), dan tanpa itu keduanya menempel terlalu rapat.
  TextStyle? _gayaPenyaring(BuildContext context, bool terpilih) {
    final dasar = Theme.of(context).textTheme.bodyMedium;
    if (dasar == null) return null;

    /*
      Dibuat berkarakter LABEL, bukan disamakan dengan kode referensi di tabel.

      Yang membuat tulisan terbaca sebagai label adalah ukuran kecil DAN jarak
      antarhuruf yang dilebarkan — bukan warnanya yang diabukan. Kode referensi
      di tabel memakai 12px abu karena ia metadata yang sesekali dilirik;
      penyaring ini target klik yang dibaca sejauh lengan, dan 12px abu di situ
      menyulitkan keduanya sekaligus.

      Jadi yang diambil karakternya: 14px dengan jarak huruf dilebarkan, warna
      tetap penuh untuk yang terpilih. Bidang sentuh ListTile tidak ikut
      mengecil — ia ditentukan tinggi tile, bukan tinggi hurufnya.
    */
    return dasar.copyWith(
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0.4,
      fontWeight: terpilih ? FontWeight.w700 : FontWeight.w400,
      color: terpilih ? dasar.color : dasar.color?.withValues(alpha: 0.62),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        10,
      ),
      width: 250,
      height: double.infinity,
      // Create horizontal line border on the right side of #ccc
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          TextFormField(
            focusNode: searchFocusNode,
            decoration: const InputDecoration(
              labelStyle: TextStyle(
                color: Color.fromARGB(255, 122, 122, 122),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 209, 209, 209),
                ),
              ),
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 209, 209, 209),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 179, 179, 179),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 1,
                horizontal: 3,
              ),
              prefixIconColor: Color.fromARGB(255, 209, 209, 209),
            ),
            style: const TextStyle(
              color: Color.fromARGB(255, 122, 122, 122),
              fontFamily: "Lato",
            ),
            onChanged: (value) {
              widget.onSearch(value);
            },
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "Product Types",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: Checkbox(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    checkColor: Theme.of(context).colorScheme.onPrimary,
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: widget.selectedTypes.isEmpty,
                    onChanged: (value) {
                      if (value != null && value == true) {
                        // Remove all
                        widget.selectedTypes.clear();
                        widget.onUpdateSelectedTypes(widget.selectedTypes);
                      } else if (value != null && value == false) {
                        return;
                      }
                    },
                  ),
                  /*
                    HIERARKINYA DULU TERBALIK.

                    Daftar penyaring ini memakai bodyLarge (18) sementara nama
                    barang di tabel tengah memakai bodyMedium (16) — jadi yang
                    jarang disentuh tampil LEBIH BESAR daripada yang dipelototi
                    kasir sepanjang hari. Mata jatuh ke kolom kiri lebih dulu,
                    setiap kali.

                    Yang diturunkan chrome-nya, bukan dinaikkan isinya:
                    membesarkan nama barang akan menaikkan tinggi baris dan
                    mengurangi jumlah barang yang muat di layar.

                    Yang belum terpilih juga diredupkan. Sebelumnya kelima
                    belas penyaring sama nyaringnya, sehingga yang sedang aktif
                    tidak terbaca sebagai aktif.
                  */
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    "All",
                    style:
                        _gayaPenyaring(context, widget.selectedTypes.isEmpty),
                  ),
                ),
                ...widget.productTypes.map((e) {
                  return ListTile(
                    leading: Checkbox(
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: widget.selectedTypes.contains(e),
                      onChanged: (checkBoxValue) {
                        if (checkBoxValue != null && checkBoxValue == false) {
                          widget.selectedTypes
                              .removeWhere((element) => element == e);
                        } else if (checkBoxValue != null &&
                            checkBoxValue == true) {
                          widget.selectedTypes.add(e);
                        }

                        widget.onUpdateSelectedTypes(widget.selectedTypes);
                      },
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      e,
                      style: _gayaPenyaring(
                        context,
                        widget.selectedTypes.contains(e),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          Row(
            children: [
              Consumer<CompareNotifier>(builder: (_, value, __) {
                return IconButton(
                  // size
                  iconSize: 25,
                  onPressed: value.selectedComparisson.length >= 2
                      ? () {
                          router.push("/compare");
                        }
                      : null,
                  icon: Icon(Icons.compare_arrows_rounded,
                      color: value.selectedComparisson.length >= 2
                          ? Theme.of(context).iconTheme.color
                          : Theme.of(context).disabledColor),
                );
              }),
              IconButton(
                onPressed: () {
                  // Check last bill
                  BillCodeModel.fetchLastBillCode().then((value) {
                    if (value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No bill found",
                          ),
                        ),
                      );
                    } else {
                      // Check printer
                      checkPrinter().then((printer) async {
                        if (printer == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "No printer found. Please select printer from your store page.",
                              ),
                            ),
                          );
                        } else {
                          await Printing.directPrintPdf(
                            printer: printer,
                            onLayout: (format) =>
                                PrintingUtils.generatePDF(value.name),
                          );
                        }
                      });
                    }
                  });
                },
                icon: Icon(
                  Icons.print,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Check last bill
                  router.push("/local");
                },
                icon: Icon(
                  Icons.data_array,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
