import 'package:cstyle_cashier_3/model/model.countries.dart';
import 'package:cstyle_cashier_3/model/model.member.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  TextEditingController codeEditingController = TextEditingController();
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
      }
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  openAddMember() {
    TextEditingController codeEditingController = TextEditingController();
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController memberNationalityController = TextEditingController();
    TextEditingController memberEmailController = TextEditingController();
    TextEditingController memberPhoneNumberController = TextEditingController();
    CountryModel? nationality;

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
                              controller: nameEditingController,
                              decoration: const InputDecoration(
                                labelText: "Preferred language",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 25,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 151, 158, 249),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 32, 92),
                                ),
                                textAlign: TextAlign.center,
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
              color: Color.fromARGB(255, 151, 158, 249),
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Memberships",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 32, 92),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Join our membership program today to earn points and get exclusive offers!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 32, 92),
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // Create button
                    GestureDetector(
                      onTap: () {
                        openAddMember();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color.fromARGB(255, 0, 32, 92),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 10,
                          ),
                          child: Text(
                            "Add new member",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  color: Color.fromARGB(255, 151, 158, 249),
                  height: 50,
                ),
                SizedBox(
                  width: ResponsiveUtils.getContainerSize(context),
                  child: StaggeredGrid.count(
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    children: [
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Current members"),
                                  Text(
                                    "1.265",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 32, 92),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Current members"),
                                  Text(
                                    "1.265",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 32, 92),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Current members"),
                                  Text(
                                    "1.265",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 32, 92),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Current members"),
                                  Text(
                                    "1.265",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 32, 92),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 4,
                        mainAxisCellCount: 1,
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Need to check your member's code?",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 32, 92),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextFormField(
                                    controller: codeEditingController,
                                    readOnly: isLoading,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffix: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: IconButton(
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.search,
                                            size: 15,
                                          ),
                                          onPressed: () {
                                            fetchByCode(
                                                    codeEditingController.text)
                                                .then((member) {})
                                                .catchError((error) {});
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Center(
              child: SizedBox(
                width: ResponsiveUtils.getContainerSize(context),
                child: Text("View members here."),
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
