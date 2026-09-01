import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/*
  Fondasi gerak aplikasi.

  KENAPA SATU BERKAS, BUKAN DITABUR DI TIAP LAYAR.

  Yang membuat sebuah program terasa mahal bukan banyaknya animasi, melainkan
  konsistensinya: setiap perpindahan memakai tempo dan lengkung yang sama, jadi
  seluruh aplikasi terasa digerakkan satu tangan. Begitu tiap layar memilih
  durasinya sendiri, hasilnya justru terasa murah — dan tidak ada cara
  merapikannya belakangan tanpa menyentuh semua berkas.

  TEMPONYA SENGAJA PENDEK.

  Ini kasir. Satu orang menekan tombol yang sama ratusan kali sehari, dan
  animasi 400ms yang terasa mewah pada demo berubah menjadi penungguan pada
  transaksi ke seratus. Semua nilai di bawah ada di bawah 300ms, dan yang
  dipakai untuk umpan balik sentuhan di bawah 150ms — cukup untuk terbaca
  sebagai gerakan, tidak cukup untuk terasa sebagai jeda.

  Gerakannya juga harus PUNYA MAKSUD: menunjukkan sesuatu datang dari mana,
  atau menegaskan angka yang baru saja berubah. Yang tidak menjelaskan apa-apa
  tidak dipasang.
*/

/// Tempo dan lengkung gerak.
class Gerak {
  Gerak._();

  /// Umpan balik sentuhan: tombol ditekan, kartu disorot kursor.
  ///
  /// Di bawah 150ms supaya terbaca sebagai respons, bukan sebagai tunggu.
  static const Duration kilat = Duration(milliseconds: 120);

  /// Perpindahan halaman dan munculnya elemen.
  static const Duration cepat = Duration(milliseconds: 180);

  /// Perubahan nilai yang perlu diikuti mata, terutama angka total.
  static const Duration sedang = Duration(milliseconds: 260);

  /// Satu-satunya gerakan panjang yang dibolehkan: tirai yang tumbuh dari
  /// sebuah kotak menjadi seluruh layar.
  ///
  /// Lebih panjang daripada yang lain, dan itu disengaja. Gerakan ini
  /// MENGGANTIKAN perpindahan halaman, bukan ditambahkan padanya — yang
  /// ditempuh matanya bukan lagi jarak beberapa piksel melainkan seluruh
  /// layar, dan pada jarak sejauh itu 180ms terbaca sebagai kedipan, bukan
  /// sebagai perpindahan. Ia juga terjadi sekali saja seumur pemasangan
  /// terminal, bukan ratusan kali sehari.
  static const Duration tirai = Duration(milliseconds: 340);

  /// Untuk sesuatu yang MASUK: cepat di awal, melambat di ujung.
  static const Curve masuk = Curves.easeOutCubic;

  /// Untuk sesuatu yang PERGI: lambat di awal, mempercepat keluar.
  static const Curve keluar = Curves.easeInCubic;

  /// Untuk angka yang berubah — berhenti tegas, tidak mengambang.
  static const Curve tegas = Curves.easeOutQuart;

  /// Berangkat pelan, cepat di tengah, mendarat pelan. Pasangan [tirai].
  ///
  /// Sesuatu yang membesar sampai seukuran layar harus terasa punya massa.
  /// easeOut saja membuatnya melesat sejak piksel pertama, dan hasilnya
  /// terlihat seperti kesalahan tata letak, bukan seperti perpindahan.
  static const Curve berat = Curves.easeInOutCubic;
}

