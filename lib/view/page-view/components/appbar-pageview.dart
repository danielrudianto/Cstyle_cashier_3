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
                  child: Center(
                    child: _PemilihMode(
                      terpilih: page,
                      onPilih: (i) => changePage(i),
                    ),
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

/// Pemilih mode: menjual, atau mengelola.
///
/// DULU DUA TAB BERGARIS BAWAH BERJUDUL "Dashboard" DAN "Store".
///
/// Dua hal yang keliru di situ. Pertama namanya: "Dashboard" tidak menyebut
/// bahwa itu layar tempat kasir menjual sepanjang hari, dan "Store" tidak
/// menyebut bahwa isinya pengaturan — statistik toko, sinkronisasi stok,
/// pengaturan tema dan pencetak, keanggotaan, persediaan. Keduanya nama tempat,
/// bukan nama pekerjaan.
///
/// Kedua bentuknya. Tab bergaris bawah menyatakan "ini beberapa halaman dari
/// satu bagian yang sama". Padahal ini bukan itu — ini dua MODE yang saling
/// meniadakan: satu dipakai menghadap pembeli, satu lagi tidak. Bentuk yang
/// menyatakan hal itu adalah sakelar bersegmen: satu wadah, satu segmen
/// menyala, dan jelas bahwa memilih yang satu berarti meninggalkan yang lain.
///
/// Ikonnya ditambahkan karena pada dua pilihan yang berdampingan, lambang jauh
/// lebih cepat dikenali daripada kata — dan kasir menekan ini berkali-kali
/// sehari tanpa membacanya lagi.
class _PemilihMode extends StatelessWidget {
  final int terpilih;
  final ValueChanged<int> onPilih;

  const _PemilihMode({required this.terpilih, required this.onPilih});

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
          _Segmen(
            ikon: Icons.point_of_sale_outlined,
            label: "Sell",
            aktif: terpilih == 0,
            onTekan: () => onPilih(0),
          ),
          const SizedBox(width: 3),
          _Segmen(
            ikon: Icons.storefront_outlined,
            label: "Manage",
            aktif: terpilih == 1,
            onTekan: () => onPilih(1),
          ),
        ],
      ),
    );
  }
}

/// Satu segmen pada [_PemilihMode].
///
/// Dijadikan satu widget karena versi tab sebelumnya menuliskan keduanya dua
/// kali, dan salinannya sudah menyimpang: yang aktif pada tab pertama memakai
/// ungu yang dipatok, yang kedua membacanya dari tema.
class _Segmen extends StatefulWidget {
  final IconData ikon;
  final String label;
  final bool aktif;
  final VoidCallback onTekan;

  const _Segmen({
    required this.ikon,
    required this.label,
    required this.aktif,
    required this.onTekan,
  });

  @override
  State<_Segmen> createState() => _SegmenState();
}

class _SegmenState extends State<_Segmen> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    /*
      Tiga tingkat, bukan dua. Yang aktif berlatar aksen; yang disorot mendapat
      latar samar; sisanya polos. Tanpa tingkat tengah, segmen yang bisa ditekan
      tidak memberi tanda apa pun sampai benar-benar ditekan.
    */
    final Color latar = widget.aktif
        ? warna.primary
        : (_disorot
            ? warna.onSurface.withValues(alpha: 0.07)
            : Colors.transparent);

    final Color depan = widget.aktif
        ? warna.onPrimary
        : warna.onSurface.withValues(alpha: _disorot ? 0.92 : 0.6);

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: latar,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.ikon, size: 17, color: depan),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: depan,
                  fontSize: 13,
                  letterSpacing: 0.3,
                  fontWeight: widget.aktif ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
