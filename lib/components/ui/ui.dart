import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';

/*
  Lapisan komponen bersama.

  KENAPA BERKAS INI ADA.

  Layar pembuka dan penyiapan dikerjakan sebagai desain: gradien, gerak,
  jarak yang dipikirkan. Layar-layar di dalamnya tidak — masing-masing dirapikan
  sendiri-sendiri, dan hasilnya makin ke dalam makin sederhana. Itu bukan
  perbedaan selera; itu tanda bahwa TIDAK ADA standarnya.

  Buktinya ada di kodenya sendiri sebelum berkas ini dibuat:

    - TIGA salinan sakelar bersegmen yang hampir identik, di bilah atas, di
      setelan tema, dan di bahasa struk. Ketiganya sudah mulai berbeda.
    - Bentuk kartu — permukaan, garis rambut, jari-jari 12 — diketik ulang di
      setiap tempat yang memakainya.
    - DUA widget judul bagian dengan nama berbeda di satu berkas yang sama.
    - Lima InputDecoration yang dirakit tangan, masing-masing menyebut sendiri
      warna garis tepinya.

  Selama bentuknya diketik ulang, keseragaman harus dicapai lagi setiap kali —
  dan yang terlewat akan menyimpang tanpa ada yang menyadarinya. Di sini
  bentuknya disebut SEKALI, dan layar-layarnya memanggil.

  Yang TIDAK masuk ke sini: warna dan ukuran huruf. Keduanya sudah tinggal di
  utils/theme.utils.dart, dan tempo gerak di utils/motion.utils.dart. Berkas ini
  hanya menyusun keduanya menjadi bentuk yang berulang.
*/

/// Permukaan berkotak yang dipakai seluruh aplikasi.
///
/// Satu bentuk: warna kartu tema, garis rambut, jari-jari 12. Yang membedakan
/// isinya, bukan wadahnya — dan kalau suatu saat memang ada yang perlu
/// dibedakan, [aksen] menyalakan batang di tepi kiri, seperti pada blok laporan
/// harian yang memang satu-satunya penghasil keluaran di halamannya.
class Kartu extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Menyalakan batang aksen di tepi kiri. Dipakai HEMAT: begitu ada dua,
  /// keduanya berhenti berarti.
  final bool aksen;

  final double? lebar;

  const Kartu({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.aksen = false,
    this.lebar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      width: lebar,
      padding: padding,
      decoration: BoxDecoration(
        color: aksen
            ? tema.secondaryHeaderColor.withValues(alpha: 0.07)
            : tema.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: aksen
            ? Border(
                left: BorderSide(
                  color: tema.secondaryHeaderColor,
                  width: 3,
                ),
              )
            : Border.all(color: tema.dividerColor),
      ),
      child: child,
    );
  }
}

/// Judul satu bagian, dengan garis rambut yang menyambung ke tepi.
///
/// Label kecil yang berdiri sendirian di antara kolom isian mudah terbaca
/// sebagai keterangan salah satu kolom, bukan sebagai pembuka kelompok.
/// Garisnya yang membuatnya terbaca sebagai batas — dan karena garis itu yang
/// bekerja, labelnya tidak perlu diperbesar sampai bersaing dengan isinya.
class JudulBagian extends StatelessWidget {
  final String teks;
  final double atas;

  const JudulBagian(this.teks, {super.key, this.atas = 22});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: atas, bottom: 12),
      child: Row(
        children: [
          Text(teks, style: gayaLabelKolom(context)?.copyWith(fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(height: 1, color: Theme.of(context).dividerColor),
          ),
        ],
      ),
    );
  }
}

/// Satu pilihan pada [PilihanSegmen].
class OpsiSegmen<T> {
  final T nilai;
  final String label;
  final IconData? ikon;

  const OpsiSegmen({required this.nilai, required this.label, this.ikon});
}

/// Sakelar bersegmen: beberapa pilihan tetap yang saling meniadakan.
///
/// MENGGANTIKAN TIGA SALINAN DAN SEJUMLAH RADIO.
///
/// Dipakai untuk pilihan yang jumlahnya TIDAK akan bertambah — tema, bahasa
/// struk, terima atau tolak. Radio selebar layar untuk dua atau tiga pilihan
/// menghabiskan seratus piksel lebih dan menyatakan bahwa daftarnya bisa
/// memanjang; bentuk bersegmen menyatakan yang sebenarnya, bahwa memilih satu
/// berarti melepas yang lain.
///
/// Tiga tingkat, bukan dua: yang terpilih berlatar aksen, yang disorot mendapat
/// latar samar, sisanya polos. Tanpa tingkat tengah, segmen yang bisa ditekan
/// tidak memberi tanda apa pun sampai benar-benar ditekan.
class PilihanSegmen<T> extends StatelessWidget {
  final List<OpsiSegmen<T>> opsi;
  final T terpilih;
  final ValueChanged<T> onPilih;