/// Apakah pengguna meminta animasi dimatikan.
///
/// Windows punya setelan "Show animations in Windows" di Ease of Access, dan
/// Flutter meneruskannya ke sini. Mengabaikannya berarti memaksakan gerak pada
/// orang yang menonaktifkannya justru karena gerak itu mengganggunya.
///
/// Setiap widget di berkas ini memeriksanya dan jatuh ke bentuk diam.
bool gerakDimatikan(BuildContext context) {
  return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Angka yang berjalan ke nilai barunya, bukan melompat.
///
/// Dipakai untuk total belanja. Selain terlihat mahal, ini ADA GUNANYA: mata
/// kasir tertarik ke angka yang bergerak, jadi perubahan total setelah barang
/// ditambah atau diskon dipasang tidak terlewat. Angka yang melompat diam-diam
/// justru mudah tidak disadari.
class AngkaBergerak extends StatelessWidget {
  final double nilai;
  final String pola;
  final TextStyle? gaya;
  final TextAlign? rataan;
  final Duration durasi;

  const AngkaBergerak({
    super.key,
    required this.nilai,
    this.pola = "#,##0.00",
    this.gaya,
    this.rataan,
    this.durasi = Gerak.sedang,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat(pola);

    if (gerakDimatikan(context)) {
      return Text(format.format(nilai), style: gaya, textAlign: rataan);
    }

    return TweenAnimationBuilder<double>(
      /*
        begin DAN end sama-sama diisi nilai sekarang, dan itu disengaja.

        TweenAnimationBuilder hanya memakai `begin` pada build PERTAMA;
        sesudahnya ia menganimasikan dari nilai yang sedang tampil menuju `end`
        yang baru. Menulis begin: 0 akan membuat totalnya menghitung naik dari
        nol setiap kali widget-nya dipasang ulang — mengesankan pada demo,
        mengganggu pada transaksi kesepuluh.
      */
      tween: Tween<double>(begin: nilai, end: nilai),
      duration: durasi,
      curve: Gerak.tegas,
      builder: (context, nilaiSekarang, _) {
        return Text(
          format.format(nilaiSekarang),
          /*
            Angka selebar sama (tabular figures).

            Pada huruf biasa, "1" jauh lebih sempit daripada "8", jadi angka
            yang sedang berjalan berubah lebar di setiap bingkai dan totalnya
            terlihat bergetar — persis lawan dari kesan yang ingin diberikan
            angka yang bergerak halus. Ini juga membuat kolom harga berbaris
            lurus di titik desimalnya.
          */
          style: (gaya ?? const TextStyle()).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          textAlign: rataan,
        );
      },
    );
  }
}

/*
  DUA WIDGET SOROT PERNAH ADA DI SINI, DAN KEDUANYA SUDAH DIBUANG.

  SorotBerlatar menyalakan latar baris daftar saat disorot; SorotMembesar
  membesarkan tombol dan kartu sedikit. Keduanya bekerja, dan keduanya ternyata
  tidak diperlukan.

  Yang pertama dibuang karena ongkosnya: satu MouseRegion dan satu
  AnimatedContainer per baris, dengan setState saat kursor masuk dan keluar,
  pada daftar yang membangun ratusan baris sekaligus. InkWell yang sudah ada di
  situ menangani sorot lewat satu lapisan Material untuk seluruh daftar.

  Yang kedua dibuang karena tidak ada lagi yang memakainya: tombol-tombol yang
  dulu dibungkusnya kini FilledButton sungguhan, dan tema sudah memberi mereka
  sorot, elevasi, dan kursor tangan.

  Pelajarannya dicatat di sini karena mudah terulang: sebelum membungkus sesuatu
  dengan widget sorot buatan sendiri, periksa dulu apakah widget yang sudah
  membungkusnya memang belum punya keadaan itu. Biasanya sudah.
*/

/// Perpindahan yang HANYA memudar, tanpa pergeseran.
///
/// Dipakai halaman yang dimasuki lewat tirai. Tirainya sudah menutupi seluruh
/// layar dengan warna latar halaman tujuan, jadi begitu halamannya benar-benar
/// dipasang, yang terjadi seharusnya tidak terlihat sama sekali. Menambahkan
/// pergeseran di situ justru merusaknya: layar yang sudah diam tiba-tiba
/// bergerak dua belas piksel, dan sambungan yang tadinya mulus jadi
/// terlihat sambungannya.
CustomTransitionPage<T> halamanMemudar<T>({
  required LocalKey kunci,
  required Widget anak,
}) {
  return CustomTransitionPage<T>(
    key: kunci,
    child: anak,
    transitionDuration: Gerak.cepat,
    reverseTransitionDuration: Gerak.kilat,
    transitionsBuilder: (context, animation, animasiKedua, child) {
      if (gerakDimatikan(context)) return child;
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<T> halamanBergerak<T>({
  required LocalKey kunci,
  required Widget anak,
}) {
  return CustomTransitionPage<T>(
    key: kunci,
    child: anak,
    transitionDuration: Gerak.cepat,

    /*
      Mundur dibuat lebih cepat daripada maju. Saat kembali, penggunanya sudah
      tahu apa yang menantinya di belakang — menunggu selama saat maju terasa
      lambat tanpa memberi keterangan apa pun.
    */
    reverseTransitionDuration: Gerak.kilat,
    transitionsBuilder: (context, animation, animasiKedua, child) {
      if (gerakDimatikan(context)) return child;

      final redup = CurvedAnimation(parent: animation, curve: Gerak.masuk);

      return FadeTransition(
        opacity: redup,
        child: SlideTransition(
          position: Tween<Offset>(
            /*
              Dinyatakan sebagai pecahan dari tinggi halaman; 0.015 mendekati
              12 piksel pada layar kasir yang lazim.
            */
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(redup),
          child: child,
        ),
      );
    },
  );
}
