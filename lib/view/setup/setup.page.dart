import 'package:cstyle_cashier_3/components/brand-backdrop/brand-backdrop.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/utils/sync.utils.dart';
import 'package:flutter/material.dart';

/// Layar penyiapan: mengikat satu terminal ke satu toko.
///
/// Dijalankan sekali saja seumur pemasangan, tetapi ia adalah layar PERTAMA
/// yang dilihat orang, dan sebelum ini ada dua hal yang membuatnya nyaris
/// tidak dapat dipakai.
///
/// SATU: TULISAN PUTIH DI ATAS PUTIH.
///
/// Kolom isian memakai `fillColor: Colors.white`, sementara warna tulisannya
/// diambil dari `textTheme.bodyLarge` — yang di tema gelap berwarna PUTIH.
/// Bawaan aplikasi ini ThemeMode.system, jadi pada Windows bertema gelap
/// petunjuk "Store Code" tidak terlihat DAN yang diketik pun tidak terlihat.
/// Kolomnya tampak kosong melompong, dan tidak ada cara menebak apa yang
/// sedang terjadi.
///
/// Sekarang isian berada di atas kartu bertema, dan warna tulisan maupun
/// petunjuknya disebut secara eksplisit dari skema warna — bukan diwarisi.
///
/// DUA: KEGAGALAN YANG TIDAK PERNAH SAMPAI KE LAYAR.
///
/// _validateStore() memasang .catchError() di tiga tingkat, dan ketiganya
/// hanya menulis ke berkas log. Kode toko salah, jaringan mati, server
/// menolak — semuanya menghasilkan hal yang sama persis: tombol ditekan, lalu
/// tidak terjadi apa-apa. Tidak ada pesan, tidak ada perubahan, tidak ada
/// petunjuk untuk mencoba apa berikutnya.
///
/// Sekarang rantai .then() itu menjadi await, galatnya ditampilkan di kartu,
/// dan tombolnya menunjukkan bahwa ia sedang bekerja.
class SetupStorePage extends StatefulWidget {
  const SetupStorePage({super.key});

  @override
  State<SetupStorePage> createState() => _SetupStorePageState();
}

class _SetupStorePageState extends State<SetupStorePage> {
  final _kunciForm = GlobalKey<FormState>();
  final TextEditingController _kodeToko = TextEditingController();

  bool _sedangMemeriksa = false;
  String? _galat;

  @override
  void dispose() {
    /*
      Dulu tidak ada dispose. Controller yang tidak dilepas menahan listener
      dan menjadi bocoran memori setiap kali layar ini dibuka.
    */
    _kodeToko.dispose();
    super.dispose();
  }

  /// Kode toko yang sudah dibersihkan: tanpa tanda hubung, tanpa spasi.
  ///
  /// Di database `stores.code` tersimpan sebagai UUID bertanda hubung,
  /// sedangkan aplikasi dan endpoint /cashier/stores/:kode sama-sama
  /// mensyaratkan 32 heksadesimal TANPA tanda hubung — server menyusun ulang
  /// tanda hubungnya sendiri sebelum mencari.
  ///
  /// Menyalin nilai itu apa adanya dari database adalah hal paling wajar yang
  /// dilakukan orang, dan dulu hasilnya ditolak tanpa penjelasan. Sekarang
  /// keduanya diterima.
  String get _kodeBersih =>
      _kodeToko.text.replaceAll("-", "").replaceAll(" ", "").trim();

  static final RegExp _polaKode = RegExp(r"^[0-9a-fA-F]{32}$");

