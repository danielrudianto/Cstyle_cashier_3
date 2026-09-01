import 'package:flutter/material.dart';

/*
  Tema aplikasi kasir.

  DULU DUA BLOK ThemeData YANG DISALIN-TEMPEL.

  Terang dan gelap ditulis terpisah dari atas sampai bawah, dan nilai yang
  seharusnya sama diketik dua kali. Yang begitu selalu berakhir sama: keduanya
  perlahan menyimpang. Sewaktu berkas ini dirapikan, seluruh perbedaan yang
  ditemukan antara keduanya tampak tidak disengaja — bukan keputusan desain:

    - Snackbar melayang di terang, menempel di gelap.
    - disabledColor grey.300 di terang, grey.500 di gelap.
    - Di gelap, colorScheme.surface hitam DAN onSurface hitam.

  Yang terakhir bukan sekadar tidak rapi: itu tulisan hitam di atas hitam.
  Dialog, bottom sheet, dan menu memakai pasangan warna itu, jadi isinya tidak
  terbaca sama sekali. Bawaannya ThemeMode.system, jadi tidak seorang pun perlu
  memilih mode gelap untuk terkena — cukup Windows-nya bertema gelap.

  Sekarang keduanya dibangun dari satu fungsi. Yang benar-benar berbeda antara
  terang dan gelap tinggal warnanya, dan itu terkumpul di _PaletTema.
*/

/// Aksen aplikasi.
///
/// Selama ini menumpang di slot `secondaryHeaderColor` — slot peninggalan
/// Material 2 yang tidak punya arti khusus — dan dibaca dari 45 tempat. Itulah
/// yang membuatnya, secara de facto, warna merek aplikasi ini. Diberi nama di
/// sini supaya tidak perlu ditebak lagi.
///
/// Di dalam view masih tersebar setidaknya empat ungu lain yang mirip tetapi
/// tidak sama (109,41,187 · 161,121,220 · 201,170,252 · 107,76,136) dan satu
/// biru tua (0,32,92). Menyatukannya pekerjaan tersendiri.
const Color aksenCstyle = Color.fromARGB(255, 109, 78, 137);

/// Huruf aplikasi.
///
/// DULU "Montserrat", DAN TIDAK PERNAH SEKALI PUN TAMPIL.
///
/// Nama itu ditulis dua puluh satu kali di seluruh kode, tetapi Montserrat
/// tidak pernah didaftarkan di pubspec.yaml dan paket google_fonts tidak
/// dipakai. Flutter tidak mengeluh untuk keluarga huruf yang tidak ada — ia
/// diam-diam jatuh ke huruf bawaan sistem. Jadi selama ini aplikasi tampil
/// dengan huruf bawaan Windows, sementara enam tempat yang menyebut "Lato"
/// justru benar-benar berganti huruf. Hasilnya dua huruf berbeda dalam satu
/// layar, tanpa ada yang meniatkannya.
///
/// Yang dipilih Lato karena memang sudah ikut dibundel (assets/fonts/lato,
/// sepuluh berkas) — jadi perbaikannya berlaku hari ini juga, tanpa menambah
/// aset apa pun. Kalau Montserrat yang memang diinginkan, berkas .ttf-nya
/// perlu ditaruh di assets/fonts/ dan didaftarkan di pubspec.yaml lebih dulu;
/// mengganti nilai di sini saja akan mengulang persis kesalahan yang sama.
const String hurufCstyle = "Lato";

/// Warna yang benar-benar berbeda antara terang dan gelap.
class _PaletTema {
  final Brightness kecerahan;
  final Color latar;
  final Color kartu;

  /// Dasar untuk dialog, bottom sheet, dan menu.
  final Color permukaan;

  /// Tulisan di atas [permukaan]. INI yang dulu hitam di atas hitam.
  final Color diAtasPermukaan;

  final Color tulisan;
  final Color ikon;
  final Color nonaktif;
  final Color latarSnackbar;
  final Color tulisanSnackbar;

  const _PaletTema({
    required this.kecerahan,
    required this.latar,
    required this.kartu,
    required this.permukaan,
    required this.diAtasPermukaan,
    required this.tulisan,
    required this.ikon,
    required this.nonaktif,
    required this.latarSnackbar,
    required this.tulisanSnackbar,
  });
}

final _paletTerang = _PaletTema(
  kecerahan: Brightness.light,
  latar: const Color.fromARGB(255, 253, 251, 255),
  kartu: Colors.white,
  permukaan: Colors.white,
  diAtasPermukaan: Colors.black,
  tulisan: Colors.black,
  ikon: Colors.black,
  nonaktif: Colors.grey.shade300,
  latarSnackbar: Colors.black,
  tulisanSnackbar: Colors.white,
);

