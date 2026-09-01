import 'dart:math';

import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Perpindahan halaman pada daftar berhalaman.
///
/// DULU HANYA "Page 1 of 408".
///
/// Nomor halaman menjawab pertanyaan yang tidak ditanyakan siapa pun. Yang
/// benar-benar ingin diketahui saat menyusuri daftar adalah BARIS KEBERAPA yang
/// sedang dilihat dari berapa seluruhnya — "1–20 dari 8.152" menjawab itu, dan
/// nomor halamannya bisa disimpulkan sendiri kalau memang diperlukan.
///
/// Angkanya monospace, sekeluarga dengan kepala kolom dan baris keterangan
/// terminal. Ini deretan angka yang berubah setiap kali halaman berpindah;
/// huruf berlebar seragam membuat posisinya tidak bergeser saat berubah.
class PaginationComponent extends StatelessWidget {
  final int pageIndex;
  final int dataCount;
  final int pageSize;
  final Function(int) onPageChange;

  const PaginationComponent({
    super.key,
    required this.pageIndex,
    required this.dataCount,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = max((dataCount / pageSize).ceil(), 1);
    final angka = NumberFormat.decimalPattern("en-US");

    final dari = dataCount == 0 ? 0 : pageIndex * pageSize + 1;
    final sampai = min((pageIndex + 1) * pageSize, dataCount);

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "${angka.format(dari)}–${angka.format(sampai)} of "
            "${angka.format(dataCount)}",
            style: gayaKode(context, ukuran: 12),
          ),
          const SizedBox(width: 14),
          _Panah(
            ikon: Icons.chevron_left_rounded,
            keterangan: "Previous page",
            onTekan: pageIndex > 0 ? () => onPageChange(pageIndex - 1) : null,
          ),
          _Panah(
            ikon: Icons.chevron_right_rounded,
            keterangan: "Next page",
            onTekan: pageIndex + 1 < totalPages
                ? () => onPageChange(pageIndex + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Satu panah perpindahan halaman.
///
/// IconButton bawaan membawa bidang sentuh 48 piksel dan riak lingkarannya
/// sendiri — dua hal yang benar pada layar sentuh dan berlebihan pada tabel
/// desktop, di mana keduanya membuat sudut halaman terlihat lebih berat
/// daripada isinya.
class _Panah extends StatefulWidget {
  final IconData ikon;
  final String keterangan;
  final VoidCallback? onTekan;

  const _Panah({
    required this.ikon,
    required this.keterangan,
    required this.onTekan,
  });

  @override
  State<_Panah> createState() => _PanahState();
}

class _PanahState extends State<_Panah> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final bisa = widget.onTekan != null;

    return Tooltip(
      message: widget.keterangan,
      child: MouseRegion(
        cursor: bisa ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _disorot = true),
        onExit: (_) => setState(() => _disorot = false),
        child: GestureDetector(
          onTap: widget.onTekan,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(left: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: _disorot && bisa
                  ? warna.onSurface.withValues(alpha: 0.07)
                  : Colors.transparent,
            ),
            child: Icon(
              widget.ikon,
              size: 20,
              color: warna.onSurface.withValues(alpha: bisa ? 0.75 : 0.25),
            ),
          ),
        ),
      ),
    );
  }
}
