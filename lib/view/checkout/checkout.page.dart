import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/printing.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/text-formatter.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/add-member-checkout.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String storeInitial = "S";
  int selectedIndex = 0;
  String? employeeID;
  String? memberID;

  List<Map<String, dynamic>> payments = [];
  double change = 0.0;
  Printer? printer;

  // Get the cash payment
  double get cashPayment {
    return payments.firstWhereOrNull(
            (payment) => payment['method'] == "Cash")?['amount'] ??
        0.0;
  }

  TextEditingController amountController = TextEditingController();

  void _calculateChange() {
    var totalPayment = 0.0;

    for (var payment in payments) {
      totalPayment += payment['amount'];
    }

    var totalCart = Provider.of<CartNotifier>(context, listen: false)
        .selectedCart!
        .products
        .fold(
            0.0,
            (previousValue, element) =>
                previousValue +
                element.price *
                    element.quantity *
                    (100 - element.discount) /
                    100);

    setState(() {
      change = totalCart - totalPayment;
    });
  }

  void _addPayment() {
    // First check the amount controller
    var amount = amountController.text;
    var formattedAmount = amount.replaceAll(" ", "");
    if (formattedAmount.isEmpty) {
      LoggerUtils().log("Amount cannot be empty", LogType.error);
      return;
    }

    if (double.tryParse(formattedAmount) == null) {
      LoggerUtils().log("Amount must be a number", LogType.error);
      return;
    }

    // If a payment method has been selected previously, then add it to that method
    if (payments.where((element) => element['id'] == selectedIndex).isEmpty) {
      setState(() {
        payments.add({
          'id': selectedIndex,
          'method': selectedIndex == 0
              ? "Cash"
              : selectedIndex == 1
                  ? "QRIS"
                  : selectedIndex == 2
                      ? "Card"
                      : selectedIndex == 3
                          ? "Bank Transfer"
                          : selectedIndex == 4
                              ? "PayPal"
                              : "Voucher",
          'amount': double.parse(formattedAmount),
        });
      });
    } else {
      setState(() {
        payments
            .where((element) => element['id'] == selectedIndex)
            .first
            .update('amount', (value) => value + double.parse(formattedAmount));
      });
    }

    // Calculate the change
    _calculateChange();
  }

  Future<void> _preCheckout() async {
    if (payments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No payment method selected!"),
        ),
      );
      return;
    }

    // Check if payment is same or greater than the total
    if (change > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Payment must be greater than or equal to the total amount!"),
        ),
      );
      return;
    }

    if (change < 0 && cashPayment == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Changes are only allowed when using cash payments."),
        ),
      );
      return;
    }

    if (change < 0 && cashPayment < -change) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient cash payment!"),
        ),
      );
      return;
    }

    Printer? selectedPrinter = null;
    while (selectedPrinter == null) {
      selectedPrinter = await checkPrinter();
    }

    // ignore: unnecessary_null_comparison
    if (selectedPrinter != null) {
      showDialog<UserModel?>(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return const Dialog(
              child: SelectEmployee(),
            );
          }).then((value) {
        if (value != null) {
          setState(() {
            employeeID = value.code;
          });
          _checkout(selectedPrinter!);
        }
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Printer has not been set up."),
      ));
    }
  }

  Future<Printer?> checkPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("printer:name") == null ||
        prefs.getString("printer:url") == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Default printer is not found. Please select a printer"),
      ));
      return await Printing.pickPrinter(context: context);
    } else {
      var selectedPrinter = Printer(
          url: prefs.getString("printer:url")!,
          name: prefs.getString("printer:name")!);

      if (selectedPrinter.isAvailable) {
        return selectedPrinter;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Default printer is not available. Please select a printer"),
        ));
        return await Printing.pickPrinter(context: context);
      }
    }
  }

  Future<void> _checkout(Printer printer) async {
    try {
      var name =
          Provider.of<CartNotifier>(context, listen: false).selectedCart!.name;
      await Provider.of<CartNotifier>(context, listen: false).checkout(
        null,
        payments,
        employeeID!,
      );

      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (format) => PrintingUtils.generatePDF(name),
      );

      await Provider.of<CartNotifier>(context, listen: false)
          .deleteCurrentCart();
      Navigator.pop(context);
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
    }
  }

  @override
  void initState() {
    StoreModel.getCurrentProfile().then((value) {
      setState(() {
        storeInitial = value!.name.substring(0, 1);
      });
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Now, you can navigate payments using F1 - F6 keys while focusing on the amount."),
        ),
      );
    });
    super.initState();
  }

  Future<dynamic> openMembershipSelector() {
    return showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: AddMemberCheckout(),
          );
        });
  }

  Widget _tabSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "assets/images/logo.webp",
            width: 150,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Thank you for your order!",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 20,
          ),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ...[
                  "Cash",
                  "QRIS",
                  "Card",
                  "Bank Transfer",
                  "PayPal",
                  "Voucher"
                ].mapIndexed((index, element) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Colors.blue.shade100
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        element,
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.blue
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                })
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Amount",
                    ),
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    inputFormatters: [
                      CustomTextInputFormatter(),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.\s]')),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 34, 34, 34),
                        ),
                        onPressed: _addPayment,
                        child: Text(
                          "Add payment",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Changes are only allowed to be made in cash payments. Please ensure that the cash payment amount is sufficient to cover the total payment amount.",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: _preCheckout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text("Checkout",
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f1): () {
          setState(() {
            selectedIndex = 0;
          });
        },
        const SingleActivator(LogicalKeyboardKey.f2): () {
          setState(() {
            selectedIndex = 1;
          });
        },
        const SingleActivator(LogicalKeyboardKey.f3): () {
          setState(() {
            selectedIndex = 2;
          });
        },
        const SingleActivator(LogicalKeyboardKey.f4): () {
          setState(() {
            selectedIndex = 3;
          });
        },
        const SingleActivator(LogicalKeyboardKey.f5): () {
          setState(() {
            selectedIndex = 4;
          });
        },
        const SingleActivator(LogicalKeyboardKey.f6): () {
          setState(() {
            selectedIndex = 5;
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: ResponsiveUtils.getContainerSize(context),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<CartNotifier>(builder: (_, value, __) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Text(storeInitial,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Checkout",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    openMembershipSelector().then((value) {
                                      if (value != null) {
                                        setState(() {
                                          memberID = value;
                                        });
                                      }
                                    }).catchError((error) {
                                      LoggerUtils().log(error, LogType.error);
                                    });
                                  },
                                  child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.5,
                                        horizontal: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: memberID == null
                                            ? const Color.fromARGB(
                                                255, 248, 215, 152)
                                            : const Color.fromARGB(
                                                206, 204, 241, 179),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              memberID == null
                                                  ? "Non-member"
                                                  : memberID!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: memberID == null
                                                    ? const Color.fromARGB(
                                                        255, 175, 98, 27)
                                                    : Colors.green.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          memberID != null
                                              ? SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child: IconButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    onPressed: () {
                                                      setState(() {
                                                        memberID = null;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons.close,
                                                      size: 12,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      )),
                                )
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...(value.selectedCart?.products ?? [])
                                        .map((e) {
                                      return ListTile(
                                        isThreeLine: false,
                                        title: Text(
                                          e.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: "Lato",
                                          ),
                                        ),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            text: "Qty:   ",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Lato",
                                            ),
                                            children: [
                                              TextSpan(
                                                text: e.quantity.toString(),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Lato",
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              NumberFormat.decimalPatternDigits(
                                                locale: "en-US",
                                                decimalDigits: 2,
                                              ).format(e.quantity *
                                                  (e.price *
                                                      (100 - e.discount)) /
                                                  110),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Lato",
                                              ),
                                            ),
                                            e.quantity > 1
                                                ? Text(
                                                    "${NumberFormat.decimalPatternDigits(
                                                      locale: "en-US",
                                                      decimalDigits: 2,
                                                    ).format((e.price * (100 - e.discount)) / 110)} each",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      );
                                    }),
                                    ListTile(
                                      title: const Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Lato",
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        NumberFormat.decimalPatternDigits(
                                          locale: "en-US",
                                          decimalDigits: 2,
                                        ).format(
                                          (value.selectedCart?.products ?? [])
                                                  .fold(
                                                0.0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    (element.quantity *
                                                        element.price),
                                              ) /
                                              1.11,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Lato",
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Discount",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      subtitle: Text(
                                        "Special discount applied for you.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: Text(
                                        NumberFormat.decimalPatternDigits(
                                          locale: "en-US",
                                          decimalDigits: 2,
                                        ).format(
                                          (value.selectedCart?.products ?? [])
                                              .fold(
                                            0.0,
                                            (previousValue, element) =>
                                                previousValue +
                                                (element.quantity *
                                                    element.price *
                                                    element.discount /
                                                    110),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Value Added Tax",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      subtitle: Text(
                                        "National-wide tax applied for you.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: Text(
                                        NumberFormat.decimalPatternDigits(
                                          locale: "en_US",
                                          decimalDigits: 2,
                                        ).format(
                                          (value.selectedCart?.products ?? [])
                                                  .fold(
                                                0.0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    (element.quantity *
                                                        element.price *
                                                        (100 -
                                                            element.discount) /
                                                        100),
                                              ) *
                                              11 /
                                              111,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: Text(
                                        NumberFormat.decimalPatternDigits(
                                          locale: "en-US",
                                          decimalDigits: 2,
                                        ).format(
                                            (value.selectedCart?.products ?? [])
                                                .fold(
                                          0.0,
                                          (previousValue, element) =>
                                              previousValue +
                                              (element.quantity *
                                                  element.price *
                                                  (100 - element.discount) /
                                                  100),
                                        )),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Payments",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Lato",
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...payments.map((e) {
                                      return ListTile(
                                        leading: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              payments.removeWhere((element) =>
                                                  element['method'] ==
                                                  e['method']);
                                            });
                                            _calculateChange();
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 12,
                                          ),
                                        ),
                                        title: Text(
                                          e['method'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        trailing: Text(
                                          NumberFormat.decimalPatternDigits(
                                            locale: "en-US",
                                            decimalDigits: 2,
                                          ).format(e['amount']),
                                        ),
                                      );
                                    }),
                                    change >= 0
                                        ? const SizedBox()
                                        : ListTile(
                                            title: Text(
                                              "Changes",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            trailing: Text(
                                              NumberFormat.decimalPatternDigits(
                                                locale: "en-US",
                                                decimalDigits: 2,
                                              ).format(change),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: _tabSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
