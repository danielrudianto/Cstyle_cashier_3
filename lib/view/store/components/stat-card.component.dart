import 'dart:ui' show FontFeature;

import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';

/// Satu angka ringkasan, disusun sebagai KOLOM pada satu deret — bukan kartu.
///
/// DUA KALI SALAH ARAH SEBELUM SAMPAI KE SINI.
///
/// Mula-mula tiap angka dikelilingi garis aksen setebal 3 piksel, jadi empat
/// bingkai ungu tebal berjajar dan yang paling menarik mata di seluruh bagian
/// itu adalah bingkainya. Lalu bingkainya ditenangkan menjadi permukaan samar
/// bergaris rambut — lebih baik, tetapi masih empat kotak, dan kotak menyatakan
/// "empat benda terpisah" padahal keempatnya satu ringkasan yang dibaca
/// sekaligus.
///
/// Yang benar untuk deret angka pembanding adalah TIDAK ada kotak sama sekali:
/// angka besar, label kecil di bawahnya, dan garis rambut tegak yang
/// memisahkan satu dari yang lain. Yang membentuk kolomnya adalah jaraknya,
/// bukan dindingnya — dan tanpa dinding, keempat angkanya berdiri di garis
/// dasar yang sama sehingga bisa dibandingkan dalam satu tatapan.
class StatCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Function onPressed;

  /// Garis rambut tegak di tepi kiri. Dimatikan untuk kolom pertama.
  final bool pemisah;

  const StatCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.onPressed,
    this.pemisah = true,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(pemisah ? 22 : 0, 2, 12, 2),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: pemisah ? tema.dividerColor : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      height: 1.05,
                      letterSpacing: -0.5,
                      /*
                        Angka selebar sama. Empat kolom berisi "0" dan "15.8M"
                        berdampingan; tanpa ini lebarnya bergeser setiap kali
                        datanya diperbarui.
                      */
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                /*
                  Keterangan lengkapnya ada di tooltip, tidak lagi ditulis penuh
                  di bawah angkanya — dulu dua baris kalimat pada setiap kolom,
                  yang menghabiskan lebih banyak ruang daripada angka yang
                  dijelaskannya.
                */
                Tooltip(
                  message: description,
                  child: InkWell(
                    onTap: () => onPressed(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.help_outline,
                        size: 15,
                        color: warna.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: gayaLabelKolom(context),
            ),
          ],
        ),
      ),
    );
  }
}
