import 'dart:io';

import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/view/store/components/stat-card.component.dart';
import 'package:cstyle_cashier_3/viewmodel/theme.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/waktu.utils.dart';
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
            /*
              Dulu 35 piksel di atas dan bawah untuk satu judul dan tiga
              pilihan. Setelan yang isinya sedikit tidak menjadi lebih mudah
              dibaca karena dikelilingi ruang kosong sebesar itu; yang terjadi
              justru harus menggulir jauh untuk menemukannya.
            */
            padding: const EdgeInsets.all(20),
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
                            lastUpdated == null
                                ? "Never synced"
                                : "Last synced ${waktuManusiawi(lastUpdated!)}",
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
        /*
          BERDAMPINGAN, BUKAN BERSUSUN.

          Keduanya setelan pendek — satu pilihan tema, satu pilihan pencetak —
          dan bersusun keduanya menjadi dua kartu selebar penuh yang isinya
          hanya beberapa baris, dengan sisa lebarnya kosong. Berdampingan,
          lebar kartunya mendekati lebar isinya, dan halaman ini kehilangan satu
          layar penuh gulungan.

          IntrinsicHeight menyamakan tingginya. Tanpa itu, kartu yang isinya
          lebih pendek berakhir menggantung, dan dua kartu bersebelahan dengan
          tinggi berbeda terbaca sebagai kesalahan, bukan sebagai pilihan.
        */
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  child: Padding(
                    /*
                      Dulu 35 piksel di atas dan bawah untuk satu judul dan tiga
                      pilihan. Setelan yang isinya sedikit tidak menjadi lebih mudah
                      dibaca karena dikelilingi ruang kosong sebesar itu; yang terjadi
                      justru harus menggulir jauh untuk menemukannya.
                    */
                    padding: const EdgeInsets.all(20),
                    child: Consumer<ThemeNotifier>(builder: (_, value, __) {
                      /*
                        Center DIBUANG.

                        Isinya — satu judul dan tiga tombol, totalnya sekitar tiga
                        ratus piksel — ditaruh di tengah kartu selebar seribu seratus.
                        Yang terlihat bukan kartu yang lapang, melainkan kartu yang
                        KOSONG, karena tidak ada apa pun di kiri dan kanan isinya yang
                        menjelaskan kenapa ruang itu ada.
                      */
                      return Align(
                        alignment: Alignment.centerLeft,
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
                            /*
                              TIGA RadioListTile MENJADI SATU BARIS BERSEGMEN.

                              Masing-masing tile setinggi lima puluh piksel dan selebar
                              kartu, jadi tiga pilihan yang saling meniadakan memakan
                              seratus lima puluh piksel dan tampak seperti daftar yang
                              bisa panjang. Padahal jumlahnya tetap tiga, selamanya, dan
                              ketiganya muat berdampingan dalam satu baris.

                              Bentuk bersegmen juga menyatakan hubungannya dengan lebih
                              jujur: memilih salah satu berarti melepas dua lainnya.
                            */
                            _PilihanTema(terpilih: value.themeMode),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  child: Padding(
                    /*
                      Dulu 35 piksel di atas dan bawah untuk satu judul dan tiga
                      pilihan. Setelan yang isinya sedikit tidak menjadi lebih mudah
                      dibaca karena dikelilingi ruang kosong sebesar itu; yang terjadi
                      justru harus menggulir jauh untuk menemukannya.
                    */
                    padding: const EdgeInsets.all(20),
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
                          /*
                            Bergaris, bukan terisi: memilih pencetak adalah persiapan
                            sekali pasang, bukan tindakan utama halaman ini.
                          */
                          OutlinedButton.icon(
                            icon: const Icon(Icons.print_outlined, size: 17),
                            label: const Text("Set printer"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(150, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
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

                                  SharedPreferences.getInstance().then((prefs) {
                                    prefs.setString(
                                        "printer:url", selectedPrinter.url);
                                    prefs.setString(
                                        "printer:name", selectedPrinter.name);
                                  });
                                }
                              });
                            },
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
                                        content: Text(
                                            "Printer is currently not available"),
                                      ),
                                    );
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
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        // button to logout from application
        _TombolKeluar(
          onKeluar: () async {
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
          /*
            DIAM SAAT TIDAK DISENTUH, MERAH SAAT DISOROT.

            Percobaan sebelumnya memberinya garis merah tetap. Itu keliru ke
            arah sebaliknya: ia menjadi satu-satunya benda berwarna galat di
            seluruh halaman, berdiri sendirian di bawah, dan mata membacanya
            sebagai peringatan tentang sesuatu yang sedang terjadi — padahal
            tidak ada yang terjadi; itu hanya tombol yang jarang ditekan.

            Tindakan yang jarang tetapi berat sebaiknya begini: tenang sampai
            didekati, lalu menyatakan dirinya. Peringatannya muncul tepat saat
            ia berguna — ketika kursor sudah berada di atasnya.
          */
        ),
      ],
    );
  }
}

