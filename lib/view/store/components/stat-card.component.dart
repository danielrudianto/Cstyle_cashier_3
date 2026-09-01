import 'package:flutter/material.dart';

/// Satu angka ringkasan pada halaman kelola.
///
/// DULU TERBALIK.
///
/// Kartunya dikelilingi garis aksen setebal 3 piksel — empat kartu berjajar
/// berarti empat bingkai ungu tebal, dan yang paling menarik mata di seluruh
/// bagian itu justru bingkainya, bukan angkanya. Sementara keterangan
/// lengkapnya ("New members registered in your store") ditulis penuh di dalam
/// kartu dengan ukuran tulisan biasa, memakan dua baris pada setiap kartu.
///
/// Jadi yang seharusnya menonjol dibingkai, dan yang seharusnya diam justru
/// diberi ruang paling banyak.
///
/// Sekarang kartunya diam — permukaan samar dengan garis rambut — dan angkanya
/// yang berbicara. Keterangannya pindah ke tooltip pada tanda tanya yang memang
/// sudah ada di situ: satu sorotan jauhnya bagi yang perlu, tidak memakan
/// tempat bagi yang sudah tahu.
class StatCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Function onPressed;

  const StatCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: warna.onSurface.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tema.dividerColor),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.headlineLarge?.copyWith(
                        /*
                          Angka selebar sama. Empat kartu berjajar dengan angka
                          sepanjang "0" dan "14.4M"; tanpa ini lebarnya berubah
                          setiap kali datanya diperbarui.
                        */
                        fontFeatures: const [FontFeature.tabularFigures()],
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  /*
                    Keterangan lengkapnya ada di sini sekarang, bukan lagi
                    ditulis penuh di badan kartu.
                  */
                  tooltip: description,
                  onPressed: () => onPressed(),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.help_outline,
                    size: 16,
                    color: warna.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodySmall?.copyWith(
                  letterSpacing: 0.3,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
