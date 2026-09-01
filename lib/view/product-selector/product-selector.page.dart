import 'dart:async';
import 'dart:math';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Memilih barang yang akan diminta pada sebuah transfer.
///
/// APA YANG TIDAK DIKATAKAN OLEH BENTUK SEBELUMNYA.
///
/// Yang dipilih di sini BERTAHAN saat halaman berganti — pilih dua di halaman
/// satu, tiga di halaman empat, dan kelimanya ikut terbawa. Tetapi tidak ada
/// satu pun tulisan di layar yang menyebut itu. Satu-satunya petunjuk bahwa
/// sesuatu sudah terpilih adalah ikon centang pada barisnya sendiri, yang
/// hilang begitu halamannya berganti. Jadi jumlah terpilih sekarang tertulis
/// di kaki dialog dan ikut pada tombolnya: ia tidak berubah saat berpindah
/// halaman, dan justru di situlah gunanya.
///
/// Penanda pilihannya juga berganti. Dulu lingkaran ungu pekat berisi tanda
/// TAMBAH, dan lingkaran itu tetap ungu pekat baik barangnya sudah terpilih
/// maupun belum — hanya isinya yang berubah dari + menjadi ✓. Dua keadaan yang
/// berlawanan digambarkan dengan bidang warna yang sama besar dan sama
/// mencoloknya. Sekarang yang belum terpilih hanya bergaris tipis, dan warna
/// pekat disediakan untuk yang sudah.
///
/// Sisa stok ikut diberi warna. Meminta barang yang stok pengirimnya nol adalah
/// permintaan yang pasti gagal, dan itu layak terlihat sebelum dikirim, bukan
/// sesudah.
class ProductSelectorPage extends StatefulWidget {
  final String? storeID;
  final List<dynamic> selectedItems;
  final Function closeDialog;

  const ProductSelectorPage({
    super.key,
    this.storeID,
    required this.selectedItems,
    required this.closeDialog,
  });

  @override
  State<ProductSelectorPage> createState() => _ProductSelectorPageState();
}

class _ProductSelectorPageState extends State<ProductSelectorPage> {
  bool isLoading = false;
  List<ProductModel> products = [];
  int page = 1;
  int productCount = 0;
  List<dynamic> selectedItems = [];

  TextEditingController searchController = TextEditingController();
  Timer? debounceTime;