/// Pilihan tema sebagai satu baris bersegmen.
///
/// Menggantikan tiga RadioListTile yang masing-masing selebar kartu. Jumlah
/// pilihannya tetap tiga selamanya, jadi tidak ada alasan memberinya bentuk
/// daftar yang bisa bertambah panjang.
class _PilihanTema extends StatelessWidget {
  final ThemeMode terpilih;

  const _PilihanTema({required this.terpilih});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final notifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: warna.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmenTema(
            ikon: Icons.brightness_auto_outlined,
            label: "Follow system",
            aktif: terpilih == ThemeMode.system,
            onTekan: notifier.setSystemScheme,
          ),
          const SizedBox(width: 3),
          _SegmenTema(
            ikon: Icons.light_mode_outlined,
            label: "Light",
            aktif: terpilih == ThemeMode.light,
            onTekan: notifier.setLightScheme,
          ),
          const SizedBox(width: 3),
          _SegmenTema(
            ikon: Icons.dark_mode_outlined,
            label: "Dark",
            aktif: terpilih == ThemeMode.dark,
            onTekan: notifier.setDarkScheme,
          ),
        ],
      ),
    );
  }
}

class _SegmenTema extends StatefulWidget {
  final IconData ikon;
  final String label;
  final bool aktif;
  final VoidCallback onTekan;

  const _SegmenTema({
    required this.ikon,
    required this.label,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_SegmenTema> createState() => _SegmenTemaState();
}

class _SegmenTemaState extends State<_SegmenTema> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final Color latar = widget.aktif
        ? warna.primary
        : (_disorot
            ? warna.onSurface.withValues(alpha: 0.07)
            : Colors.transparent);

    final Color depan = widget.aktif
        ? warna.onPrimary
        : warna.onSurface.withValues(alpha: _disorot ? 0.92 : 0.62);

    return MouseRegion(
      cursor: widget.aktif ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.aktif ? null : widget.onTekan,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.ikon, size: 16, color: depan),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: depan,
                  fontSize: 13,
                  fontWeight: widget.aktif ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol keluar dari toko.
///
/// Tenang sampai disorot, lalu merah. Ia menjalankan exit(0) — apa pun yang
/// belum tersinkron ditinggalkan — jadi peringatannya memang perlu ada; yang
/// tidak perlu adalah peringatan itu menyala sepanjang waktu pada halaman yang
/// dibuka untuk mengganti pencetak.
class _TombolKeluar extends StatefulWidget {
  final Future<void> Function() onKeluar;

  const _TombolKeluar({required this.onKeluar});

  @override
  State<_TombolKeluar> createState() => _TombolKeluarState();
}

class _TombolKeluarState extends State<_TombolKeluar> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final depan =
        _disorot ? warna.error : warna.onSurface.withValues(alpha: 0.55);

    return Align(
      alignment: Alignment.centerLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _disorot = true),
        onExit: (_) => setState(() => _disorot = false),
        child: GestureDetector(
          onTap: () => widget.onKeluar(),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: Gerak.kilat,
            curve: Gerak.masuk,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _disorot
                  ? warna.error.withValues(alpha: 0.09)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 16, color: depan),
                const SizedBox(width: 9),
                Text(
                  "Log out of this store",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: depan,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