final _paletGelap = _PaletTema(
  kecerahan: Brightness.dark,
  latar: const Color.fromARGB(255, 41, 41, 41),
  kartu: const Color.fromARGB(255, 36, 36, 36),

  /*
    Dulu Colors.black — lebih gelap daripada latar layarnya sendiri (#292929).
    Di mode gelap yang lazim justru sebaliknya: permukaan yang terangkat sedikit
    lebih terang, karena itulah yang membuatnya terbaca sebagai "di atas".
    Disamakan dengan warna kartu supaya dialog dan kartu tampak sekeluarga.
  */
  permukaan: const Color.fromARGB(255, 36, 36, 36),
  diAtasPermukaan: Colors.white,
  tulisan: Colors.white,
  ikon: Colors.white,
  nonaktif: Colors.grey.shade500,
  latarSnackbar: Colors.white,
  tulisanSnackbar: Colors.black,
);

/*
  Tangga ukuran huruf.

  Nilainya SENGAJA dibiarkan persis seperti sebelumnya supaya perbaikan ini
  tidak menggeser tata letak satu layar pun. Perlu dicatat bahwa tangganya
  tidak konsisten: headlineSmall (15) lebih kecil daripada bodyLarge (18), dan
  labelMedium (20) lebih besar daripada labelLarge (15). Nama perannya tidak
  mengikuti ukurannya, jadi ukuran tidak bisa ditebak dari nama — harus
  dihafal. Merapikannya mengubah ukuran tulisan di semua layar sekaligus, jadi
  dikerjakan terpisah dan sengaja tidak diselipkan di sini.
*/
TextTheme _tanggaHuruf(_PaletTema palet) {
  /*
    fontFamily tidak lagi diulang di tiap gaya. ThemeData.fontFamily di bawah
    berlaku untuk seluruh TextTheme, dan pengulangan dua puluh satu kali itulah
    yang membuat satu nama huruf yang tidak pernah ada lolos tanpa ketahuan.
  */
  return TextTheme(
    bodySmall: TextStyle(color: Colors.grey.shade500, fontSize: 12),
    bodyMedium: TextStyle(color: palet.tulisan, fontSize: 16),
    bodyLarge: TextStyle(color: palet.tulisan, fontSize: 18),
    labelSmall: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    labelMedium: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    labelLarge: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
    headlineSmall: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
    headlineMedium: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    headlineLarge: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  );
}

ThemeData _bangunTema(_PaletTema palet) {
  final pemisah = Colors.grey.shade500;

  return ThemeData(
    useMaterial3: true,
    brightness: palet.kecerahan,
    fontFamily: hurufCstyle,

    /*
      Dulu alfanya 150, bukan 255 — jadi warnanya separuh tembus pandang dan
      hasil akhirnya bergantung pada apa pun yang kebetulan ada di belakangnya.
      Hampir pasti salah ketik: nilai yang sama muncul lagi di colorScheme
      dengan alfa penuh.
    */
    primaryColor: const Color.fromARGB(255, 220, 216, 215),
    primaryColorDark: const Color.fromARGB(255, 68, 68, 68),

    /* Aksen aplikasi; 45 tempat membacanya lewat slot ini. */
    secondaryHeaderColor: aksenCstyle,

    scaffoldBackgroundColor: palet.latar,
    cardColor: palet.kartu,
    dividerColor: pemisah,
    disabledColor: palet.nonaktif,
    iconTheme: IconThemeData(color: palet.ikon),
    textTheme: _tanggaHuruf(palet),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 130, 131, 130),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palet.latarSnackbar,
      elevation: 2.0,

      /*
        Melayang di kedua tema. Dulu gelap memakai `fixed` sendirian, jadi
        snackbar berpindah tempat begitu pengguna mengganti tema.
      */
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(color: palet.tulisanSnackbar),
      actionTextColor: aksenCstyle,
    ),
    colorScheme: ColorScheme(
      brightness: palet.kecerahan,
      primary: const Color.fromARGB(255, 220, 216, 215),
      onPrimary: Colors.black,
      secondary: const Color.fromARGB(255, 180, 181, 181),
      onSecondary: Colors.black,
      surface: palet.permukaan,
      onSurface: palet.diAtasPermukaan,
      error: Colors.red,
      onError: Colors.white,

      /*
        Material 3 memakai `outline` untuk garis tepi OutlinedButton, TextField,
        dan kartu bergaris. Tanpa disebut, nilainya jatuh ke bawaan Material
        yang keunguan dan tidak nyambung dengan pemisah abu-abu di seluruh
        aplikasi.
      */
      outline: pemisah,
    ),
  );
}

ThemeData themeData = _bangunTema(_paletTerang);
ThemeData darkThemeData = _bangunTema(_paletGelap);
