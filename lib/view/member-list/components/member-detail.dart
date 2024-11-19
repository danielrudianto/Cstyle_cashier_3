import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MemberDetailPage extends StatefulWidget {
  String code;
  MemberDetailPage(this.code, {super.key});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  bool isLoading = false;
  MemberModel? member;

  @override
  void initState() {
    MemberModel.fetchByCode(widget.code).then((value) {
      setState(() {
        member = value;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return member == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Name",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                member!.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Code",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: member!.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Code copied to clipboard"),
                          duration: Duration(
                            seconds: 1,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      member!.code,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Phone",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                member!.phoneNumber == "" ? "N/A" : member!.phoneNumber,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Email",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                member!.email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Birthday",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                member!.birthday == null
                    ? "N/A"
                    : DateFormat("dd MMM yyyy").format(member!.birthday!),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          );
    // ) DataTable(columns: const [
    //     DataColumn(label: Text('Name')),
    //     DataColumn(label: Text('Code')),
    //     DataColumn(label: Text('Phone')),
    //     DataColumn(label: Text('Email')),
    //     DataColumn(label: Text('Birthday')),
    //   ], rows: [
    //     DataRow(cells: [
    //       DataCell(Text(member!.name)),
    //       DataCell(Text(member!.code)),
    //       DataCell(Text(
    //           member!.phoneNumber == "" ? "N/A" : member!.phoneNumber)),
    //       DataCell(Text(member!.email)),
    //       DataCell(Text(member!.birthday == null
    //           ? "N/A"
    //           : DateFormat("dd MMM yyyy").format(member!.birthday!))),
    //     ])
    //   ]);
  }
}
