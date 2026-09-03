import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/view/history/components/bill-view.page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Riwayat nota yang sudah tercatat di server.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BillCodeModelFetch> bills = [];
  int count = 0;
  int page = 1;
  bool isLoading = true;

  _fetchBill() async {
    setState(() {
      isLoading = true;
    });

    try {
      var fetchedBills = await BillCodeModelFetch.fetchHistory(
        page,
      );

      setState(() {
        bills = fetchedBills['data'] as List<BillCodeModelFetch>;
        count = fetchedBills['count'];
      });
    } catch (e) {
      LoggerUtils().log("Error", LogType.error,
          error: e, stackTrace: StackTrace.current);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch data"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Membuka rincian satu nota.
  ///
  /// Dulu mengetuk baris membuka lembar bawah yang isinya SATU pilihan —
  /// "View bill" — yang barulah membuka rinciannya. Selembar penuh untuk
  /// sebuah menu beranggota satu; pilihannya sekarang diambilkan langsung.
  void _bukaNota(BillCodeModelFetch bill) {
    bukaDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 800,
            child: BillViewPage(id: bill.id),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _fetchBill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        const KepalaHalaman(
          penanda: "SALES",
          judul: "History",
          keterangan: "Every bill this store has recorded on the server, "
              "newest first.",
        ),
        Bagian(
          atas: 34,
          label: bills.isEmpty
              ? "BILLS"
              : "BILLS · ${NumberFormat.decimalPattern("en-US").format(count)}",
          child: AnimatedSwitcher(
            duration: Gerak.cepat,
            switchInCurve: Gerak.masuk,
            switchOutCurve: Gerak.keluar,
            child: isLoading
                ? const Padding(
                    key: ValueKey("memuat"),
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : bills.isEmpty
                    ? Padding(
                        key: const ValueKey("kosong"),
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No bills recorded yet.",
                          style: tema.textTheme.bodyMedium,
                        ),
                      )
                    : _tabel(context),
          ),
        ),
        const SizedBox(height: 6),
        PaginationComponent(
          pageIndex: page - 1,
          pageSize: 20,
          dataCount: count,
          onPageChange: (newPage) {
            setState(() {
              page = newPage + 1;
            });
            _fetchBill();
          },
        ),
      ],
    );
  }

  Widget _tabel(BuildContext context) {
    final tema = Theme.of(context);

    /*
      Perlakuan yang sama dengan tabel anggota: garis antarbaris dimatikan
      lewat Theme (dividerThickness: 0 hanya membuatnya setipis mungkin,
      bukan hilang), pemisahnya jarak, kepala kolomnya monospace.
    */
    return Theme(
      key: ValueKey("hal$page"),
      data: tema.copyWith(
        dividerColor: Colors.transparent,
        // Jalur yang benar-benar dibaca DataTable pada Material 3.
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          showCheckboxColumn: false,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          headingRowHeight: 44,
          dividerThickness: 0,
          border: const TableBorder(),
          headingRowColor: const WidgetStatePropertyAll(Colors.transparent),
          columns: [
            DataColumn(label: Text("DATE", style: gayaKode(context))),
            DataColumn(label: Text("BILL", style: gayaKode(context))),
            DataColumn(label: Text("MEMBER", style: gayaKode(context))),
            DataColumn(label: Text("CASHIER", style: gayaKode(context))),
            DataColumn(label: Text("RECORDED", style: gayaKode(context))),
          ],
          rows: bills
              .map(
                (bill) => DataRow(
                  onSelectChanged: (value) {
                    if (value == true) _bukaNota(bill);
                  },
                  cells: [
                    DataCell(
                      Text(
                        DateFormat("d MMM yyyy").format(bill.date),
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                    /*
                      Nomor nota monospace: dibaca huruf per huruf saat
                      dicocokkan dengan struk di tangan orang.
                    */
                    DataCell(Text(bill.name, style: gayaKode(context))),
                    DataCell(
                      bill.memberID == null
                          /*
                            Tanpa anggota dulu tertulis "NO" — yang terbaca
                            sebagai jawaban atas pertanyaan yang tidak
                            diajukan. Tanda pisah menyatakan kosong tanpa
                            berlagak menjawab.
                          */
                          ? Text(
                              "—",
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: tema.colorScheme.onSurface
                                    .withValues(alpha: 0.35),
                              ),
                            )
                          : Text(
                              bill.memberID!.name,
                              style: tema.textTheme.bodyMedium,
                            ),
                    ),
                    DataCell(
                      Text(
                        bill.createdBy.name,
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat("d MMM yyyy HH:mm").format(bill.createdAt),
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
