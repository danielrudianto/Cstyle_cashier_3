import 'dart:async';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/view/member-list/components/member-detail.dart';
import 'dart:ui' show FontFeature;
import 'package:cstyle_cashier_3/utils/theme.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        const SizedBox(
          height: 25,
        ),
        /*
          Disamakan dengan pencarian barang di layar jual: terisi samar,
          bersudut, lebarnya dibatasi. Bentuk lama memakai label melayang
          seukuran isian dan garis tepi dividerColor — yang sejak pemisah
          diturunkan ke 7% menjadi hampir tak terlihat.
        */
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
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
        const SizedBox(
          height: 15,
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
                headingRowColor: WidgetStatePropertyAll(
                  Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.03),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      "NAME",
                      style: gayaLabelKolom(context),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "CODE",
                      style: gayaLabelKolom(context),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "EMAIL",
                      style: gayaLabelKolom(context),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "PHONE",
                      style: gayaLabelKolom(context),
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
                                        return Container(
                                          width: 400,
                                          padding: const EdgeInsets.all(20),
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              ListTile(
                                                onTap: e.email == ""
                                                    ? null
                                                    : () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: e.email,
                                                          ),
                                                        );

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Successfully copied email.",
                                                            ),
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ),
                                                        );

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                leading: Icon(
                                                  Icons.copy,
                                                  color: e.email == ""
                                                      ? Theme.of(context)
                                                          .disabledColor
                                                      : Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                ),
                                                title: Text(
                                                  "Copy email",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: e.email == ""
                                                            ? Theme.of(context)
                                                                .disabledColor
                                                            : Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                      ),
                                                ),
                                              ),
                                              ListTile(
                                                onTap: e.phoneNumber == ""
                                                    ? null
                                                    : () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: e.email,
                                                          ),
                                                        );

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Successfully copied phone number.",
                                                            ),
                                                            duration: Duration(
                                                                seconds: 1),
                                                          ),
                                                        );

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                leading: Icon(
                                                  Icons.copy,
                                                  color: e.phoneNumber == ""
                                                      ? Theme.of(context)
                                                          .disabledColor
                                                      : Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                ),
                                                title: Text(
                                                  "Copy phone number",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: e.phoneNumber ==
                                                                ""
                                                            ? Theme.of(context)
                                                                .disabledColor
                                                            : Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                      ),
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: e.code,
                                                    ),
                                                  );

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Successfully copied code.",
                                                      ),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );

                                                  Navigator.of(context).pop();
                                                },
                                                leading: Icon(
                                                  Icons.copy,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                                title: Text(
                                                  "Copy code",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: e.email == ""
                                                            ? Theme.of(context)
                                                                .disabledColor
                                                            : Theme.of(context)
                                                                .iconTheme
                                                                .color,
                                                      ),
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pop("detail");
                                                },
                                                leading: Icon(
                                                  Icons.info_outline,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                                title: Text(
                                                  "View detail",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).then((value) {
                                    if (value == 'detail') {
                                      // show dialog detail
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              "Member Detail",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                            ),
                                            // content table
                                            content: MemberDetailPage(e.code),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Close",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  });
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
                                      style: gayaLabelKolom(context),
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
