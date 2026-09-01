import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/model/model.countries.dart';
import 'package:cstyle_cashier_3/model/model.daily-report.model.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/view/check-stock/check-stock.page.dart';
import 'package:cstyle_cashier_3/view/history/history.page.dart';
import 'package:cstyle_cashier_3/view/member-list/member-list.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/create-stock-transfer/create-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/list-stock-transfer/list-stock-transfer.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/receive-stock-transfer/receive-stock-transfer.page.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/send-stock-transfer/send-stock.transfer.page.dart';
import 'package:cstyle_cashier_3/view/store/components/store-dashboard.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

// ignore: camel_case_types
enum language {
  // ignore: constant_identifier_names
  EN,
  // ignore: constant_identifier_names
  ID,
}

class _StorePageState extends State<StorePage> {
  int selectedMenu = 0;
  bool isLoading = false;

  Future<void> fetchByCode(String code) async {
    setState(() {
      isLoading = true;
    });
    try {
      var member = await MemberModel.fetchByCode(code);
      if (member != null) {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Code",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.code,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Name",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Nationality",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.nationality ?? "N/A",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              member.email == "" ? "N/A" : member.email,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.copy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Phone",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Text(
                              member.phoneNumber == ""
                                  ? "N/A"
                                  : member.phoneNumber,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.copy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Birthday",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.birthday == null
                            ? "N/A"
                            : DateFormat("dd/MM/yyyy").format(member.birthday!),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {}
    } catch (error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  preOpenAddMember() {
    showModalBottomSheet<UserModel?>(
        // ignore: use_build_context_synchronously
        context: context,
        showDragHandle: false,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return const SelectEmployee();
        }).then((value) {
      if (value != null) {
        openAddMember(value.id);
      }
    });
  }

  openAddMember(String userID) {
    TextEditingController codeEditingController = TextEditingController();
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController memberNationalityController = TextEditingController();
    TextEditingController memberEmailController = TextEditingController();
    TextEditingController memberPhoneNumberController = TextEditingController();
    TextEditingController memberBirthdayController = TextEditingController();
    CountryModel? nationality;
    language? selectedLanguage = language.ID;
    bool isSubmitting = false;

    addMember() async {
      setState(() {
        isSubmitting = true;
      });

      try {
        if (codeEditingController.text.isEmpty) {
          throw Exception("Code cannot be empty");
        }

        if (nameEditingController.text.isEmpty) {
          throw Exception("Name cannot be empty");
        }

        if (memberEmailController.text.isEmpty &&
            memberPhoneNumberController.text.isEmpty) {
          throw Exception(
              "Please insert either phone number or email, or both.");
        }

        var member = MemberModel(
          code: codeEditingController.text,
          name: nameEditingController.text,
          nationality: nationality?.code,
          email: memberEmailController.text,
          phoneNumber: memberPhoneNumberController.text,
          birthday: DateTime.now(),
          lang: selectedLanguage!,
          points: 0,
          createdBy: userID,
        );

        await member.create();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully created member"),
            duration: Duration(seconds: 1),
            showCloseIcon: true,
          ),
        );
        Navigator.pop(context);
      } catch (error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      } finally {
        setState(() {
          isSubmitting = false;
        });
      }
    }

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              surfaceTintColor: Theme.of(context).cardColor,
              backgroundColor: Theme.of(context).cardColor,
              child: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 400,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          // border color
                          border: Border.all(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Create new member",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: codeEditingController,
                              decoration: InputDecoration(
                                label: Text(
                                  "Code",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: nameEditingController,
                              decoration: InputDecoration(
                                label: Text(
                                  "Name",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Autocomplete<CountryModel>(
                              displayStringForOption: (CountryModel option) =>
                                  "${option.name} (${option.code})",
                              initialValue: TextEditingValue(
                                  text: (nationality != null)
                                      ? "${nationality!.name} (${nationality!.code})"
                                      : ""),
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController
                                      fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted) {
                                memberNationalityController =
                                    fieldTextEditingController;
                                return TextField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  enabled: (nationality == null),
                                  decoration: InputDecoration(
                                    label: Text(
                                      "Nationality",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<CountryModel>.empty();
                                }

                                return availableCountries
                                    .where((CountryModel option) {
                                  return option.name.toLowerCase().contains(
                                          textEditingValue.text
                                              .toLowerCase()) ||
                                      option.name.toLowerCase().startsWith(
                                          textEditingValue.text.toLowerCase());
                                });
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<CountryModel>
                                      onSelected,
                                  Iterable<CountryModel> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    child: Container(
                                      width: 370,
                                      color: Theme.of(context).canvasColor,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(10.0),
                                        itemCount: options.length >= 5
                                            ? 5
                                            : options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final CountryModel option =
                                              options.elementAt(index);
                                          return GestureDetector(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: ListTile(
                                                title: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "${option.name} (${option.code})",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Flag.fromString(
                                                      option.code,
                                                      height: 20,
                                                      width: 30,
                                                      fit: BoxFit.fill,
                                                      replacement:
                                                          const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onSelected: (value) {
                                setState(() {
                                  nationality = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextButton(
                              onPressed: nationality == null
                                  ? null
                                  : () {
                                      setState(() {
                                        nationality = null;
                                        memberNationalityController.text = "";
                                      });
                                    },
                              child: Text(
                                "Remove nationality",
                                style: TextStyle(
                                  color: nationality == null
                                      ? Theme.of(context).disabledColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: memberPhoneNumberController,
                              decoration: InputDecoration(
                                label: Text(
                                  "Phone number",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: memberEmailController,
                              decoration: InputDecoration(
                                label: Text(
                                  "Email",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Please insert either phone number or email, or both.",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text(
                                  "Birthday",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              onTap: () {
                                var firstDate = DateTime.now();
                                var lastDate = DateTime.now();

                                firstDate = DateTime(firstDate.year - 100);
                                lastDate = DateTime(lastDate.year - 18);
                                showDatePicker(
                                        // container color
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? ColorScheme.dark(
                                                      surface: Theme.of(context)
                                                          .canvasColor,
                                                    )
                                                  : ColorScheme.light(
                                                      surface: Theme.of(context)
                                                          .canvasColor,
                                                    ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .secondaryHeaderColor,
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                        context: context,
                                        firstDate: firstDate,
                                        lastDate: lastDate)
                                    .then((value) {
                                  if (value == null) {
                                    return;
                                  } else {
                                    memberBirthdayController.text =
                                        DateFormat("dd/MM/yyyy").format(value);
                                  }
                                }).catchError((error) {
                                  LoggerUtils()
                                      .log(error.toString(), LogType.error);
                                });
                              },
                              controller: memberBirthdayController,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            RadioListTile<language>(
                                title: Text(
                                  "English",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                groupValue: selectedLanguage,
                                value: language.EN,
                                activeColor:
                                    Theme.of(context).secondaryHeaderColor,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value;
                                  });
                                }),
                            RadioListTile<language>(
                                title: Text(
                                  "Bahasa",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                groupValue: selectedLanguage,
                                value: language.ID,
                                activeColor:
                                    Theme.of(context).secondaryHeaderColor,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value;
                                  });
                                }),
                            const SizedBox(
                              height: 15,
                            ),
                            InkWell(
                              onTap: isSubmitting
                                  ? null
                                  : () {
                                      addMember();
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 25,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSubmitting
                                      ? Theme.of(context).disabledColor
                                      : Theme.of(context).secondaryHeaderColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  openDailyReport() {
    DailyReportModel.downloadDailyReport().then((value) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                height: 620,
                width: 480,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        // border width 0
                        border: Border.all(
                          width: 0,
                          color: Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Daily Report",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: Theme.of(context).textTheme.labelSmall,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              Text(
                                DateFormat("dd/MM/yyyy").format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyLarge,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Sales : Rp. ${NumberFormat("#,##0.00").format(value['payments'].fold(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element['value'],
                                ))}",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textScaler: const TextScaler.linear(1.1),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: value['payments'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      value['payments'][index]['type']
                                          .toString()
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                      textScaler: const TextScaler.linear(1.1),
                                    ),
                                    subtitle: Text(
                                      NumberFormat("#,##0.00").format(
                                          value['payments'][index]['value']),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textScaler: const TextScaler.linear(1.1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      child: Row(children: [
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            String text = "";
                            num total = 0.0;
                            for (var item in value['payments']) {
                              text +=
                                  "${item['type'].toString().toUpperCase()}: ${NumberFormat("#,##0.00").format(item['value'])}\n";
                              total += item['value'];
                            }
                            text +=
                                "Total: ${NumberFormat("#,##0.00").format(total)}";
                            Clipboard.setData(ClipboardData(text: text));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Copied to clipboard"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Text(
                            "Copy to clipboard",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          });
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Widget get currentPage {
    switch (selectedMenu) {
      case 0:
        return const StoreDashboard();
      case 1:
        return const MemberListPage();
      case 2:
        return const CreateStockTransferPage();
      case 3:
        return const SendStockTransferPage();
      case 4:
        return const ReceiveStockTransferPage();
      case 5:
        return const ListStockTransfer();
      case 6:
        return const CheckStockPage();
      case 7:
        return const HistoryPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              color: Theme.of(context).cardColor,
            ),
            width: 250,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        onTap: selectedMenu == 0
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 0;
                                });
                              },
                        title: Text(
                          "Home",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 0
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.dashboard_outlined,
                          color: selectedMenu == 0
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      ListTile(
                        title: Text(
                          "Memberships",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          preOpenAddMember();
                        },
                        title: Text(
                          "Add member",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        leading: Icon(
                          Icons.add,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 1
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 1;
                                });
                              },
                        // add new member
                        title: Text(
                          "View members",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: selectedMenu == 1
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.list,
                          color: selectedMenu == 1
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).dividerColor,
                      ),
                      ListTile(
                        title: Text(
                          "Inventory",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 2
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 2;
                                });
                              },
                        title: Text(
                          "Create transfer",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 2
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.add,
                          color: selectedMenu == 2
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 3
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 3;
                                });
                              },
                        title: Text(
                          "Send transfer",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 3
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.call_made,
                          color: selectedMenu == 3
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 4
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 4;
                                });
                              },
                        title: Text(
                          "Receive transfer",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 4
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.call_received,
                          color: selectedMenu == 4
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 5
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 5;
                                });
                              },
                        title: Text(
                          "List",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 5
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.list,
                          color: selectedMenu == 5
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).dividerColor,
                      ),
                      ListTile(
                        title: Text(
                          "Utilities",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          openDailyReport();
                        },
                        title: Text(
                          "Daily Report",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        leading: Icon(
                          Icons.report,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 6
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 6;
                                });
                              },
                        title: Text(
                          "Stock list",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 6
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.list,
                          color: selectedMenu == 6
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      ListTile(
                        onTap: selectedMenu == 7
                            ? null
                            : () {
                                setState(() {
                                  selectedMenu = 7;
                                });
                              },
                        title: Text(
                          "History",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: selectedMenu == 7
                                        ? Theme.of(context).secondaryHeaderColor
                                        : null,
                                  ),
                        ),
                        leading: Icon(
                          Icons.history,
                          color: selectedMenu == 7
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RawScrollbar(
              controller: scrollController,
              thumbColor: const Color.fromARGB(255, 161, 121, 220),
              radius: const Radius.circular(8.0),
              thickness: 8.0,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: ResponsiveUtils.getContainerSize(context),
                      maxWidth: ResponsiveUtils.getContainerSize(context),
                      minHeight: MediaQuery.of(context).size.height - 100,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        child: currentPage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
