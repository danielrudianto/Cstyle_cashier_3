import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bilah atas: lambang, perpindahan halaman, dan daftar nota tertahan.
///
/// EMPAT HAL YANG DIPERBAIKI.
///
/// Satu, garis bawahnya Colors.grey.shade300 — nilai untuk latar terang. Di
/// tema gelap itulah garis paling terang di seluruh layar, dan ia kebal
/// terhadap perubahan dividerColor karena tidak pernah membacanya.
///
/// Dua, kedua tab menyalin kode satu sama lain, dan salinannya sudah
/// menyimpang: tab aktif "Dashboard" memakai ungu yang dipatok #6D4E89 —
/// ungu tema TERANG — sementara "Store" memakai secondaryHeaderColor. Dua
/// warna berbeda untuk keadaan yang sama persis, dan yang dipatok itu redup di
/// atas latar gelap, jadi halaman yang sedang dibuka justru tampil paling pudar.
/// Sekarang keduanya satu widget; tidak ada lagi salinan yang bisa menyimpang.
///
/// Tiga, tingginya 80 piksel untuk memuat dua kata. Di layar kasir, setiap
/// piksel yang dipakai bilah atas adalah satu baris barang yang tidak muat.
/// Turun ke 56.
///
/// Empat, tab yang tidak aktif tidak punya keadaan sorot sama sekali, jadi
/// tidak ada tanda ia bisa ditekan sampai benar-benar ditekan.
class AppbarPageView extends StatelessWidget {
  final int page;
  final Function changePage;
  final Function onOpenCartList;
  final Function onOpenCart;

  const AppbarPageView({
    super.key,
    required this.page,
    required this.changePage,
    required this.onOpenCartList,
    required this.onOpenCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Consumer<CartNotifier>(
        builder: (_, keranjang, __) {
          return SizedBox(
            height: 56,
            child: Row(
              children: [
                Image.asset(
                  logoTema(context),
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  "CSTYLE CASHIER",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                _TombolMode(
                  diModeKelola: page == 1,
                  onTukar: () => changePage(page == 1 ? 0 : 1),
                ),
                const SizedBox(width: 6),
                Badge(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  /*
                    Badge memakai textColor, bukan foregroundColor. Angkanya
                    dulu dipatok Colors.white — di tema gelap aksennya ungu
                    MUDA, dan putih di atasnya hanya 3,4:1.
                  */
                  textColor: diAtasAksen(context),
                  isLabelVisible: keranjang.cartCount > 0,
                  label: Text(
                    keranjang.cartCount.toString(),
                    style: const TextStyle(fontSize: 9),
                  ),
                  child: IconButton(
                    /*
                      Tombol ini tidak pernah punya nama. Ia membuka daftar nota
                      yang ditahan, dan satu-satunya keterangannya adalah ikon
                      peti — yang tidak menyebut nota maupun tahan.
                    */
                    tooltip: keranjang.cartCount == 0
                        ? "No held bills"
                        : "Held bills (${keranjang.cartCount})",
                    icon: Icon(
                      Icons.inventory_2_outlined,
                      color: keranjang.cartCount == 0
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).iconTheme.color,
                    ),
                    onPressed: keranjang.cartCount == 0
                        ? null
                        : () => onOpenCartList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Satu tombol untuk berpindah antara menjual dan mengelola.
///
/// KENAPA SATU TOMBOL, BUKAN DUA PILIHAN BERDAMPINGAN.
///
/// Bentuk sebelumnya — mula-mula dua tab bergaris bawah, lalu sakelar
/// bersegmen — memberi bobot yang sama kepada dua hal yang pemakaiannya sama
/// sekali tidak seimbang. Kasir berada di mode menjual hampir sepanjang hari;
/// mengelola adalah singgahan sesekali untuk menyinkronkan stok atau mengubah
/// pencetak. Menampilkan keduanya bersisian di tengah bilah menyatakan bahwa
/// keduanya setara, dan itu tidak benar.
///
/// Satu tombol menyatakan hubungan yang sebenarnya: ada tempat kerja, dan ada
/// jalan keluar sementara darinya. Ditaruh di KANAN bersama kendali lain, bukan
/// di tengah — letaknya sendiri sudah mengatakan bahwa ini bukan navigasi
/// utama, dan tengah bilah bebas untuk lambangnya.
///
/// Labelnya menyebut TUJUAN, bukan keadaan sekarang. "Manage store" berarti
/// menekan ini membawa ke sana; ketika sudah di sana, ia berubah menjadi
/// "Back to selling". Anak panahnya ikut berbalik supaya arahnya terbaca
/// sebelum kalimatnya.
class _TombolMode extends StatefulWidget {
  final bool diModeKelola;
  final VoidCallback onTukar;

  const _TombolMode({required this.diModeKelola, required this.onTukar});

  @override
  State<_TombolMode> createState() => _TombolModeState();
}

class _TombolModeState extends State<_TombolMode> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    final ikon = widget.diModeKelola
        ? Icons.arrow_back_rounded
        : Icons.storefront_outlined;
    final label = widget.diModeKelola ? "Back to selling" : "Manage store";

    final depan = warna.onSurface.withValues(alpha: _disorot ? 0.95 : 0.7);

    return Tooltip(
      message: widget.diModeKelola
          ? "Return to the selling screen"
          : "Stock sync, printer, memberships and settings",
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _disorot = true),
        onExit: (_) => setState(() => _disorot = false),
        child: GestureDetector(
          onTap: widget.onTukar,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: Gerak.kilat,
            curve: Gerak.masuk,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _disorot
                  ? warna.onSurface.withValues(alpha: 0.07)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: warna.outline.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ikon, size: 16, color: depan),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: depan,
                    fontSize: 13,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
