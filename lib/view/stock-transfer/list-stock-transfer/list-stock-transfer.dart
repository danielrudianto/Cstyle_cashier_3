import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/list-stock-transfer/components/list-stock-transfer-detail.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListStockTransfer extends StatefulWidget {
  const ListStockTransfer({super.key});

  @override
  State<ListStockTransfer> createState() => _ListStockTransferState();
}

class _ListStockTransferState extends State<ListStockTransfer> {
  List<StockTransferFetchmodel> stockTransfers = [];
  int count = 0;
  int page = 1;

  _fetchStockTransfer() async {
    var fetchedStockTransfers = await StockTransferFetchmodel.fetchCreated(
      page,
    );

    setState(() {
      stockTransfers = fetchedStockTransfers['data'];
      count = fetchedStockTransfers['count'];
    });
  }

  @override
  void initState() {
    _fetchStockTransfer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        /*
          Halaman ini dulu terbuka langsung ke tabel — tanpa judul, tanpa
          keterangan, dan tanpa jumlah. Sekarang memakai kepala halaman dan
          label bagian yang sama dengan daftar anggota dan halaman kelola.
        */
        const KepalaHalaman(
          penanda: "INVENTORY",
          judul: "Transfer list",
          keterangan: "Every stock transfer this store has requested or "
              "been asked for.",
        ),
        Bagian(
          label: stockTransfers.isEmpty
              ? "TRANSFERS"
              : "TRANSFERS · ${NumberFormat.decimalPattern("en-US").format(count)}",
        ),
        /*
          TINGGI TETAP DIBUANG.

          Tabelnya dulu dipatok setinggi layar dikurangi sebuah angka tetap,
          dengan penggulirnya sendiri di dalamnya. Angka itu menghitung
          tinggi segala sesuatu di atasnya — dan begitu satu baris
          ditambahkan di atas, ia menjadi salah tanpa ada yang memberi tahu:
          tabelnya tetap setinggi itu, dan yang berada DI BAWAHNYA —
          perpindahan halaman — terdorong keluar layar.

          Sekarang tabelnya setinggi isinya dan halamannya sendiri yang
          menggulir, jadi tidak ada lagi angka yang harus ikut diperbarui
          setiap kali sesuatu ditambahkan di atasnya.
        */
        /*
          Melebar penuh. Pembungkus lebar ini sempat ikut terbuang bersama
          tinggi tetapnya, dan tanpa batasan lebar DataTable menyusut ke lebar
          isinya — tabel yang berhenti di tengah halaman.
        */
        /*
          dividerThickness: 0 TIDAK meniadakan garisnya.

          DataTable menyusun hiasan barisnya dengan BorderSide(width:
          dividerThickness), dan di Flutter lebar nol berarti "setipis mungkin",
          bukan "tidak ada". Jadi garis antarbarisnya tetap tergambar — itulah
          garis yang masih terlihat meski ketebalannya sudah disetel nol.

          Yang benar-benar meniadakannya adalah warnanya, dan warnanya diambil
          DataTable dari Theme.dividerColor — jadi ditimpa di sini, hanya untuk
          tabel ini.
        */
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            // Jalur yang benar-benar dibaca DataTable pada Material 3.
            dividerTheme: const DividerThemeData(color: Colors.transparent),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              showCheckboxColumn: false,
              /*
                          Tanpa garis antarbaris, dan barisnya direnggangkan —
                          sama seperti daftar anggota. Dua puluh baris berarti dua
                          puluh garis sejajar, dan mata membacanya sebagai kisi.
                        */
              dividerThickness: 0,
              border: const TableBorder(),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              headingRowHeight: 44,
              headingRowColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    "NAME",
                    style: gayaKode(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "REQUEST FROM",
                    style: gayaKode(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "REQUEST TO",
                    style: gayaKode(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "CREATED BY",
                    style: gayaKode(context),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "CREATED AT",
                    style: gayaKode(context),
                  ),
                ),
              ],
              rows: stockTransfers.isEmpty == true
                  ? [
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              "No data",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const DataCell(
                            Text(""),
                          ),
                          const DataCell(
                            Text(""),
                          ),
                          const DataCell(
                            Text(""),
                          ),
                          const DataCell(
                            Text(""),
                          ),
                        ],
                      ),
                    ]
                  : stockTransfers
                      .map(
                        (stockTransfer) => DataRow(
                          selected: false,
                          onSelectChanged: (value) {
                            // show dialog
                            bukaDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Stock Transfer Detail"),
                                  content: ListStockTransferDetail(
                                    id: stockTransfer.id!,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          cells: [
                            DataCell(
                              /* Nomor transfernya kode, bukan kalimat. */
                              Text(
                                stockTransfer.name,
                                style: gayaKode(context, ukuran: 13).copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                stockTransfer.requestFrom == null
                                    ? "Office"
                                    : stockTransfer.requestFrom!['name'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DataCell(
                              Text(
                                stockTransfer.requestTo == null
                                    ? "Office"
                                    : stockTransfer.requestTo!['name'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DataCell(
                              Text(
                                stockTransfer.createdBy,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat("dd MMM yyyy HH:mm")
                                    .format(stockTransfer.createdAt),
                                /* Kolom tanggal berbaris lurus. */
                                style: gayaKode(context, ukuran: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        PaginationComponent(
          pageIndex: page - 1,
          pageSize: 10,
          dataCount: count,
          onPageChange: (newPage) {
            setState(() {
              page = newPage + 1;
            });
            _fetchStockTransfer();
          },
        ),
      ],
    );
  }
}
