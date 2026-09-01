import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Panel bersama halaman kirim dan terima transfer.
///
/// SATU SUMBER, BUKAN DUA SALINAN.
///
/// Kedua halaman itu identik di tujuh puluh persen bentuknya: daftar transfer
/// bernomor halaman di kiri yang salah satunya dipilih, dan rinciannya di
/// kanan. Sebelum ini keduanya menyalin bentuk itu masing-masing — kotak
/// bergaris, bilah judul hitam, ListTile polos — dan setiap perbaikan harus
/// diketik dua kali atau, seperti yang terjadi, tidak dua-duanya.

/// Daftar transfer yang menunggu dipilih.
class DaftarTransfer extends StatelessWidget {
  final List<StockTransferFetchmodel> transfers;
  final String? terpilihID;
  final bool memuat;
  final int page;
  final int dataCount;
  final ValueChanged<StockTransferFetchmodel> onPilih;
  final ValueChanged<int> onPageChange;

  const DaftarTransfer({
    super.key,
    required this.transfers,
    required this.terpilihID,
    required this.memuat,
    required this.page,
    required this.dataCount,
    required this.onPilih,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 340,
          /*
            Pergantian memuat -> isi disilangkan, bukan ditukar sekejap.
            Pindah halaman lewat pagination memicu jalur yang sama, jadi
            tabelnya tidak lagi berkedip putih setiap ganti halaman.
          */
          child: AnimatedSwitcher(
            duration: Gerak.cepat,
            switchInCurve: Gerak.masuk,
            switchOutCurve: Gerak.keluar,
            child: memuat
                ? const Center(
                    key: ValueKey("memuat"),
                    child: CircularProgressIndicator(),
                  )
                : transfers.isEmpty
                    ? Center(
                        key: const ValueKey("kosong"),
                        child: Text(
                          "Nothing waiting here.",
                          style: tema.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey("hal$page"),
                        itemCount: transfers.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: tema.dividerColor,
                        ),
                        itemBuilder: (context, index) {
                          final transfer = transfers[index];
                          return _BarisTransfer(
                            transfer: transfer,
                            terpilih: transfer.id != null &&
                                transfer.id == terpilihID,
                            onPilih: () => onPilih(transfer),
                          );
                        },
                      ),
          ),
        ),
        const SizedBox(height: 10),
        PaginationComponent(
          pageIndex: page - 1,
          dataCount: dataCount,
          pageSize: 10,
          onPageChange: onPageChange,
        ),
      ],
    );
  }
}

/// Satu transfer pada daftar.
class _BarisTransfer extends StatefulWidget {
  final StockTransferFetchmodel transfer;
  final bool terpilih;
  final VoidCallback onPilih;

  const _BarisTransfer({
    required this.transfer,
    required this.terpilih,
    required this.onPilih,
  });

  @override
  State<_BarisTransfer> createState() => _BarisTransferState();
}

class _BarisTransferState extends State<_BarisTransfer> {
  bool _disorot = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;
    final asal = widget.transfer.requestFrom == null
        ? "Office"
        : widget.transfer.requestFrom!['name'];

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          /*
            Yang terpilih ditandai LATAR aksen tipis dan garis di tepi kiri —
            tanda yang bertahan saat mata pergi ke panel rincian dan kembali.
            Sorot hover lebih redup daripada tanda terpilih supaya keduanya
            tidak tertukar.
          */
          decoration: BoxDecoration(
            color: widget.terpilih
                ? tema.secondaryHeaderColor.withValues(alpha: 0.08)
                : _disorot
                    ? warna.onSurface.withValues(alpha: 0.04)
                    : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: widget.terpilih
                    ? tema.secondaryHeaderColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.transfer.name, style: gayaKode(context)),
                    const SizedBox(height: 3),
                    Text(
                      "Requested from $asal",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat("d MMM").format(widget.transfer.createdAt),
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rincian transfer yang sedang dipilih.
class RincianTransfer extends StatelessWidget {
  final StockTransferFetchmodel? transfer;
  final bool memuat;

  const RincianTransfer({
    super.key,
    required this.transfer,
    required this.memuat,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return AnimatedSwitcher(
      duration: Gerak.cepat,
      switchInCurve: Gerak.masuk,
      switchOutCurve: Gerak.keluar,
      child: memuat
          ? const Padding(
              key: ValueKey("memuat"),
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          : transfer == null
              ? Padding(
                  key: const ValueKey("kosong"),
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Pick a transfer from the list to see what it holds.",
                    style: tema.textTheme.bodyMedium,
                  ),
                )
              : _isi(context, transfer!),
    );
  }

  Widget _isi(BuildContext context, StockTransferFetchmodel transfer) {
    final tema = Theme.of(context);
    final asal =
        transfer.requestFrom == null ? "Office" : transfer.requestFrom!['name'];

    return Column(
      key: ValueKey(transfer.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(transfer.name, style: gayaKode(context, ukuran: 14)),
        const SizedBox(height: 14),
        BarisMeta(
          isi: [
            Meta("FROM", asal),
            Meta("BY", transfer.createdBy),
            Meta("DATE", DateFormat("d MMM yyyy").format(transfer.createdAt)),
          ],
        ),
        if (transfer.note.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          /*
            Catatannya baru ditampilkan sekarang. Modelnya selalu membawanya,
            tetapi kedua halaman lama tidak pernah meletakkannya di layar —
            padahal justru di sinilah pengirim membaca pesan si peminta.
          */
          Text(
            transfer.note,
            style: tema.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 6),
        const JudulBagian("ITEMS", atas: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transfer.items.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: tema.dividerColor,
          ),
          itemBuilder: (context, index) {
            final barang = transfer.items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(barang.reference, style: gayaKode(context)),
                        const SizedBox(height: 2),
                        Text(
                          barang.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${NumberFormat("#,##0").format(barang.quantity)} pcs",
                    style: gayaKode(context, ukuran: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
