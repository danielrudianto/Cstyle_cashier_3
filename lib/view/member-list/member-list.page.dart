import 'dart:async';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:cstyle_cashier_3/view/member-list/components/member-actions.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  int page = 1;
  List<MemberModel> members = [];
  int memberCount = 0;
  TextEditingController controller = TextEditingController();
  Timer? timer;

  _fetchMembers(int selectedPage) {
    setState(() {
      page = selectedPage;
    });

    MemberModel.fetch(page, controller.text).then((value) {
      setState(() {
        members = List<MemberModel>.from(value['data']);
        memberCount = value['count'];
      });
    });
  }

  @override
  void initState() {
    _fetchMembers(1);
    controller.addListener(() {
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(const Duration(milliseconds: 500), () {
        _fetchMembers(1);
      });
    });
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
          Kepala halaman yang sama dengan halaman kelola. Sebelumnya daftar
          ini dibuka langsung ke kolom pencarian, tanpa satu pun kalimat yang
          menyebutkan halaman apa yang sedang terbuka.
        */
        const KepalaHalaman(
          penanda: "MEMBERSHIPS",
          judul: "Members",
          keterangan: "Everyone registered at this store, with the contact "
              "details kept for them.",
        ),
        /*
          BAHASA YANG SAMA DENGAN HALAMAN KELOLA.

          Label monospace di kiri, pencarian di kanan barisan yang sama,
          garis rambut di bawah keduanya. Dulu kolom pencariannya berdiri
          sendiri di atas tabel tanpa apa pun yang menyebutkan daftar ini
          daftar apa — dan jumlah anggotanya tidak tertulis di mana pun,
          padahal itu angka pertama yang ingin diketahui saat membukanya.
        */
        Bagian(
          atas: 34,
          label: members.isEmpty
              ? "MEMBERS"
              : "MEMBERS · ${NumberFormat.decimalPattern("en-US").format(memberCount)}",
          aksi: SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Search members",
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 286,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                showCheckboxColumn: false,
                /*
                  Tanpa garis antarbaris, sama seperti tabel barang: dua
                  puluh baris berarti dua puluh garis sejajar, dan mata
                  membacanya sebagai kisi. Pemisahnya jarak antarbaris.
                */
                dividerThickness: 0,
                border: const TableBorder(),
                /*
                  Tanpa latar pada baris kepala. Bagian di atasnya sudah
                  menutup dengan garis rambut, dan menambahkan bidang abu di
                  bawahnya membuat tabelnya kembali terlihat berkotak.
                */
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
                      "CODE",
                      style: gayaKode(context),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "EMAIL",
                      style: gayaKode(context),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "PHONE",
                      style: gayaKode(context),
                    ),
                  ),
                ],
                rows: members.isEmpty
                    ? [
                        DataRow(cells: [
                          DataCell(
                            Text(
                              "Data not found.",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                        ])
                      ]
                    : [
                        ...members.map(
                          (e) {
                            return DataRow(
                              selected: false,
                              onSelectChanged: (value) {
                                if (value == true) {
                                  // open bottom sheet
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return MemberActions(anggota: e);
                                      }).then((value) {});
                                }
                              },
                              cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      e.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      /* Nama yang dicari; ia memimpin barisnya. */
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      e.code,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      /* Penanda, bukan isi: diperlakukan sebagai label. */
                                      style: gayaKode(context),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 10,
                                    ),
                                    /*
                                      Dulu "N/A", ditulis sama tegasnya dengan
                                      alamat surel yang ada. Pada halaman berisi
                                      dua puluh anggota yang kebanyakan tidak
                                      punya surel, itu berarti selusin "N/A"
                                      berjajar yang lebih menarik mata daripada
                                      data yang benar-benar ada. Ketiadaan
                                      sebaiknya terlihat sebagai ketiadaan.
                                    */
                                    child: Text(
                                      e.email == "" ? "—" : e.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: e.email == ""
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.35)
                                                : null,
                                          ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      e.phoneNumber == "" ? "—" : e.phoneNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                        color: e.phoneNumber == ""
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.35)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        PaginationComponent(
          pageIndex: page - 1,
          dataCount: memberCount,
          pageSize: 20,
          onPageChange: (value) {
            _fetchMembers(value + 1);
          },
        )
      ],
    );
  }
}
