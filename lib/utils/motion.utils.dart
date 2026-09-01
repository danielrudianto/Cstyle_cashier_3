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

  /// Untuk sesuatu yang MASUK: cepat di awal, melambat di ujung.
  static const Curve masuk = Curves.easeOutCubic;

  /// Untuk sesuatu yang PERGI: lambat di awal, mempercepat keluar.
  static const Curve keluar = Curves.easeInCubic;

  /// Untuk angka yang berubah — berhenti tegas, tidak mengambang.
  static const Curve tegas = Curves.easeOutQuart;
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
          style: gaya,
          textAlign: rataan,
        );
      },
    );
  }
}

/*
  KEDUA WIDGET DI BAWAH SENGAJA TIDAK MENANGKAP SENTUHAN.

  Percobaan pertama menggabungkan sorot kursor dan umpan balik tekan dalam satu
  widget yang memasang GestureDetector sendiri. Itu salah untuk aplikasi ini:
  hampir semua yang dapat ditekan di sini sudah dibungkus InkWell, dan dua
  penangkap sentuhan yang bertumpuk akan saling berebut di gesture arena —
  gejalanya sentuhan yang kadang tidak terbaca, dan itu jauh lebih mahal
  daripada nilai animasinya.

  Jadi keduanya hanya mendengarkan KURSOR lewat MouseRegion, yang tidak ikut
  dalam perebutan itu sama sekali. Umpan balik sentuhan tetap ditangani riak
  bawaan InkWell yang memang sudah ada.

  Keadaan sorot memang tidak ada pada layar sentuh. Tetapi ini aplikasi Windows
  yang dijalankan dengan tetikus, dan justru benda yang menyadari kursor ada di
  atasnya itulah yang paling membedakan program desktop yang digarap dari yang
  tidak.
*/

/// Sedikit membesar saat kursor berada di atasnya. Untuk tombol dan kartu.
///
/// Pembesarannya 2%. Pada sesuatu yang dilewati kursor ratusan kali sehari,
/// gerakan besar berubah menjadi ribut.
class SorotMembesar extends StatefulWidget {
  final Widget child;
  final double skala;

  const SorotMembesar({super.key, required this.child, this.skala = 1.02});

  @override
  State<SorotMembesar> createState() => _SorotMembesarState();
}

class _SorotMembesarState extends State<SorotMembesar> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    if (gerakDimatikan(context)) return widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: AnimatedScale(
        scale: _disorot ? widget.skala : 1.0,
        duration: Gerak.kilat,
        curve: Gerak.masuk,
        child: widget.child,
      ),
    );
  }
}

/// Latar yang menyala tipis saat kursor berada di atasnya. Untuk baris daftar.
///
/// Baris daftar TIDAK boleh diperbesar seperti kartu — membesar berarti
/// menimpa baris tetangganya, dan pada daftar barang yang rapat hasilnya
/// terlihat seperti kesalahan tata letak, bukan seperti sambutan.
///
/// Warnanya diambil dari aksen tema dengan opasitas sangat rendah, jadi ia ikut
/// benar di terang maupun gelap tanpa perlu nilai terpisah.
///
/// Memakai withValues, bukan withOpacity. Yang terpasang Flutter 3.44.4 /
/// Dart 3.12.2; withOpacity sudah usang di situ dan menghasilkan peringatan.
/// Angka >=3.22.0 di pubspec.lock adalah batas MINIMUM dari dependensinya,
/// bukan versi yang dipakai membangun — keduanya sempat tertukar.
///
/// Tujuh belas withOpacity lain yang sudah ada di kode belum diikutkan;
/// itu penyapuan tersendiri.
class SorotBerlatar extends StatefulWidget {
  final Widget child;
  final BorderRadius? lengkung;

  const SorotBerlatar({super.key, required this.child, this.lengkung});

  @override
  State<SorotBerlatar> createState() => _SorotBerlatarState();
}

class _SorotBerlatarState extends State<SorotBerlatar> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    if (gerakDimatikan(context)) return widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: AnimatedContainer(
        duration: Gerak.kilat,
        curve: Gerak.masuk,
        decoration: BoxDecoration(
          borderRadius: widget.lengkung,
          color: _disorot
              ? Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Perpindahan halaman untuk go_router.
///
/// Halaman baru meredup masuk sambil naik sedikit. Naiknya cuma 12 piksel —
/// cukup untuk memberi arah, tidak cukup untuk terasa sebagai perjalanan.
///
/// Sebelumnya seluruh route memakai `builder:`, yang berarti transisi bawaan
/// dan berbeda-beda tergantung sistem operasinya. Sekarang keempat belas route
/// bergerak dengan cara yang sama.
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
