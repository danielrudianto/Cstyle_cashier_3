import 'package:flutter/material.dart';

/// Latar bermerek untuk dua layar pertama: splash dan penyiapan toko.
///
/// KENAPA WARNANYA TETAP, TIDAK IKUT TEMA.
///
/// Kedua layar ini muncul sebelum ada yang bisa dikerjakan — sebelum toko
/// dikenali, bahkan sebelum basis data siap. Di situ yang dibutuhkan bukan
/// permukaan kerja melainkan tanda pengenal, dan tanda pengenal yang berubah
/// warna mengikuti setelan Windows justru kehilangan gunanya.
///
/// Karena itu warnanya dikunci gelap, dan seluruh tulisan di atasnya putih.
/// Yang penting: apa pun yang ditaruh di [child] harus membawa permukaannya
/// sendiri — kartu bertema — supaya isian dan tombol tetap benar di terang
/// maupun gelap. Menaruh widget bertema langsung di atas latar ini adalah cara
/// paling mudah menghasilkan tulisan putih di atas putih.
///
/// DULU WARNA TUNGGAL 161,121,220.
///
/// Ungu muda yang sama rata memenuhi seluruh layar, tanpa arah dan tanpa
/// kedalaman. Gradien di bawah bergerak dari ungu yang jauh lebih gelap di
/// atas ke ungu merek di bawah; bedanya tipis, dan justru itu maksudnya —
/// cukup untuk memberi bidang itu sumbu, tidak cukup untuk menarik perhatian.
class BrandBackdrop extends StatelessWidget {
  /// Isi utama, ditaruh di bawah lockup merek.
  final Widget child;

  /// Versi aplikasi, ditampilkan kecil di bawah nama.
  final String versi;

  const BrandBackdrop({
    super.key,
    required this.child,
    this.versi = versiAplikasi,
  });

  /// Versi yang ditampilkan di layar pembuka.
  ///
  /// Harus sejalan dengan `msix_version` di pubspec.yaml. Dulu ditulis
  /// langsung di dalam hero.page.dart, jadi ia diam-diam basi setiap kali
  /// versinya naik tanpa ada yang ingat menyuntingnya.
  static const String versiAplikasi = "3.0.9.1";

  /// Ungu merek, gelap. Sama dengan aksenCstyle di utils/theme.utils.dart.
  static const Color _bawah = Color.fromARGB(255, 109, 78, 137);

  /// Ungu yang jauh lebih gelap untuk bagian atas gradien.
  static const Color _atas = Color.fromARGB(255, 45, 31, 58);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_atas, _bawah],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              /*
                Dapat digulir karena jendela kasir kadang dipendekkan sampai
                setengah layar. Tanpa ini, isinya terpotong dan tombolnya tidak
                dapat dijangkau sama sekali.
              */
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/IconReverted.webp",
                    width: 72,
                    height: 72,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "CSTYLE CASHIER",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      /*
                        Jarak antarhuruf dilebarkan. Pada tulisan pendek yang
                        seluruhnya kapital, ini yang membedakan antara terbaca
                        sebagai nama produk dan terbaca sebagai teriakan.
                      */
                      letterSpacing: 3.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Version $versi",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: "Lato",
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
