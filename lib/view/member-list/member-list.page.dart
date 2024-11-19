import 'dart:async';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/view/member-list/components/member-detail.dart';
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
        SizedBox(
          height: 50,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              label: Text(
                "Search member",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              prefix: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
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
                dividerThickness: 0.75,
                // border color only horizontal
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  verticalInside: BorderSide.none,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      "Name",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Code",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Email",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Phone",
                      style: Theme.of(context).textTheme.headlineMedium,
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
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
                                      e.email == "" ? "N/A" : e.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
                                      e.phoneNumber == ""
                                          ? "N/A"
                                          : e.phoneNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