  /// Dimatikan seluruhnya, mis. selama pengiriman berlangsung.
  final bool aktif;

  const PilihanSegmen({
    super.key,
    required this.opsi,
    required this.terpilih,
    required this.onPilih,
    this.aktif = true,
  });

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: warna.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < opsi.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            _Segmen<T>(
              opsi: opsi[i],
              terpilih: opsi[i].nilai == terpilih,
              aktif: aktif,
              onTekan: () => onPilih(opsi[i].nilai),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segmen<T> extends StatefulWidget {
  final OpsiSegmen<T> opsi;
  final bool terpilih;
  final bool aktif;
  final VoidCallback onTekan;

  const _Segmen({
    required this.opsi,
    required this.terpilih,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_Segmen<T>> createState() => _SegmenState<T>();
}

class _SegmenState<T> extends State<_Segmen<T>> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final bisaDitekan = widget.aktif && !widget.terpilih;

    final Color latar = widget.terpilih
        ? warna.primary
        : (_disorot && bisaDitekan
            ? warna.onSurface.withValues(alpha: 0.07)
            : Colors.transparent);

    final Color depan = widget.terpilih
        ? warna.onPrimary
        : warna.onSurface.withValues(
            alpha: widget.aktif ? (_disorot ? 0.92 : 0.62) : 0.3,
          );

    return MouseRegion(
      cursor: bisaDitekan ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: bisaDitekan ? widget.onTekan : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.opsi.ikon != null) ...[
                Icon(widget.opsi.ikon, size: 16, color: depan),
                const SizedBox(width: 8),
              ],
              Text(
                widget.opsi.label,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: depan,
                  fontSize: 13,
                  letterSpacing: 0.2,
                  fontWeight:
                      widget.terpilih ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hiasan kolom isian yang dipakai seluruh aplikasi.
///
/// Sebelumnya tiap layar merakitnya sendiri, dan yang paling sering keliru
/// adalah warnanya: garis tepi diambil dari dividerColor — yang sengaja sangat
/// samar supaya garis antarbaris tabel tidak berteriak — sehingga TEPI kolom
/// isian nyaris tidak terlihat. Dan garis fokusnya kerap disetel sama persis
/// dengan yang tidak fokus, jadi tidak ada tanda kolom mana yang sedang diketik.
///
/// Di sini keduanya disebut sekali: `outline` untuk tepi, aksen untuk fokus,
/// dan warna galat menggantikan keduanya saat [galat] benar.
InputDecoration dekorasiIsian(
  BuildContext context, {
  String? label,
  String? petunjuk,
  Widget? awalan,
  Widget? akhiran,
  bool galat = false,
}) {
  final warna = Theme.of(context).colorScheme;

  OutlineInputBorder garis(Color c, [double lebar = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: c, width: lebar),
      );

  return InputDecoration(
    isDense: true,
    labelText: label,
    hintText: petunjuk,
    hintStyle: TextStyle(color: warna.onSurface.withValues(alpha: 0.4)),
    prefixIcon: awalan,
    suffixIcon: akhiran,
    filled: true,
    fillColor: warna.onSurface.withValues(alpha: 0.05),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: garis(warna.outline),
    enabledBorder: garis(galat ? warna.error : warna.outline),
    focusedBorder: garis(galat ? warna.error : warna.primary, 1.6),
  );
}

/// Satu pasang keterangan pada [BarisMeta].
class Meta {
  final String label;
  final String nilai;

  const Meta(this.label, this.nilai);
}

/// Deret keterangan mendatar di antara dua garis rambut.
///
/// Bentuk yang dipakai halaman yang ingin terbaca sebagai DOKUMEN: label kecil
/// beserta nilainya, berjajar, dipisah jarak dan bukan kotak. Ia menjawab
/// pertanyaan yang muncul sekali dan tidak perlu ditanyakan lagi — versi berapa,
/// toko mana, terakhir disinkronkan kapan — tanpa memakan tempat sebesar kartu.
///
/// Nilainya memakai huruf monospace karena semuanya kode dan angka; lihat
/// gayaKode di utils/theme.utils.dart.
class BarisMeta extends StatelessWidget {
  final List<Meta> isi;

  const BarisMeta({super.key, required this.isi});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tema.dividerColor),
          bottom: BorderSide(color: tema.dividerColor),
        ),
      ),
      child: Wrap(
        spacing: 36,
        runSpacing: 12,
        children: [
          for (final m in isi)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.label, style: gayaLabelKolom(context)),
                const SizedBox(width: 10),
                Text(
                  m.nilai,
                  style: gayaKode(context, ukuran: 12).copyWith(
                    color: tema.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
