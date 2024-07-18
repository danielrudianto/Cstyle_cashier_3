// ignore_for_file: constant_identifier_names, camel_case_types

import 'package:cstyle_cashier_3/model/model.countries.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/select-employee.dart';
import 'package:cstyle_cashier_3/view/store/components/action-card.component.dart';
import 'package:cstyle_cashier_3/view/store/components/stat-card.component.dart';
import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

enum language {
  EN,
  ID,
}

class _StorePageState extends State<StorePage> {
  TextEditingController codeEditingController = TextEditingController();
  bool isLoading = false;
  int memberCount = 0;

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
      LoggerUtils().log(error.toString(), LogType.error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  preOpenAddMember() {
    showDialog<UserModel?>(
        context: context,
        builder: (context) {
          return const Dialog(
            child: SelectEmployee(),
          );
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
            const SnackBar(content: Text("Successfully created member")));
        Navigator.pop(context);
      } catch (error) {
        LoggerUtils().log(error.toString(), LogType.error);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
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
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 96, 99, 255),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Spacer(),
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
                            const Center(
                              child: Text("Create new member",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  )),
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
                              decoration: const InputDecoration(
                                labelText: "Code",
                                border: OutlineInputBorder(),
                                focusColor: Colors.black54,
                                hoverColor: Colors.black54,
                                focusedBorder: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: nameEditingController,
                              decoration: const InputDecoration(
                                labelText: "Name",
                                border: OutlineInputBorder(),
                                focusColor: Colors.black54,
                                hoverColor: Colors.black54,
                                focusedBorder: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black54,
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
                                  decoration: const InputDecoration(
                                    hintText: "Ex. Indonesia (ID)",
                                    labelText: "Nationality",
                                    border: OutlineInputBorder(),
                                    focusColor: Colors.black54,
                                    hoverColor: Colors.black54,
                                    focusedBorder: OutlineInputBorder(),
                                    labelStyle: TextStyle(
                                      color: Colors.black54,
                                    ),
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.black54,
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
                                      color: Colors.white,
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
                                                        style: const TextStyle(
                                                          color: Colors.black87,
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
                                      ? Colors.grey
                                      : Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              controller: memberPhoneNumberController,
                              decoration: const InputDecoration(
                                labelText: "Phone number",
                                border: OutlineInputBorder(),
                                focusColor: Colors.black54,
                                hoverColor: Colors.black54,
                                focusedBorder: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: memberEmailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                                focusColor: Colors.black54,
                                hoverColor: Colors.black54,
                                focusedBorder: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text(
                                "Please insert either phone number or email, or both."),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Birthday",
                                border: OutlineInputBorder(),
                                focusColor: Colors.black54,
                                hoverColor: Colors.black54,
                                focusedBorder: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              onTap: () {
                                var firstDate = DateTime.now();
                                var lastDate = DateTime.now();

                                firstDate = DateTime(firstDate.year - 100);
                                lastDate = DateTime(lastDate.year - 18);
                                showDatePicker(
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
                                title: const Text("English"),
                                groupValue: selectedLanguage,
                                value: language.EN,
                                activeColor: Colors.black54,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value;
                                  });
                                }),
                            RadioListTile<language>(
                                title: const Text("Bahasa"),
                                groupValue: selectedLanguage,
                                value: language.ID,
                                activeColor: Colors.black54,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value;
                                  });
                                }),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
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
                                  color: Color.fromARGB(255, 151, 158, 249),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 32, 92),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                bottom: 50,
              ),
              color: Color.fromARGB(0, 151, 157, 249),
              child: Center(
                child: SizedBox(
                  width: 0.8 * ResponsiveUtils.getContainerSize(context),
                  child: Row(
                    children: [
                      SizedBox(
                        // Width only 0.7
                        width: 0.5 * ResponsiveUtils.getContainerSize(context),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Check Your Store Performance",
                              style: TextStyle(
                                color: Color.fromARGB(255, 109, 41, 187),
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              "Here you can check out your sales performance, track registered members, and monitor overall store activity.",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 32, 92),
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "More to your store",
                      style: TextStyle(
                        color: Color.fromARGB(255, 109, 41, 187),
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    StaggeredGrid.count(
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 25,
                      crossAxisCount: 3,
                      children: [
                        ActionCard(
                          imageString: "assets/images/create.png",
                          title: "Add new member",
                          description:
                              "Add new member. Please prepare the required data such as name and email.",
                          onPressed: preOpenAddMember,
                        ),
                        ActionCard(
                          imageString: "assets/images/check-stock.png",
                          title: "Check stock",
                          description: "Check stocks from other stores.",
                          onPressed: () {
                            router.push('/inventory/check-stock');
                          },
                        ),
                        ActionCard(
                          imageString: "assets/images/history.png",
                          title: "Sales history",
                          description: "Get past bills",
                          onPressed: () {
                            router.push('/history');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Divider(
                      color: Color.fromARGB(255, 184, 184, 184),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Center(
              child: SizedBox(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                child: Card(
                  color: const Color.fromARGB(59, 240, 237, 245),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 35,
                      horizontal: 15,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Your store stats",
                            style: TextStyle(
                              color: Color.fromARGB(255, 66, 66, 66),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          // select
                          Row(
                            children: [
                              DropdownMenu<String>(
                                // white background
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  filled: true,
                                  contentPadding: EdgeInsets.all(10.0),
                                  // borer
                                  border: OutlineInputBorder(),
                                ),
                                width: 0.4 *
                                    ResponsiveUtils.getContainerSize(context),
                                label: const Text("Assessment period"),
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry(
                                    label: "Today",
                                    value: "0",
                                  ),
                                  DropdownMenuEntry(
                                    label: "Last 7 days",
                                    value: "7",
                                  ),
                                  DropdownMenuEntry(
                                    label: "Last 30 days",
                                    value: "30",
                                  ),
                                  DropdownMenuEntry(
                                    label: "Overall",
                                    value: "-1",
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Expanded(
                                child: Text(
                                    "You can change the periode of your assessment here. By default it will be the today's assessment.",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Row(
                            children: [
                              StatCard(
                                number:
                                    NumberFormat.compact().format(memberCount),
                                title: "Member count",
                                description: "Members registered in your store",
                                onPressed: () {},
                              ),
                              StatCard(
                                number:
                                    NumberFormat.compact().format(memberCount),
                                title: "Member count",
                                description: "Members registered in your store",
                                onPressed: () {},
                              ),
                              StatCard(
                                number:
                                    NumberFormat.compact().format(memberCount),
                                title: "Member count",
                                description: "Members registered in your store",
                                onPressed: () {},
                              ),
                              StatCard(
                                number:
                                    NumberFormat.compact().format(memberCount),
                                title: "Member count",
                                description: "Members registered in your store",
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Center(
              child: SizedBox(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "More to your store",
                      style: TextStyle(
                        color: Color.fromARGB(255, 109, 41, 187),
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    StaggeredGrid.count(
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 25,
                      crossAxisCount: 3,
                      children: [
                        ActionCard(
                          imageString: "assets/images/report.png",
                          title: "Daily report",
                          description:
                              "Get your daily report here, it contains payments and sales data.",
                          onPressed: () {},
                        ),
                        ActionCard(
                          imageString: "assets/images/send.png",
                          title: "Send stock transfer",
                          description: "Send stock to other stores.",
                          onPressed: () {
                            router.push('/inventory/stock-transfer/send');
                          },
                        ),
                        ActionCard(
                          imageString: "assets/images/receive.png",
                          title: "Receive stock transfer",
                          description:
                              "Receive stock transfer from other stores / office.",
                          onPressed: () {
                            router.push('/inventory/stock-transfer/receive');
                          },
                        ),
                        ActionCard(
                          imageString:
                              "assets/images/create-stock-transfer.png",
                          title: "Create stock transfer",
                          description:
                              "Create stock transfer request to other stores / office.",
                          onPressed: () {
                            router.push('/inventory/stock-transfer/create');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Divider(
                      color: Color.fromARGB(255, 184, 184, 184),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
