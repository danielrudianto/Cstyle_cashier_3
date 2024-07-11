import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/checkout/components/select-employee.dart';
import 'package:cstyle_cashier_3/view/clip-path/trapezoid.clip-path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CreateStockTransferPage extends StatefulWidget {
  const CreateStockTransferPage({super.key});

  @override
  State<CreateStockTransferPage> createState() =>
      _CreateStockTransferPageState();
}

class _CreateStockTransferPageState extends State<CreateStockTransferPage> {
  bool isSubmitting = false;
  bool isFetchingStores = false;
  List<StoreModel> stores = [];
  StoreModel? store;
  List<ProductModelStockTransfer> products = [];
  TextEditingController noteController = TextEditingController();

  _fetchStores() {
    setState(() {
      isFetchingStores = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Fetching stores"),
    ));

    StoreModel.fetchStores().then((value) {
      setState(() {
        stores = value;
      });
      _showStorePicker();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }).whenComplete(() {
      setState(() {
        isFetchingStores = false;
      });
    });
  }

  _showStorePicker() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select store",
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 30, 73),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Select the store you want to transfer stock from",
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 30, 73),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          router.pop(stores[index]);
                        },
                        title: Text(stores[index].name),
                        subtitle: Text(stores[index].address),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          store = value;
        });
      }
    });
  }

  _openProductSelector() {
    router.push("/select-product/${store!.id}").then((value) {
      if (value != null) {
        var product = value as ProductModel;
        setState(() {
          products.add(
            ProductModelStockTransfer(
              id: product.id,
              reference: product.reference,
              description: product.description,
              brand: product.brand,
              type: product.type,
              price: product.price,
              stock: product.stock ?? 0,
              quantity: 1,
            ),
          );
        });
      }
    });
  }

  _createStockTransfer() {
    setState(() {
      isSubmitting = true;
    });

    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a store",
          ),
        ),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add at least one product",
          ),
        ),
      );
      return;
    }

    // Create the stock transfer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Creating stock transfer",
        ),
      ),
    );

    // No products can be 0
    if (products.any((element) => element.quantity == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Quantity of products cannot be 0",
          ),
        ),
      );
      return;
    }

    showDialog<UserModel?>(
        context: context,
        builder: (context) {
          return const Dialog(
            child: SelectEmployee(),
          );
        }).then((value) {
      if (value != null) {
        StockTransferModel(
          storeID: store!.id,
          items: products.map((x) {
            return StockTransferItemModel(itemID: x.id, quantity: x.quantity);
          }).toList(),
          createdBy: value.id,
          createdAt: DateTime.now(),
          note: noteController.text,
        ).create().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stock transfer request successfully created."),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            router.pop();
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString(),
              ),
            ),
          );

          setState(() {
            isSubmitting = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: TrapezoidClipPath(),
            child: Container(
              width: double.infinity,
              color: Color.fromARGB(255, 211, 212, 253),
              height: 500,
            ),
          ),
          ClipPath(
            clipper: InversedTrapezoidClipPath(),
            child: Container(
              width: double.infinity,
              color: Color.fromARGB(180, 124, 136, 248),
              height: 500,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              SizedBox(
                width: ResponsiveUtils.getContainerSize(context),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              router.pop();
                            }),
                        Text(
                          "Create stock transfer",
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 30, 73),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _fetchStores();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 25,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 4, 30, 73),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Text(
                                    "Select store",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Selected store",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: store == null
                                ? const Text("No store selected")
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        store!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        store!.address,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed:
                                    store == null ? null : _openProductSelector,
                                // Style same as the select store container
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    store == null
                                        ? const Color.fromARGB(
                                            255, 102, 102, 102)
                                        : const Color.fromARGB(255, 4, 30, 73),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 25,
                                  ),
                                  child: Text(
                                    "Add product",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Table(
                            // Want to have horizontal borders only
                            border: const TableBorder(
                              horizontalInside: BorderSide(
                                color: Colors.black54,
                                width: 1,
                              ),
                            ),
                            // Need to have 3 columns
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "Reference",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "Description",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "Quantity",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...products.map((product) {
                                TextEditingController controller =
                                    TextEditingController();

                                controller.text = product.quantity.toString();
                                return TableRow(children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        product.reference,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        product.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        // Only can input digits
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        // on change update the product data
                                        onChanged: (value) {
                                          product.quantity = value.isEmpty
                                              ? 0
                                              : int.parse(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.grey.shade800,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          products.remove(product);
                                        });
                                      },
                                    ),
                                  )),
                                ]);
                              }),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // Textarea for note
                          TextField(
                            controller: noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Note",
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          // Create another button
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _createStockTransfer,
                                // Style same as the select store container
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    store == null ||
                                            products.isEmpty ||
                                            isSubmitting
                                        ? const Color.fromARGB(
                                            255, 102, 102, 102)
                                        : const Color.fromARGB(255, 4, 30, 73),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 25,
                                  ),
                                  child: Text(
                                    "Create stock transfer",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
