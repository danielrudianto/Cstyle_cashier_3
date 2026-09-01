import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';

/// Tirai yang tumbuh dari satu widget hingga menutupi seluruh layar.
///
/// KENAPA BUKAN SEKADAR PERPINDAHAN HALAMAN.
///
/// Perpindahan biasa memperlakukan dua layar sebagai dua benda: yang satu
/// pergi, yang lain datang. Padahal dari sisi penggunanya, menekan "Activate"
/// bukan berpindah ke tempat lain — kartu yang barusan diisi ITULAH yang
/// menjadi halaman berikutnya. Tirai ini menjalankan bacaan itu: kartunya
/// tidak hilang lalu diganti, ia tumbuh sampai seukuran layar, dan halaman
/// berikutnya sudah ada di dalamnya.
///
/// CARA MEMBUATNYA TIDAK TERLIHAT SAMBUNGANNYA.
///
/// Tirainya diisi dengan latar halaman TUJUAN, bukan warna netral. Begitu ia
/// selesai mengembang, yang terlihat di layar sudah persis sama dengan halaman
/// berikutnya — jadi perpindahan route yang terjadi sesudahnya, yang hanya
/// memudar, tidak mengubah satu piksel pun. Sambungannya ada, tetapi tidak ada
/// yang bisa melihatnya.
///
/// Itu juga sebabnya route /main memakai perpindahan yang HANYA memudar;
/// pergeseran sekecil apa pun di situ langsung membongkar tipuannya.
///
/// SATU BENTUK, DUA EFEK.
///
/// Tirainya selalu persegi bersudut membulat yang jari-jarinya menyusut ke
/// nol. Diberi kotak asal seukuran kartu dengan jari-jari kecil, hasilnya
/// kartu yang mengembang. Diberi kotak asal seukuran logo dengan jari-jari
/// setengah lebarnya, kotak itu BERUPA lingkaran, dan hasilnya lingkaran yang
/// menyebar dari logo. Tidak perlu dua widget.
class TiraiKeluar extends StatefulWidget {
  /// Isi halaman, ditaruh di bawah tirai.
  final Widget child;

  /// Widget yang menjadi titik mulai. Ukuran dan posisinya dibaca saat
  /// [aktif] berubah menjadi benar.
  final GlobalKey asal;

  /// Menjalankan tirai. Sekali benar, tidak perlu dikembalikan.
  final bool aktif;

  /// Jari-jari sudut pada saat mulai. Setengah lebar [asal] menghasilkan
  /// lingkaran.
  final double radiusAwal;

  /// Isi tirai. Salah satu saja yang diisi.
  final Gradient? gradien;
  final Color? warna;

  const TiraiKeluar({
    super.key,
    required this.child,
    required this.asal,
    required this.aktif,
    this.radiusAwal = 0,
    this.gradien,
    this.warna,
  });

  @override
  State<TiraiKeluar> createState() => _TiraiKeluarState();
}

class _TiraiKeluarState extends State<TiraiKeluar> {
  /// Kotak asal dalam koordinat layar, dibaca sekali saat tirai dijalankan.
  Rect? _kotakAsal;

  /// Dinyalakan SATU BINGKAI sesudah [_kotakAsal] terisi.
  ///
  /// AnimatedPositioned menganimasikan dari nilai yang sudah pernah ia pasang
  /// ke nilai barunya. Kalau keduanya disetel pada bingkai yang sama, ia hanya
  /// melihat satu nilai — yang sudah mengembang — dan tirainya muncul langsung
  /// memenuhi layar tanpa gerakan sama sekali.
  bool _mengembang = false;

  @override
  void didUpdateWidget(TiraiKeluar lama) {
    super.didUpdateWidget(lama);
    if (widget.aktif && !lama.aktif) {
      _jalankan();
    }
  }

  void _jalankan() {
    final render = widget.asal.currentContext?.findRenderObject();
    if (render is! RenderBox || !render.hasSize) {
      /*
        Tanpa kotak asal tidak ada yang bisa ditumbuhkan. Dibiarkan diam:
        pemanggilnya tetap berpindah halaman sesudah jedanya, jadi yang hilang
        hanya gerakannya, bukan alurnya.
      */
      return;
    }

    setState(() {
      _kotakAsal = render.localToGlobal(Offset.zero) & render.size;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _mengembang = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final layar = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        widget.child,
        if (_kotakAsal != null)
          AnimatedPositioned(
            duration: Gerak.tirai,
            curve: Gerak.berat,
            left: _mengembang ? 0 : _kotakAsal!.left,
            top: _mengembang ? 0 : _kotakAsal!.top,
            width: _mengembang ? layar.width : _kotakAsal!.width,
            height: _mengembang ? layar.height : _kotakAsal!.height,
            child: AnimatedContainer(
              duration: Gerak.tirai,
              curve: Gerak.berat,
              decoration: BoxDecoration(
                gradient: widget.gradien,
                color: widget.warna,
                borderRadius: BorderRadius.circular(
                  _mengembang ? 0 : widget.radiusAwal,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
