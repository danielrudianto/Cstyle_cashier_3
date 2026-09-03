import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class CheckStockPage extends StatefulWidget {
  const CheckStockPage({super.key});

  @override
  State<CheckStockPage> createState() => _CheckStockPageState();
}

class _CheckStockPageState extends State<CheckStockPage> {
  GlobalKey flushBarKey = GlobalKey();

  Timer? _debounce;
  bool isLoading = true;
  int page = 1;
  String keyword = "";
  List<StoreModel> stores = [];
  List<ProductStockFetchItemModel> items = [];
  int count = 0;
  bool isDownloading = false;

  ScrollController controller = ScrollController();

  /// Baris matriks yang sedang berada di bawah penunjuk.
  ///
  /// Dipegang halaman, bukan tiap sel, karena satu baris digambar oleh
  /// delapan builder terpisah — judulnya satu, angkanya tujuh — dan
  /// kedelapannya harus menyala bersama supaya terbaca sebagai baris.
  ///
  /// ValueNotifier, BUKAN setState — dan itu bukan soal selera. Penyelaras
  /// gulir tabel lengketnya dibuat ulang pada setiap build dan lupa bahwa
  /// sebuah gestur sedang berlangsung, sehingga setState per gerakan mouse
  /// memutus ikatan kepala kolom dengan badannya persis selagi penunjuk ada
  /// di atas tabel. Dengan notifier, hover tidak membangun ulang apa pun
  /// kecuali sel yang berlangganan.
  final ValueNotifier<int?> _barisSorot = ValueNotifier(null);

  /// Dibuat SEKALI, bukan di build. Setiap pemanggilan ScrollControllers()
  /// melahirkan tiga pengendali baru untuk kepala kolom dan legenda; kalau
  /// lahir di build, setiap rebuild menukar pengendali yang sedang dipegang
  /// tampilan yang tengah digulirkan.
  late final ScrollControllers _kendaliGulir =
      ScrollControllers(verticalBodyController: controller);

  /*
    Ukuran sel disebut SEKALI. Pembungkus sorotnya harus mengisi penuh slot
    yang diberikan tabel, dan slot itu ditentukan CellDimensions — dua angka
    yang sama di dua tempat adalah dua tempat yang bisa berbeda.
  */
  static const double _lebarSel = 120;
  static const double _tinggiSel = 56;
  static const double _lebarLegenda = 280;
  TextEditingController searchController = TextEditingController();

