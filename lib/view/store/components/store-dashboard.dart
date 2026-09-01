import 'dart:io';

import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/view/store/components/stat-card.component.dart';
import 'package:cstyle_cashier_3/viewmodel/theme.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/waktu.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/components/brand-backdrop/brand-backdrop.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreDashboard extends StatefulWidget {
  /// Membuka ringkasan penjualan hari ini.
  ///
  /// Dijalankan halaman induk karena dialognya milik StorePage; yang ada di
  /// sini hanya tempat menekannya.
  final VoidCallback onLaporanHarian;

  const StoreDashboard({super.key, required this.onLaporanHarian});

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
        const SizedBox(height: 22),
        /*
          BARIS KETERANGAN TERMINAL.

          Empat hal yang ditanyakan sekali lalu tidak perlu ditanyakan lagi:
          versi berapa yang jalan, toko mana yang terpasang, kapan terakhir
          disinkronkan, dan pencetak mana yang aktif. Sebelum ini tidak satu pun
          terjawab di layar — versi hanya ada di layar pembuka yang lewat dalam
          dua detik, kode toko tidak pernah ditampilkan sama sekali, dan
          pencetak baru terlihat kalau menggulir sampai bawah.

          Bentuknya baris, bukan kartu: keterangan yang jarang berubah tidak
          perlu wadah, cukup dua garis rambut yang memisahkannya dari isi.
        */
        BarisMeta(
          isi: [
            const Meta("VERSION", BrandBackdrop.versiAplikasi),
            Meta(
              "STORE",
              storeModel?.code == null
                  ? "—"
                  : storeModel!.code!.replaceAll("-", "").substring(0, 8),
            ),
            Meta(
              "LAST SYNC",
              lastUpdated == null ? "never" : waktuManusiawi(lastUpdated!),
            ),
            Meta("PRINTER", printer?.name ?? "not set"),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        /*
          Kepala halaman ini dan kepala daftar anggota dulu ditulis terpisah
          dengan susunan yang sama persis. Sekarang keduanya memanggil
          KepalaHalaman; lihat components/ui.
        */
        KepalaHalaman(
          penanda: storeModel == null ? "" : storeModel!.name.toUpperCase(),
          judul: "Store overview",
          keterangan: "Sales performance, registered members, and everything "
              "this terminal keeps in sync with the server.",
        ),
        const SizedBox(height: 6),
        Bagian(
          label: "STORE STATS",
          aksi: SizedBox(
            width: 210,
            child: Theme(
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
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                ),
                width: 0.4 * ResponsiveUtils.getContainerSize(context),
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
                        Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatCard(
                /* Kolom pertama: tidak ada yang perlu dipisahkan di kirinya. */
                pemisah: false,
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
        ),
        const SizedBox(
          height: 15,
        ),
        /*
          LAPORAN HARIAN, DIPINDAH DARI MENU SAMPING.

          Di menu ia satu-satunya butir yang tidak membuka halaman melainkan
          memunculkan dialog, jadi ia tidak pernah bisa tampil terpilih seperti
          tetangganya. Di sini ia berdiri sebagai tindakan, dan batang aksen di
          tepi kiri menandainya sebagai satu-satunya hal di halaman ini yang
          menghasilkan sesuatu untuk dibawa keluar.
        */
        /*
          SATU-SATUNYA kartu beraksen di halaman ini, dan itu disengaja:
          hanya ini yang menghasilkan sesuatu untuk dibawa keluar. Begitu ada
          dua yang beraksen, keduanya berhenti berarti.
        */
        Bagian(
          aksen: true,
          label: "DAILY REPORT",
          keterangan: "Everything sold today from this terminal, ready to "
              "read or send on.",
          /*
            Tenang, bukan terisi. Sesudah kotaknya dibuang, tombol berisi
            penuh menjadi satu-satunya bidang berwarna yang tersisa di
            halaman ini — lihat TombolBagian di components/ui.
          */
          aksi: TombolBagian(
            label: "Open report",
            ikon: Icons.summarize_outlined,
            onTekan: widget.onLaporanHarian,
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
        Bagian(
          label: "SYNC STOCK",
          keterangan: "Pulls the latest stock figures from the server. "
              "Needs an internet connection.",
          /*
            Tenang, bukan terisi. Sesudah kotaknya dibuang, tombol berisi
            penuh menjadi satu-satunya bidang berwarna yang tersisa di
            halaman ini — lihat TombolBagian di components/ui.
          */
          aksi: TombolBagian(
            label: "Sync now",
            ikon: Icons.sync_rounded,
            onTekan: () async {
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
        /*
          DUA KARTU BERSANDING MENJADI DUA BAGIAN SELEBAR PENUH.

          Menyandingkannya dulu memang menghemat gulungan, tetapi keduanya
          tetap kotak — dan begitu halaman ini berhenti memakai kotak, dua
          kotak yang tersisa justru menjadi satu-satunya yang berdinding.
          Melebar penuh, keduanya ikut irama bagian di atasnya, dan
          tindakannya berada di kanan barisan label seperti yang lain.
        */
        Consumer<ThemeNotifier>(
          builder: (_, value, __) => Bagian(
            label: "APPEARANCE",
            aksi: PilihanSegmen<ThemeMode>(
              terpilih: value.themeMode,
              opsi: const [
                OpsiSegmen(
                  nilai: ThemeMode.system,
                  label: "Follow system",
                  ikon: Icons.brightness_auto_outlined,
                ),
                OpsiSegmen(
                  nilai: ThemeMode.light,
                  label: "Light",
                  ikon: Icons.light_mode_outlined,
                ),
                OpsiSegmen(
                  nilai: ThemeMode.dark,
                  label: "Dark",
                  ikon: Icons.dark_mode_outlined,
                ),
              ],
              onPilih: (mode) => Provider.of<ThemeNotifier>(
                context,
                listen: false,
              ).setThemeMode(mode),
            ),
          ),
        ),
        Bagian(
          label: "RECEIPT PRINTER",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 15,
              ),
              if (printer == null) ...[
                /*
                                      Keterangan keadaan, bukan judul — dulu bodyLarge,
                                      seukuran isi utama, sehingga kalimat yang hanya
                                      memberi tahu bahwa pencetak belum dipilih tampil
                                      lebih besar daripada nama pencetak itu sendiri.
                                    */
                Text(
                  "No printer set. Printing is off until one is "
                  "chosen.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  height: 15,
                ),
                /*
                                      Bergaris, bukan terisi: memilih pencetak adalah persiapan
                                      sekali pasang, bukan tindakan utama halaman ini.
                                    */
                TombolBagian(
                  label: "Set printer",
                  ikon: Icons.print_outlined,
                  onTekan: () async {
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
                          prefs.setString("printer:name", selectedPrinter.name);
                        });
                      }
                    });
                  },
                ),
              ] else ...[
                /*
                                      Label kecil di atas, nama pencetak di bawahnya —
                                      sama seperti kolom lain di aplikasi ini. Dulu satu
                                      baris "Printer: EPSONC70AE8 (L14150 Series)"
                                      seukuran judul, yang membuat nama perangkat menjadi
                                      hal terbesar kedua di halaman setelan.
                                    */
                Text("CONNECTED", style: gayaLabelKolom(context)),
                const SizedBox(height: 4),
                Text(
                  printer!.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
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
                            prefs.setString("printer:url", selectedPrinter.url);
                            prefs.setString(
                                "printer:name", selectedPrinter.name);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Printer has been changed successfully"),
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
