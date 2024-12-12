import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/components/thousand-separator/thousand-separator.dart';
import 'package:cstyle_cashier_3/model/model.cart-item.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/printing.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/add-member-checkout.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int selectedIndex = 0;
  UserModel? employeeID;
  String? memberID;

  List<Map<String, dynamic>> payments = [];
  double change = 0.0;
  Printer? printer;

  TextEditingController cashController = TextEditingController();
  TextEditingController cardController = TextEditingController();
  TextEditingController bankTransferController = TextEditingController();
  TextEditingController paypalController = TextEditingController();
  TextEditingController qrisController = TextEditingController();
  TextEditingController voucherController = TextEditingController();

  TextEditingController amountController(String params) {
    switch (params) {
      case "Cash":
        return cashController;
      case "Card":
        return cardController;
      case "Bank Transfer":
        return bankTransferController;
      case "PayPal":
        return paypalController;
      case "QRIS":
        return qrisController;
      case "Voucher":
        return voucherController;
      default:
        return cashController;
    }
  }

  // Get the cash payment
  double get cashPayment {
    return payments.firstWhereOrNull(
            (payment) => payment['method'] == "Cash")?['amount'] ??
        0.0;
  }

  double get totalPayment {
    return payments.fold(
        0.0, (previousValue, element) => previousValue + element['amount']);
  }

  int get totalAmount {
    int value = (Provider.of<CartNotifier>(context, listen: false)
        .selectedCart!
        .products
        .fold(
            0,
            (previousValue, element) =>
                previousValue +
                element.quantity *
                    (element.price * (100 - element.discount) / 100000)
                        .floor() *
                    1000));

    return value;
  }

  bool isPaymentMethodExists(String e) {
    return payments.where((element) => element['method'] == e).isNotEmpty;
  }

  _updatePriceDiscount(CartItemModel item, int index) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController discountController = TextEditingController(
          text: NumberFormat.decimalPattern().format(item.discount),
        );
        TextEditingController quantityController = TextEditingController(
          text: NumberFormat.decimalPattern().format(item.quantity),
        );

        return Material(
          type: MaterialType.transparency,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    height: 420,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      // border radius only top
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.reference,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      item.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Divider(
                            color: Theme.of(context).dividerColor,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          //form field

                          Text(
                            "Price",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(NumberFormat.decimalPattern().format(item.price),
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            // label Price
                            // decoration outlineInputBorder
                            decoration: InputDecoration(
                              labelText: "Discount",
                              labelStyle: Theme.of(context).textTheme.bodySmall,
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
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              formKey.currentState!.validate();
                              setState(() {});
                            },
                            controller: discountController,
                            // input filter
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            // keyboard type number
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              double? discount = double.tryParse(value!);
                              if (discount != null) {
                                if (discount < 0 || discount > 100) {
                                  return 'Discount must be between 0 and 100';
                                }
                              } else {
                                return 'Invalid input';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            // label Price
                            // decoration outlineInputBorder
                            decoration: InputDecoration(
                              labelText: "Quantity",
                              labelStyle: Theme.of(context).textTheme.bodySmall,
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
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              formKey.currentState!.validate();
                              setState(() {});
                            },
                            controller: quantityController,
                            // input filter
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            // keyboard type number
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              double? quantity = double.tryParse(value!);
                              if (quantity != null) {
                                if (quantity < 0) {
                                  return 'Quantity must be greater than 0';
                                }
                              } else {
                                return 'Invalid input';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Price after discount: ${NumberFormat.decimalPattern().format(item.price - (item.price * double.parse(discountController.text) / 100))}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    item.discount =
                                        double.parse(discountController.text);
                                    item.quantity =
                                        int.parse(quantityController.text);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).then((value) {
      Provider.of<CartNotifier>(context, listen: false).updatePrice();
      setState(() {});
    });
  }

  void _calculateChange() {
    int value = (Provider.of<CartNotifier>(context, listen: false)
        .selectedCart!
        .products
        .fold(
            0,
            (previousValue, element) =>
                previousValue +
                element.quantity *
                    (element.price * (100 - element.discount) / 100000)
                        .floor() *
                    1000));

    setState(() {
      change = value - totalPayment;
    });
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

    int value = totalAmount;

    if (totalPayment < value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Payment must be greater than or equal to the total amount!"),
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

    Printer? selectedPrinter;
    while (selectedPrinter == null) {
      selectedPrinter = await checkPrinter();
    }

    // ignore: unnecessary_null_comparison
    if (selectedPrinter != null) {
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
          setState(() {
            employeeID = value;
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
      var cart =
          Provider.of<CartNotifier>(context, listen: false).selectedCart!;
      var name = cart.name;

      // show print preview
      showDialog(
        context: context,
        builder: (_) => Center(
          child: Container(
            color: Theme.of(context).canvasColor,
            width: 400,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: PdfPreview(
                    scrollViewDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    dynamicLayout: false,
                    padding: const EdgeInsets.all(0),
                    previewPageMargin: const EdgeInsets.all(0),
                    build: (format) => PrintingUtils.generateCartPDF(
                      cart,
                      payments,
                      memberID,
                      employeeID!,
                    ),
                    allowPrinting: false,
                    allowSharing: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    actionBarTheme: PdfActionBarTheme(
                      backgroundColor: Theme.of(context).canvasColor,
                      iconColor: Theme.of(context).iconTheme.color,
                    ),
                    canDebug: false,
                    pdfPreviewPageDecoration: const BoxDecoration(
                      // no box shadow
                      color: Colors.white,
                      boxShadow: [],
                    ),
                  ),
                ),
                Center(
                  child: IconButton(
                    onPressed: () {
                      router.pop("print");
                    },
                    icon: Icon(
                      Icons.print,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).then((value) async {
        if (value == "print") {
          Provider.of<CartNotifier>(context, listen: false)
              .checkout(
            memberID,
            payments,
            employeeID!.code,
          )
              .then((value) async {
            await Printing.directPrintPdf(
              name: name,
              printer: printer,
              onLayout: (format) => PrintingUtils.generateCartPDF(
                cart,
                payments,
                memberID,
                employeeID!,
              ),
            );

            await Provider.of<CartNotifier>(context, listen: false)
                .deleteCurrentCart();
            router.pop();
          }).catchError((error) {
            LoggerUtils().log(error.toString(), LogType.error);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          });
        }
      });
    } catch (error) {
      LoggerUtils().log(error.toString(), LogType.error);
    }
  }

  Future<dynamic> openMembershipSelector() {
    return showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: AddMemberCheckout(),
          );
        }).then((value) {
      setState(() {
        memberID = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          // back button color
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              router.pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Consumer<CartNotifier>(builder: (_, value, __) {
            return Center(
              child: Container(
                width: ResponsiveUtils.getContainerSize(context),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "CHECKOUT",
                      // all caps
                      // size it 1.5 times
                      textScaleFactor: 1.5,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(
                              fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                // add border 1px solid grey
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.black87,
                                      ),
                                      child: Text(
                                        "1. PAYMENT OPTIONS",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        "Thank you for your order!",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                    ...[
                                      "Cash",
                                      "Card",
                                      "Bank Transfer",
                                      "PayPal",
                                      "QRIS",
                                      "Voucher"
                                    ].map((e) {
                                      return ExpansionTile(
                                        onExpansionChanged: (value) {
                                          if (!value) {
                                            setState(() {
                                              payments.removeWhere((element) =>
                                                  element['method'] == e);
                                            });
                                            amountController(e).text = "";
                                            _calculateChange();
                                          } else {
                                            setState(() {
                                              if (e != 'Cash' &&
                                                  e != 'Voucher') {
                                                payments.add({
                                                  'method': e,
                                                  'amount': totalAmount,
                                                });

                                                _calculateChange();

                                                if (e == 'Card') {
                                                  cardController.text =
                                                      NumberFormat("#,##0.00")
                                                          .format(totalAmount);
                                                } else if (e == 'QRIS') {
                                                  qrisController.text =
                                                      NumberFormat("#,##0.00")
                                                          .format(totalAmount);
                                                } else if (e == 'PayPal') {
                                                  paypalController.text =
                                                      NumberFormat("#,##0.00")
                                                          .format(totalAmount);
                                                } else if (e ==
                                                    'Bank Transfer') {
                                                  bankTransferController.text =
                                                      NumberFormat("#,##0.00")
                                                          .format(totalAmount);
                                                }
                                              } else {
                                                payments.add({
                                                  'method': e,
                                                  'amount': 0.0,
                                                });

                                                _calculateChange();
                                              }
                                            });
                                          }
                                        },
                                        title: Text(
                                          e,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        trailing: isPaymentMethodExists(e)
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )
                                            : const Icon(
                                                Icons.add,
                                                color: Colors.grey,
                                              ),
                                        childrenPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        children: [
                                          TextField(
                                            controller: amountController(e),
                                            // outlined
                                            decoration: InputDecoration(
                                              label: Text(
                                                "Amount",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              ),
                                              border: OutlineInputBorder(
                                                // color same as divider color
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                ),
                                              ),
                                            ),
                                            // only allow number
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                              DecimalFormatter(
                                                  decimalDigits: 0),
                                            ],
                                            // thousand separator
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                var index = payments.indexWhere(
                                                    (element) =>
                                                        element['method'] == e);
                                                payments[index]['amount'] =
                                                    value.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                            value.replaceAll(
                                                                ",", ""));

                                                _calculateChange();
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                // add border 1px solid grey
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.black87,
                                      ),
                                      child: Text(
                                        "2. MEMBERSHIPS",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Join our membership programs to get more benefits!",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          // if memberID is not null
                                          if (memberID != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 15,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Member ID: $memberID",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        memberID = null;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          // member selector button
                                          InkWell(
                                            onTap: () {
                                              openMembershipSelector();
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Select Membership",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        color: Colors.white,
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(0),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        color: Theme.of(context)
                                            .secondaryHeaderColor
                                            .withOpacity(0.8),
                                      ),
                                      child: Text(
                                        "IN YOUR BAG",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            _updatePriceDiscount(
                                                value.selectedCart!
                                                    .products[index],
                                                index);
                                          },
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 15,
                                          ),
                                          title: Text(
                                            value.selectedCart!.products[index]
                                                .reference,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                value
                                                    .selectedCart!
                                                    .products[index]
                                                    .description,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${NumberFormat().format(value.selectedCart!.products[index].quantity)} x ${value.selectedCart!.products[index].discount == 0 ? NumberFormat("#,##0.00").format(value.selectedCart!.products[index].price) : NumberFormat("#,##0.00").format(
                                                        1000 *
                                                            ((value
                                                                    .selectedCart!
                                                                    .products[
                                                                        index]
                                                                    .price) *
                                                                (100 -
                                                                    value
                                                                        .selectedCart!
                                                                        .products[
                                                                            index]
                                                                        .discount) /
                                                                100 ~/
                                                                1000),
                                                      )}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    value
                                                                .selectedCart!
                                                                .products[index]
                                                                .discount ==
                                                            0
                                                        ? NumberFormat(
                                                                "#,##0.00")
                                                            .format(
                                                            (value.selectedCart!.products[index].quantity *
                                                                        value
                                                                            .selectedCart!
                                                                            .products[
                                                                                index]
                                                                            .price *
                                                                        (100 -
                                                                            value.selectedCart!.products[index].discount) /
                                                                        100000)
                                                                    .floor() *
                                                                1000,
                                                          )
                                                        : NumberFormat(
                                                                "#,##0.00")
                                                            .format(
                                                            value
                                                                    .selectedCart!
                                                                    .products[
                                                                        index]
                                                                    .quantity *
                                                                (value
                                                                            .selectedCart!
                                                                            .products[
                                                                                index]
                                                                            .price *
                                                                        (100 -
                                                                            value.selectedCart!.products[index].discount) /
                                                                        100000)
                                                                    .floor() *
                                                                1000,
                                                          ),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: value.selectedCart == null
                                          ? 0
                                          : value.selectedCart!.products.length,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Divider(
                                      color: Colors.grey.shade300,
                                    ),
                                    // const SizedBox(
                                    //   height: 15,
                                    // ),
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     vertical: 5,
                                    //     horizontal: 15,
                                    //   ),
                                    //   child: Row(
                                    //     children: [
                                    //       Text(
                                    //         "Subtotal",
                                    //         style: Theme.of(context)
                                    //             .textTheme
                                    //             .labelLarge,
                                    //       ),
                                    //       const Spacer(),
                                    //       Text(
                                    //         NumberFormat("#,##0.00").format(
                                    //             value.totalPrice / 1.11),
                                    //         style: Theme.of(context)
                                    //             .textTheme
                                    //             .labelLarge!
                                    //             .copyWith(
                                    //               fontWeight: FontWeight.normal,
                                    //             ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     vertical: 5,
                                    //     horizontal: 15,
                                    //   ),
                                    //   child: Row(
                                    //     children: [
                                    //       Text(
                                    //         "Tax",
                                    //         style: Theme.of(context)
                                    //             .textTheme
                                    //             .labelLarge,
                                    //       ),
                                    //       const Spacer(),
                                    //       Text(
                                    //         NumberFormat("#,##0.00").format(
                                    //             value.totalPrice -
                                    //                 value.totalPrice / 1.11),
                                    //         style: Theme.of(context)
                                    //             .textTheme
                                    //             .labelLarge!
                                    //             .copyWith(
                                    //               fontWeight: FontWeight.normal,
                                    //             ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 15,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Total",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                          const Spacer(),
                                          Text(
                                            NumberFormat("#,##0.00")
                                                .format(value.totalPrice),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Payments",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: payments.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == payments.length) {
                                    return ListTile(
                                      title: Text(
                                        "Changes",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: Text(
                                        change >= 0
                                            ? "0.00"
                                            : NumberFormat("#,##0.00").format(
                                                -change,
                                              ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      title: Text(
                                        payments[index]['method'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      trailing: Text(
                                        NumberFormat("#,##0.00").format(
                                          payments[index]['amount'],
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // Button
                              InkWell(
                                onTap: () {
                                  _preCheckout();
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Checkout",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
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
                  ],
                ),
              ),
            );
          }),
        ));
  }
}
