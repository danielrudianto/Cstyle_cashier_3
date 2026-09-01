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
                  width: 32,
                  height: 32,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TabBilah(
                        label: "Dashboard",
                        aktif: page == 0,
                        onTekan: () => changePage(0),
                      ),
                      _TabBilah(
                        label: "Store",
                        aktif: page == 1,
                        onTekan: () => changePage(1),
                      ),
                    ],
                  ),
                ),
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

/// Satu tab pada bilah atas.
///
/// Dijadikan satu widget karena versi sebelumnya menuliskan keduanya dua kali,
/// dan salinannya sudah mulai menyimpang — yang satu memakai warna aktif yang
/// dipatok, yang lain membacanya dari tema.
class _TabBilah extends StatefulWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTekan;

  const _TabBilah({
    required this.label,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_TabBilah> createState() => _TabBilahState();
}

class _TabBilahState extends State<_TabBilah> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aksen = tema.secondaryHeaderColor;
    final dasar = tema.textTheme.bodyMedium;

    /*
      Tiga tingkat, bukan dua. Yang aktif memakai aksen penuh; yang sedang
      disorot naik mendekati warna tulisan biasa; sisanya diredupkan. Tanpa
      tingkat tengah, tab yang bisa ditekan tidak memberi tanda apa pun sampai
      benar-benar ditekan.
    */
    final Color warnaTulisan = widget.aktif
        ? aksen
        : (dasar?.color ?? Colors.white)
            .withValues(alpha: _disorot ? 0.92 : 0.55);

    return MouseRegion(
      cursor: widget.aktif ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.aktif ? null : widget.onTekan,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.aktif ? aksen : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: dasar?.copyWith(
              color: warnaTulisan,
              letterSpacing: 0.3,
              fontWeight: widget.aktif ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