  fetchProducts(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });
    ProductModel.fetchServerProducts(
      page,
      widget.storeID,
      searchController.text,
    ).timeout(const Duration(seconds: 5), onTimeout: () {
      // Handle timeout
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out')),
      );
      return null;
    }).then((value) {
      if (value != null && value['data'] != null) {
        setState(() {
          products = value['data'];
          productCount = value['count'];
        });
      } else {
        // Handle case where value is null or doesn't contain data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products found')),
        );
      }
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return null;
    }).whenComplete(() {
      /*
        Dialognya bisa ditutup selagi permintaannya masih di jalan. Tanpa
        penjagaan ini, setState dipanggil pada kerangka yang sudah dilepas.
      */
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    fetchProducts(1);

    searchController.addListener(() {
      if (debounceTime != null) {
        debounceTime!.cancel();
      }
      debounceTime = Timer(const Duration(milliseconds: 500), () {
        fetchProducts(1);
      });
    });

    selectedItems = widget.selectedItems;

    super.initState();
  }

  @override
  void dispose() {
    debounceTime?.cancel();
    searchController.dispose();
    super.dispose();
  }

  bool _terpilih(ProductModel produk) {
    return selectedItems.any((e) => e['id'] == produk.id);
  }

  void _alihkan(ProductModel produk) {
    setState(() {
      if (_terpilih(produk)) {
        selectedItems.removeWhere((e) => e['id'] == produk.id);
      } else {
        selectedItems.add({
          "id": produk.id,
          "reference": produk.reference,
          "description": produk.description,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final jumlah = selectedItems.length;

    return Container(
      width: 820,
      /*
        Tingginya dibatasi layar. Angka tetap 500 memaksa daftar dua puluh
        barang menggulir di dalam kotak yang tinggal separuh layar, dan pada
        layar yang lebih pendek dari itu justru meluber.
      */
      height: min(620, MediaQuery.sizeOf(context).height - 120),
      decoration: BoxDecoration(
        color: tema.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Add products",
                      style: tema.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () => widget.closeDialog(null),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                "Search by code or name. What you pick is kept as you move "
                "between pages.",
                style: tema.textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: TextField(
                controller: searchController,
                decoration: dekorasiIsian(
                  context,
                  petunjuk: "Search products",
                  awalan: const Icon(Icons.search, size: 19),
                ),
              ),
            ),
            Divider(height: 1, color: tema.dividerColor),
            Expanded(
              child: _isi(context),
            ),
            Divider(height: 1, color: tema.dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: PaginationComponent(
                      pageIndex: page - 1,
                      dataCount: productCount,
                      pageSize: 20,
                      onPageChange: (value) {
                        fetchProducts(value + 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  /*
                    Jumlah terpilih ditulis di sini karena inilah satu-satunya
                    angka yang tidak ikut berubah saat halaman berganti.
                  */
                  Text(
                    jumlah == 0 ? "Nothing selected" : "$jumlah selected",
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 14),
                  FilledButton(
                    onPressed: () => widget.closeDialog(selectedItems),
                    child: const Text("Apply selection"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _isi(BuildContext context) {
    final tema = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      /*
        Keadaan kosong menyebutkan APA yang dicari. "No products found" saja
        membuat orang menebak apakah katanya salah ketik atau memang tidak ada.
      */
      final kata = searchController.text.trim();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            kata.isEmpty
                ? "No products in this store yet."
                : "No product matches “$kata”.",
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: products.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 62,
        endIndent: 20,
        color: tema.dividerColor,
      ),
      itemBuilder: (context, index) {
        final produk = products[index];
        return _BarisProduk(
          kode: produk.reference,
          nama: produk.description,
          stok: produk.stock,
          terpilih: _terpilih(produk),
          onAlih: () => _alihkan(produk),
        );
      },
    );
  }
}

/// Satu barang pada daftar pemilih.
class _BarisProduk extends StatefulWidget {
  final String kode;
  final String nama;
  final int? stok;
  final bool terpilih;
  final VoidCallback onAlih;

  const _BarisProduk({
    required this.kode,
    required this.nama,
    required this.stok,
    required this.terpilih,
    required this.onAlih,
  });

  @override
  State<_BarisProduk> createState() => _BarisProdukState();
}

class _BarisProdukState extends State<_BarisProduk> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.onAlih,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          padding: const EdgeInsets.fromLTRB(24, 12, 20, 12),
          color: _disorot
              ? warna.onSurface.withValues(alpha: 0.04)
              : Colors.transparent,
          child: Row(
            children: [
              _Tanda(terpilih: widget.terpilih, disorot: _disorot),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.kode, style: gayaKode(context)),
                    const SizedBox(height: 3),
                    Text(
                      widget.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _Stok(jumlah: widget.stok),
            ],
          ),
        ),
      ),
    );
  }
}

/// Penanda terpilih atau belum.
class _Tanda extends StatelessWidget {
  final bool terpilih;
  final bool disorot;

  const _Tanda({required this.terpilih, required this.disorot});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: Gerak.kilat,
      curve: Gerak.masuk,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: terpilih ? warna.primary : Colors.transparent,
        border: Border.all(
          color: terpilih
              ? warna.primary
              : warna.onSurface.withValues(alpha: disorot ? 0.5 : 0.3),
          width: 1.4,
        ),
      ),
      child: terpilih
          ? Icon(Icons.check_rounded, size: 14, color: diAtasAksen(context))
          : null,
    );
  }
}

/// Sisa stok pada toko pengirim.
class _Stok extends StatelessWidget {
  final int? jumlah;

  const _Stok({required this.jumlah});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final n = jumlah ?? 0;

    /*
      Nol berarti permintaannya tidak akan bisa dipenuhi, dan sedikit berarti
      mungkin tidak seluruhnya. Keduanya lebih berguna diketahui sekarang
      daripada sesudah transfernya dikirim.
    */
    final Color warna = n <= 0
        ? tema.colorScheme.error
        : n <= 3
            ? warnaPeringatan(context)
            : tema.colorScheme.onSurface.withValues(alpha: 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "IN STOCK",
          style: gayaLabelKolom(context)?.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 3),
        Text(
          n <= 0 ? "None" : NumberFormat.decimalPattern().format(n),
          style: gayaKode(context, ukuran: 13).copyWith(color: warna),
        ),
      ],
    );
  }
}