  _fetchItems(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });

    StoreModel.getCurrentProfile().then((store) {
      ProductStockFetchModel.checkServerStock(page, searchController.text)
          .then((value) {
        ProductStockModel.fetchLocalStock(value.data.map((e) {
          return e.id;
        }).toList())
            .then((stocks) {
          List<ProductStockFetchItemModel> itemList = [];
          for (var e in value.data) {
            var stockIndex = stocks.indexWhere((x) => x.mongoID == e.id);
            var availableStocks = [
              ProductStockFetchStoreModel(
                storeID: store!.code,
                quantity: stockIndex == -1 ? 0 : stocks[stockIndex].stock,
              ),
            ];
            availableStocks.addAll(e.stock);

            itemList.add(
              ProductStockFetchItemModel(
                id: e.id,
                reference: e.reference,
                description: e.description,
                brand: e.brand,
                type: e.type,
                stock: availableStocks,
              ),
            );
          }

          List<StoreModel> finalStores = [
            StoreModel(
              name: store!.name,
              address: store.address,
              id: store.code,
            )
          ];
          finalStores.addAll(value.stores);

          setState(() {
            isLoading = false;
            stores = finalStores;
            items = itemList;
            count = value.count;
          });
        });
      }).catchError((error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future<List<int>?> _downloadStocks() async {
    var value = await ProductStockFetchModel.downloadServerStock();

    var excel = Excel.createExcel();
    for (var i = 0; i < value.stores.length; i++) {
      // create sheet
      var sheet =
          excel[value.stores[i].id == null ? "Office" : value.stores[i].name];

      // create header which consist of reference, description, brand, type, and stock
      /*
        Tanpa `const`. TextCellValue pada paket excel versi baru bukan lagi
        const constructor, jadi daftar ini tidak bisa lagi dinyatakan const.
      */
      sheet.appendRow([
        TextCellValue("Reference"),
        TextCellValue("Description"),
        TextCellValue("Brand"),
        TextCellValue("Type"),
        TextCellValue("Stock"),
      ]);

      // create rows
      for (var j = 0; j < value.data.length; j++) {
        var storeID = value.stores[i].id;
        var dataStockIndex = value.data[j].stock.indexWhere(
          (e) => e.storeID == storeID,
        );

        int quantity = dataStockIndex == -1
            ? 0
            : value.data[j].stock[dataStockIndex].quantity;

        sheet.appendRow([
          TextCellValue(value.data[j].reference),
          TextCellValue(value.data[j].description),
          TextCellValue(value.data[j].brand),
          TextCellValue(value.data[j].type),
          TextCellValue(quantity.toString()),
        ]);

        CellStyle style = CellStyle(numberFormat: NumFormat.standard_1);
        var cell = sheet.cell(CellIndex.indexByString('E${j + 2}'));
        cell.value = IntCellValue(quantity);
        cell.cellStyle = style;

        // make the column A to D to be auto fit
        sheet.setColumnAutoFit(0);
        sheet.setColumnAutoFit(1);
        sheet.setColumnAutoFit(2);
        sheet.setColumnAutoFit(3);
      }
    }

    return excel.encode();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchItems(1);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _barisSorot.dispose();
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _fetchItems(1);
    // controller.addListener(() {
    //   // debounce 500ms
    //   if (_debounce?.isActive ?? false) _debounce?.cancel();
    //   _debounce = Timer(const Duration(milliseconds: 500), () {
    //     _fetchItems(1);
    //   });
    // });
    super.initState();
  }

  /// Mengunduh matriks stok sebagai berkas Excel ke folder Downloads.
  void _unduhExcel() {
    setState(() {
      isDownloading = true;
    });
    _downloadStocks().then((value) async {
      try {
        Directory? directory = await getDownloadsDirectory();
        if (directory != null) {
          String filePath =
              "${directory.path}/stock_${DateTime.now().microsecondsSinceEpoch.toString()}.xlsx";
          if (value == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Failed to build the Excel file"),
            ));
          } else {
            File(filePath)
              ..createSync(recursive: false)
              ..writeAsBytesSync(value);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Stock saved to your Downloads folder."),
            ));

            LoggerUtils()
                .log("Stock card downloaded successfully.", LogType.info);
          }
        }
      } catch (error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }).whenComplete(() {
      if (!mounted) return;
      setState(() {
        isDownloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    /*
      Matriks lengketnya butuh tinggi terpagar — ia menggulir dua arah di
      dalam dirinya sendiri, jadi tidak bisa dibiarkan setinggi isinya seperti
      tabel biasa. Diambil dari tinggi layar dengan lantai 360 supaya layar
      pendek tidak meremasnya jadi celah.
    */
    final tinggiMatriks = max(360.0, MediaQuery.sizeOf(context).height - 380);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        const KepalaHalaman(
          penanda: "INVENTORY",
          judul: "Stock",
          keterangan: "How much of each product every store is holding "
              "right now.",
        ),
        Bagian(
          atas: 34,
          label: count == 0
              ? "PRODUCTS"
              : "PRODUCTS · ${NumberFormat.decimalPattern("en-US").format(count)}",
          aksi: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurface,
                  ),
                  decoration: dekorasiIsian(
                    context,
                    petunjuk: "Search products",
                    awalan: const Icon(Icons.search, size: 19),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TombolBagian(
                label: "Download Excel",
                ikon: Icons.download_rounded,
                memuat: isDownloading,
                onTekan: _unduhExcel,
              ),
            ],
          ),
          child: SizedBox(
            height: tinggiMatriks,
            child: AnimatedSwitcher(
              duration: Gerak.cepat,
              switchInCurve: Gerak.masuk,
              switchOutCurve: Gerak.keluar,
              child: isLoading
                  ? const Center(
                      key: ValueKey("memuat"),
                      child: CircularProgressIndicator(),
                    )
                  : items.isEmpty
                      ? Center(
                          key: const ValueKey("kosong"),
                          child: Text(
                            searchController.text.trim().isEmpty
                                ? "No products to show."
                                : "No product matches "
                                    "\u201C${searchController.text.trim()}\u201D.",
                            style: tema.textTheme.bodyMedium,
                          ),
                        )
                      : _matriks(context),
            ),
          ),
        ),
        const SizedBox(height: 6),
        PaginationComponent(
            pageIndex: page - 1,
            dataCount: count,
            pageSize: 20,
            onPageChange: (value) {
              page = value + 1;
              _fetchItems(page);
              controller.jumpTo(0);
            }),
      ],
    );
  }

  /// Satu sel matriks yang ikut menyala saat barisnya disorot.
  ///
  /// Mengisi penuh slot selnya — sorot yang hanya selebar tulisannya membuat
  /// barisnya menyala bolong-bolong.
  Widget _selBaris({
    required int baris,
    required double lebar,
    required Widget anak,
    AlignmentGeometry rata = Alignment.center,
    EdgeInsetsGeometry? bantalan,
  }) {
    final sorotan = Theme.of(context).colorScheme.onSurface.withValues(
          alpha: 0.05,
        );
    return MouseRegion(
      onEnter: (_) => _barisSorot.value = baris,
      onExit: (_) {
        if (_barisSorot.value == baris) _barisSorot.value = null;
      },
      child: ValueListenableBuilder<int?>(
        valueListenable: _barisSorot,
        builder: (context, sorot, anakTetap) {
          return AnimatedContainer(
            duration: Gerak.kilat,
            curve: Gerak.masuk,
            width: lebar,
            height: _tinggiSel,
            alignment: rata,
            padding: bantalan,
            color: sorot == baris ? sorotan : Colors.transparent,
            child: anakTetap,
          );
        },
        child: anak,
      ),
    );
  }

  Widget _matriks(BuildContext context) {
    final tema = Theme.of(context);

    /*
      SCROLLBAR-NYA DULU DOBEL.

      Paket tabel ini menggambar Scrollbar Material-nya sendiri, dan perilaku
      gulir bawaan desktop menyuntikkan scrollbar SATU LAGI pada scrollable
      yang sama — dua batang berdampingan untuk satu gerakan. Suntikan
      platformnya dimatikan di sini, dan yang milik paket digayakan lewat
      ScrollbarTheme supaya serupa dengan penggulir halaman kelola.
    */
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Theme(
        data: tema.copyWith(
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(8),
            thickness: const WidgetStatePropertyAll(6),
            crossAxisMargin: 2,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => tema.secondaryHeaderColor.withValues(
                alpha: states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.dragged)
                    ? 0.75
                    : 0.45,
              ),
            ),
          ),
        ),
        child: StickyHeadersTable(
          key: ValueKey("hal$page"),
          /*
            Muncul HANYA saat menggulir. Saat selalu tampak, thumb horizontal
            membentang nyaris selebar tabel begitu isinya muat di layar —
            dan batang sepanjang itu tidak terbaca sebagai scrollbar,
            melainkan sebagai palang tebal di bawah kepala kolom.
          */
          showVerticalScrollbar: false,
          showHorizontalScrollbar: false,
          scrollControllers: _kendaliGulir,
          cellAlignments: const CellAlignments.fixed(
            contentCellAlignment: Alignment.center,
            stickyLegendAlignment: Alignment.centerLeft,
            stickyColumnAlignment: Alignment.centerLeft,
            stickyRowAlignment: Alignment.center,
          ),
          /*
        Tinggi sel diturunkan dari 100 ke 56. Seratus piksel untuk satu angka
        membuat lima barang memenuhi layar; matriks stok gunanya justru
        MEMBANDINGKAN, dan membandingkan butuh banyak baris terlihat
        sekaligus.
      */
          cellDimensions: const CellDimensions.fixed(
            contentCellWidth: _lebarSel,
            contentCellHeight: _tinggiSel,
            stickyLegendWidth: _lebarLegenda,
            stickyLegendHeight: 44,
          ),
          columnsLength: stores.length,
          legendCell: Text("PRODUCT", style: gayaKode(context)),
          columnsTitleBuilder: (i) {
            /*
          Kata pertama semua toko sama — "CSTYLE" — jadi yang ditampilkan
          justru sisanya, bagian yang membedakan. Kantor pusat tidak
          berawalan itu dan lewat apa adanya.
        */
            final kata = stores[i].name.split(" ");
            final label =
                kata.length > 1 && kata.first.toUpperCase() == "CSTYLE"
                    ? kata.skip(1).join(" ")
                    : stores[i].name;
            return Text(
              label.toUpperCase(),
              style: gayaKode(context),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          },
          rowsLength: items.length,
          rowsTitleBuilder: (rowIndex) {
            return _selBaris(
              baris: rowIndex,
              lebar: _lebarLegenda,
              rata: Alignment.centerLeft,
              bantalan: const EdgeInsets.only(right: 14),
              anak: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(items[rowIndex].reference, style: gayaKode(context)),
                  const SizedBox(height: 2),
                  Text(
                    items[rowIndex].description,
                    style: tema.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          contentCellBuilder: (i, j) {
            var storeID = stores[i].id;
            var dataStockIndex =
                items[j].stock.indexWhere((e) => e.storeID == storeID);
            final jumlah = dataStockIndex == -1
                ? 0
                : items[j].stock[dataStockIndex].quantity;

            /*
          Nol diredupkan, bukan disembunyikan dan bukan diwarnai bahaya:
          pada matriks berisi ratusan sel, nol adalah keadaan paling umum,
          dan yang perlu menonjol justru angka yang ADA.
        */
            return _selBaris(
              baris: j,
              lebar: _lebarSel,
              anak: Text(
                NumberFormat.decimalPattern("en-US").format(jumlah),
                style: gayaKode(context, ukuran: 12).copyWith(
                  color: jumlah == 0
                      ? tema.colorScheme.onSurface.withValues(alpha: 0.3)
                      : tema.colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
