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
///
/// Dipakai di atas dasar TERANG. Kontrasnya terhadap putih 6,8:1 — lulus
/// WCAG AA untuk teks biasa.
const Color aksenCstyle = Color.fromARGB(255, 109, 78, 137);

/// Aksen yang sama, untuk dasar GELAP.
///
/// [aksenCstyle] terlalu gelap untuk dipakai di atas latar #292929: kontrasnya
/// cuma 2,3:1, jadi tombol ungu di mode gelap nyaris menyatu dengan
/// belakangnya. Yang ini 4,7:1 terhadap latar gelap dan 6,2:1 terhadap hitam.
///
/// Bukan warna karangan — nilai ini sudah dipakai di beberapa view sebagai
/// varian terang ungunya.
const Color aksenCstyleMuda = Color.fromARGB(255, 161, 121, 220);

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

  /// Aksen yang terbaca di atas dasar tema ini.
  final Color aksen;

  /// Tulisan dan ikon di atas [aksen].
  final Color diAtasAksen;

  /// Aksen untuk teks tombol snackbar.
  ///
  /// Sengaja KEBALIKAN dari [aksen]. Latar snackbar dibalik terhadap temanya —
  /// hitam di tema terang, putih di tema gelap — jadi aksen yang benar di
  /// layar justru salah di atas snackbar. Sebelumnya keduanya memakai ungu
  /// gelap yang sama, dan di tema terang tombolnya jadi ungu gelap di atas
  /// hitam: kontras 3,1:1, praktis tidak terbaca.
  final Color aksenSnackbar;

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
    required this.aksen,
    required this.diAtasAksen,
    required this.aksenSnackbar,
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
  aksen: aksenCstyle,
  diAtasAksen: Colors.white,
  aksenSnackbar: aksenCstyleMuda,
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
  aksen: aksenCstyleMuda,
  diAtasAksen: Colors.black,
  aksenSnackbar: aksenCstyle,
);

/*
  Tangga ukuran huruf.

  DULU BUKAN TANGGA.

  Nama perannya tidak mengikuti ukurannya sama sekali: headlineSmall (15) lebih
  kecil daripada bodyLarge (18), headlineMedium (16) juga, dan labelMedium (20)
  justru lebih besar daripada labelLarge (15). Ukuran tidak bisa ditebak dari
  nama — harus dihafal satu per satu.

  Akar masalahnya bukan angkanya, melainkan pemakaiannya. headlineMedium
  dipakai 27 tempat untuk DUA peran sekaligus: 19 di antaranya header kolom
  tabel ("Date", "Name", "Member ID"), 8 sisanya judul kartu betulan ("Items",
  "Theme setting"). Selama keduanya berbagi satu gaya, ukurannya memang tidak
  bisa dibetulkan — mengecilkan merusak judul, membesarkan merusak tabel.

  Jadi header kolomnya dipindahkan lebih dulu ke labelLarge, yang ukurannya
  sama persis (16), sehingga perpindahan itu sendiri tidak mengubah tampilan
  sedikit pun. Barulah keluarga headline bisa dinaikkan ke atas body.

  YANG BERUBAH UKURANNYA:

    headlineSmall   15 -> 20   11 tempat  (judul bagian, total di kasir)
    headlineMedium  16 -> 22    8 tempat  (judul kartu)
    labelLarge      15 -> 16   35 tempat  (+1px; 16 lama + 19 header kolom)
    labelMedium     20 -> 15    0 tempat  (tidak dipakai di mana pun)

  YANG TIDAK BERUBAH: seluruh keluarga body (177 tempat, termasuk bodyLarge
  yang dipakai 117 kali), labelSmall, dan headlineLarge.
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
      fontSize: 15,
    ),
    /* Header kolom tabel memakai gaya ini; lihat catatan di atas. */
    labelLarge: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    headlineSmall: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    headlineMedium: TextStyle(
      color: palet.tulisan,
      fontWeight: FontWeight.bold,
      fontSize: 22,
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
      Slot peninggalan Material 2, dibaca dari dua tempat.

      DULU ABU-ABU MUDA DENGAN ALFA 150.

      Dua hal salah sekaligus. Alfanya 150, bukan 255 — jadi warnanya separuh
      tembus pandang dan hasil akhirnya bergantung pada apa pun yang kebetulan
      ada di belakangnya; hampir pasti salah ketik, karena nilai yang sama
      muncul lagi di colorScheme dengan alfa penuh.

      Yang kedua lebih terasa: salah satu dari dua pemakainya adalah warna ikon
      unduh di halaman cek stok. Abu-abu muda di atas latar #FDFBFF berkontras
      sekitar 1,2:1 — ikonnya ada, tapi praktis tidak terlihat.

      Disamakan dengan colorScheme.primary supaya tidak ada lagi dua "warna
      utama" yang berbeda di satu tema.
    */
    primaryColor: palet.aksen,
    primaryColorDark: const Color.fromARGB(255, 68, 68, 68),

    /*
      Aksen aplikasi; 45 tempat membacanya lewat slot ini.

      Dulu ungu gelap yang sama di KEDUA tema. Di mode gelap kontrasnya
      terhadap latar #292929 cuma 2,3:1 — jadi seluruh 45 tempat itu nyaris
      tidak terbaca begitu temanya gelap. Sekarang mengikuti temanya.
    */
    secondaryHeaderColor: palet.aksen,
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
      actionTextColor: palet.aksenSnackbar,
    ),
    colorScheme: ColorScheme(
      brightness: palet.kecerahan,

      /*
        DULU ABU-ABU MUDA (220,216,215).

        `primary` menentukan warna FilledButton, FAB, Switch, Checkbox, Radio,
        dan garis fokus TextField. Dengan abu-abu muda, tombol tindakan utama
        tampil sama pucatnya dengan latar di sekitarnya — tidak ada yang
        menonjol sebagai "ini yang harus ditekan".

        Yang aneh, aplikasinya SUDAH punya aksen: ungu yang dibaca dari 45
        tempat lewat secondaryHeaderColor. Jadi widget bawaan Material selama
        ini berjalan dengan warna yang berbeda sendiri dari seluruh aplikasi.
        Sekarang keduanya memakai satu warna yang sama.
      */
      primary: palet.aksen,
      onPrimary: palet.diAtasAksen,

      /*
        `secondary` sengaja dibiarkan abu-abu. Menaikkannya jadi ungu juga akan
        membuat chip dan tombol lapis kedua ikut berwarna, dan hierarkinya
        hilang lagi — justru kebalikan dari yang sedang diperbaiki.
      */
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
