import 'package:cstyle_cashier_3/model/model.product-image.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/components/product-image.component.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardGridList extends StatelessWidget {
  final List<ProductModel> products;
  final Function onAddProduct;

  /// Pengendali gulir milik halaman induk, yang juga memakainya untuk memuat
  /// halaman berikutnya saat sampai di bawah.
  final ScrollController controller;
  const DashboardGridList({
    required this.controller,
    super.key,
    required this.products,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    showProductDialog(
        ProductModel e, List<ProductImageModel> images, int stock) {
      showDialog(
          context: context,
          builder: (context) {
            final tema = Theme.of(context);
            final warna = tema.colorScheme;
            final habis = stock <= 0;

            /*
              DIALOG INI DULU BERTINGGI TETAP 250 PIKSEL.

              Isinya tidak pernah muat, jadi ia menggulir di dalam kotak sempit
              dan kode referensi di barisnya yang paling atas terpotong separuh.
              Sekarang tingginya mengikuti isinya, dengan batas atas supaya
              barang bernama panjang pun tidak memenuhi layar.

              Dua baris terakhirnya — "100% Original Products" dan "Pay on
              delivery" — dibuang. Keduanya kalimat toko daring pada aplikasi
              kasir tempat orang berdiri di depan meja; yang kedua bahkan tidak
              benar, tidak ada pengiriman di sini.

              Dan tombolnya dulu berbunyi "Available" / "Not Available".
              Itu KEADAAN, bukan tindakan — tombol seharusnya menyebut apa yang
              terjadi kalau ditekan. Lebih buruk lagi: saat stok nol ia hanya
              berganti warna, onTap-nya tetap berjalan, jadi barang habis tetap
              bisa masuk keranjang. Sekarang keadaannya ditulis terpisah sebagai
              keterangan, dan tombolnya benar-benar mati ketika habis.
            */
            return Dialog(
              backgroundColor: tema.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: images.isEmpty ? 380 : 620,
                  maxHeight: 460,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty) ...[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProductImageComponent(
                              id: e.id,
                              autoPlay: true,
                              bordered: false,
                              static: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(e.reference, style: gayaLabelKolom(context)),
                            const SizedBox(height: 6),
                            Text(
                              e.description,
                              style: tema.textTheme.headlineSmall?.copyWith(
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.brand,
                              style: tema.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              /*
                                Tanpa ",00". Rupiah tidak dipakai dalam sen di
                                meja kasir, dan dua angka nol yang selalu sama
                                hanya membuat harganya lebih lambat dibaca.
                              */
                              "Rp ${NumberFormat("#,##0").format(e.price)}",
                              style: tema.textTheme.headlineMedium?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            /*
                              Keadaan stok ditulis di sini, terpisah dari
                              tombol — dan angkanya disebut, bukan cuma
                              "Available". Berapa sisanya menentukan apakah
                              kasir menawarkan dua atau menahan yang terakhir.
                            */
                            Row(
                              children: [
                                Icon(
                                  habis
                                      ? Icons.remove_shopping_cart_outlined
                                      : Icons.inventory_2_outlined,
                                  size: 16,
                                  color: habis
                                      ? warna.error
                                      : warnaPeringatan(context),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  habis ? "Out of stock" : "$stock in stock",
                                  style: tema.textTheme.bodySmall?.copyWith(
                                    color: habis ? warna.error : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed:
                                    habis ? null : () => router.pop("add"),
                                icon: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 18,
                                ),
                                label: const Text("Add to cart"),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).then((value) {
        if (value == 'add') {
          onAddProduct(e);
        }
      });
    }

    /*
      ListView.builder, BUKAN Column DI DALAM SingleChildScrollView.

      Bentuk lama membangun SELURUH baris sekaligus. Halaman ini memuat 25
      barang per permintaan dan menambahkannya saat digulir, jadi setelah
      beberapa gulungan `products` berisi ratusan — dan setiap satu di antaranya
      menjadi widget hidup, lengkap dengan kotak centang, tombol ikon, dan
      pemformat angka, biar pun berada jauh di luar layar.

      Yang membuatnya terasa saat menambah barang ke keranjang: Consumer2 di
      bawah ini membungkus seluruh daftar, jadi satu perubahan keranjang
      membangun ulang SEMUA baris itu. Satu klik, ratusan baris disusun ulang.

      Dengan itemBuilder, yang dibangun hanya yang terlihat — belasan, bukan
      ratusan. Consumer2-nya tetap di sini, tetapi sekarang yang ia bangun ulang
      juga hanya yang terlihat.
    */
    return Consumer2<CompareNotifier, CartNotifier>(
      builder: (_, compareNotifier, cartNotifier, child) {
        return ListView.builder(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final e = products[index];
            /*
              Stok yang benar-benar bisa dijual: stok gudang dikurangi yang
              sudah masuk keranjang tapi belum dibayar.
            */
            final tersedia =
                (e.stock ?? 0) - cartNotifier.checkProductQuantity(e.id);

            /*
              SorotBerlatar DIBUANG DARI SINI.

              Ia memasang satu MouseRegion dan satu AnimatedContainer PER
              BARIS, dan tiap baris memanggil setState saat kursor masuk dan
              keluar. Daftar ini dibangun seluruhnya sekaligus di dalam sebuah
              Column — bukan ListView yang mendaur ulang barisnya — jadi
              biayanya bukan satu widget melainkan sebanyak barang yang sedang
              ditampilkan, dan menggeser kursor menyeberangi daftar memicu
              serentetan rebuild. Itu yang membuatnya terasa berat.

              InkWell yang memang sudah ada di sini punya keadaan sorot sendiri
              yang ditangani lapisan Material — satu lapisan lukis untuk seluruh
              daftar, tanpa widget tambahan dan tanpa setState per baris.
              Hasilnya sama, ongkosnya tidak.
            */
            return InkWell(
              hoverColor: Theme.of(context)
                  .secondaryHeaderColor
                  .withValues(alpha: 0.07),
              onTap:
                  ((e.stock ?? 0) - cartNotifier.checkProductQuantity(e.id)) <=
                          0
                      ? () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Insufficient stock. If you have reported this issue and adjustment has been made, please go to setting and override manually.",
                              ),
                              action: SnackBarAction(
                                label: "OK",
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                        }
                      : () {
                          onAddProduct(e);
                        },
              child: Container(
                /*
                    Tidak ada lagi garis di bawah tiap baris.

                    Seberapa pun tipisnya, dua belas baris berarti dua belas
                    garis sejajar, dan mata membacanya sebagai kisi — bukan
                    sebagai daftar. Pemisahnya sekarang jarak dan pengelompokan:
                    kode referensi kecil menempel di atas nama barangnya, lalu
                    ruang kosong di antara pasangan itu. Garis hanya dipertahankan
                    di tempat yang memang menandai batas, yaitu di bawah kepala
                    kolom.
                  */
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Checkbox(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: compareNotifier.hasProduct(e.id),
                        onChanged: (value) {
                          LoggerUtils().log(
                              "User has change ${e.id} to $value. Prepared to be compared.",
                              LogType.info);

                          if (value != null && value == false) {
                            Provider.of<CompareNotifier>(context, listen: false)
                                .deselectProduct(e.id);
                          } else if (value != null && value == true) {
                            Provider.of<CompareNotifier>(context, listen: false)
                                .selectProduct(e);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e.reference,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            e.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            /*
                                Nama barang adalah yang dibaca paling sering di
                                layar ini, jadi ia yang memimpin barisnya —
                                setengah tingkat di atas angka, dan lebih tebal.
                                Ukurannya sengaja tidak dinaikkan lebih jauh
                                supaya tinggi barisnya tidak bertambah.
                              */
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        NumberFormat.decimalPattern("en-US").format(e.price),
                        textAlign: TextAlign.end,
                        /*
                            Angka selebar sama. Ini kolom angka bersusun; pada
                            huruf biasa "1" jauh lebih sempit daripada "8", jadi
                            satuan dan ribuannya tidak pernah berbaris lurus.
                          */
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    /*
                      STOK SEBAGAI KEADAAN, BUKAN SEKADAR ANGKA.

                      Sebelumnya "0" tampil persis sama dengan "9" — warna,
                      berat, dan ukuran yang sama — padahal keduanya berarti
                      hal yang sangat berbeda di meja kasir. Yang satu tidak
                      bisa dijual sama sekali; yang lain aman. Kasir harus
                      MEMBACA angkanya untuk tahu bedanya, dan itu berarti
                      memeriksa satu per satu setiap kali menyusuri daftar.

                      Sekarang bedanya terlihat sebelum angkanya dibaca:
                      habis memakai warna galat dan tulisan "Out", menipis
                      (tiga ke bawah) memakai warna peringatan, sisanya diam.

                      Batas tiga dipilih karena itu jumlah yang masih mungkin
                      terjual habis dalam satu transaksi.
                    */
                    Expanded(
                      flex: 5,
                      child: Text(
                        tersedia <= 0
                            ? "Out"
                            : NumberFormat.decimalPattern("en-US")
                                .format(tersedia),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight:
                              tersedia <= 3 ? FontWeight.w700 : FontWeight.w400,
                          color: tersedia <= 0
                              ? Theme.of(context).colorScheme.error
                              : tersedia <= 3
                                  ? warnaPeringatan(context)
                                  : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () async {
                          List<ProductImageModel> images =
                              await ProductImageModel.fetchByItemID(e.id);
                          showProductDialog(
                              e,
                              images,
                              (e.stock ?? 0) -
                                  cartNotifier.checkProductQuantity(e.id));
                        },
                        tooltip: "Product photos",
                        icon: const Icon(Icons.view_array),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
