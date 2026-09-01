import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:flutter/material.dart';

/// Memilih toko atau kantor yang akan mengirimkan stok.
///
/// APA YANG KURANG DARI DAFTAR NAMA SAJA.
///
/// Bentuk sebelumnya hanya menampilkan nama, dan nama-nama itu berawalan sama
/// semua — "CSTYLE CANGGU", "CSTYLE PERERENAN", "CSTYLE UBUD". Yang membedakan
/// baru muncul di kata kedua, jadi memilih berarti membaca setiap baris sampai
/// selesai. Alamatnya ditambahkan karena itulah yang benar-benar dipakai orang
/// untuk mengenali cabang, dan lingkaran berwarna memberi satu titik tetap
/// untuk melompat antarbaris.
///
/// Tingginya juga tidak lagi dipatok 300 piksel. Enam toko memenuhi lebih dari
/// itu, jadi daftarnya menggulir di dalam kotak yang tidak punya alasan untuk
/// sempit.
class StoreSelector extends StatefulWidget {
  const StoreSelector({super.key});

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  bool isLoading = true;
  List<StoreModel> stores = [];

  _fetchStores() {
    StoreModel.fetchStores().then((fetchedStores) {
      if (!mounted) return;
      setState(() {
        stores = fetchedStores;
      });
    }).catchError((error) {
      LoggerUtils().log(error, LogType.error);
      if (!mounted) return;
      Navigator.pop(context);
    }).whenComplete(() {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      width: 460,
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: BoxDecoration(
        color: tema.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*
            Kepala dialog duduk di permukaan yang sama dengan isinya. Bilah ungu
            setinggi 80 piksel yang dulu ada di sini memberi warna paling
            menonjol di layar kepada satu-satunya bagian yang tidak perlu
            dikerjakan siapa pun.
          */
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 10, 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Send from",
                    style: tema.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: "Close",
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Text(
              "Which store, or the office, should send the stock.",
              style: tema.textTheme.bodySmall,
            ),
          ),
          Divider(height: 1, color: tema.dividerColor),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(),
            )
          else if (stores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 22),
              child: Text(
                "No stores available.",
                style: tema.textTheme.bodyMedium,
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final toko = stores[index];
                  return _BarisToko(
                    nama: toko.name,
                    alamat: toko.address,
                    /*
                      Warnanya diturunkan dari kodenya kalau ada. Kantor pusat
                      tidak punya kode, jadi namanya yang dipakai — cukup, karena
                      hanya ada satu.
                    */
                    kunci: (toko.code == null || toko.code!.isEmpty)
                        ? toko.name
                        : toko.code!,
                    onPilih: () => Navigator.pop(context, toko),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Satu toko pada daftar pemilih.
class _BarisToko extends StatefulWidget {
  final String nama;
  final String alamat;
  final String kunci;
  final VoidCallback onPilih;

  const _BarisToko({
    required this.nama,
    required this.alamat,
    required this.kunci,
    required this.onPilih,
  });

  @override
  State<_BarisToko> createState() => _BarisTokoState();
}

class _BarisTokoState extends State<_BarisToko> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _disorot = true),
      onExit: (_) => setState(() => _disorot = false),
      child: GestureDetector(
        onTap: widget.onPilih,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Gerak.kilat,
          curve: Gerak.masuk,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: _disorot
                ? warna.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              AvatarInisial(nama: widget.nama, kunci: widget.kunci, ukuran: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.alamat.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.alamat,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: warna.onSurface.withValues(alpha: _disorot ? 0.7 : 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