  Future<void> _validateStore() async {
    if (_sedangMemeriksa) return;
    if (!(_kunciForm.currentState?.validate() ?? false)) return;

    setState(() {
      _sedangMemeriksa = true;
      _galat = null;
    });

    try {
      final toko = await StoreModel.checkStoreUID(_kodeBersih);

      LoggerUtils()
          .log("Store found, applying to local database", LogType.info);

      await StoreModel(
        id: toko.id,
        address: toko.address,
        name: toko.name,
        code: toko.code,
        phoneNumber: toko.phoneNumber,
      ).create();

      LoggerUtils().log("Fetching stock from server", LogType.info);

      final stok = await ProductStockModel.fetchServerStock(toko.code!);
      await ProductStockModel.updateServerStock(stok);

      LoggerUtils().log("Stock updated", LogType.info);
      SyncUtils.sync();

      router.replace("/main");
    } catch (error, jejak) {
      LoggerUtils().log(
        "Gagal menyiapkan toko",
        LogType.error,
        error: error,
        stackTrace: jejak,
      );

      if (!mounted) return;
      setState(() {
        _galat =
            "Could not activate this terminal. Check the store code and your "
            "connection, then try again.";
      });
    } finally {
      if (mounted) {
        setState(() => _sedangMemeriksa = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return BrandBackdrop(
      child: ConstrainedBox(
        /*
          Lebarnya dibatasi, bukan dibuat pecahan dari lebar layar. Satu kolom
          kode toko tidak menjadi lebih mudah diisi karena membentang sembilan
          ratus piksel di monitor kasir.
        */
        constraints: const BoxConstraints(maxWidth: 380),
        child: Card(
          color: tema.cardColor,
          elevation: 8,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            child: Form(
              key: _kunciForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Activate this terminal",
                    style: tema.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Paste the store code for the till this computer "
                    "belongs to. Dashes are fine. It is set once and "
                    "remembered.",
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _kodeToko,
                    autofocus: true,
                    enabled: !_sedangMemeriksa,
                    textInputAction: TextInputAction.go,
                    /*
                      Warna tulisan disebut eksplisit dari skema warna. Inilah
                      perbaikan putih-di-atas-putih: mewarisi bodyLarge membuat
                      isian ini tidak terbaca di tema gelap.
                    */
                    style: tema.textTheme.bodyLarge?.copyWith(
                      color: warna.onSurface,
                      letterSpacing: 1.1,
                    ),
                    decoration: InputDecoration(
                      labelText: "Store code",
                      hintText: "32 characters",
                      hintStyle: TextStyle(
                        color: warna.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 1.1,
                      ),
                      filled: true,
                      fillColor: warna.onSurface.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                    ),
                    validator: (_) {
                      /*
                        Format diperiksa DI SINI, bukan dibiarkan gagal di
                        server. Kode yang panjangnya salah selalu ditolak, jadi
                        mengirimkannya lebih dulu hanya menukar pesan yang tepat
                        dengan pesan umum "gagal mengaktifkan" sesudah menunggu
                        satu perjalanan jaringan.
                      */
                      if (_kodeBersih.isEmpty) {
                        return "Enter a store code";
                      }
                      if (!_polaKode.hasMatch(_kodeBersih)) {
                        return "That is not a store code. It is 32 letters and "
                            "numbers, with or without dashes.";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _validateStore(),
                  ),
                  /*
                    Ruang galat hanya muncul saat ada galat. Menyediakannya
                    permanen membuat kartunya bercelah tanpa sebab; menyisipkan
                    saat perlu membuat kartunya sedikit memanjang, dan gerakan
                    itu sendiri sudah menjadi tanda bahwa ada yang berubah.
                  */
                  AnimatedSize(
                    duration: Gerak.cepat,
                    curve: Gerak.masuk,
                    child: _galat == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: warna.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _galat!,
                                    style: tema.textTheme.bodySmall?.copyWith(
                                      color: warna.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _sedangMemeriksa ? null : _validateStore,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    /*
                      Tombolnya menunjukkan bahwa ia sedang bekerja. Sebelumnya
                      pemeriksaan berjalan tanpa satu pun tanda, jadi menekan
                      dua kali karena mengira tidak tertekan adalah reaksi yang
                      wajar — dan itu menjalankan penyiapan dua kali.
                    */
                    child: _sedangMemeriksa
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: warna.onPrimary,
                            ),
                          )
                        : const Text("Activate"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
