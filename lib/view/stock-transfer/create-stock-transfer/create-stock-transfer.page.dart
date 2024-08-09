import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/components/store-selector/store-selector.dart';
import 'package:cstyle_cashier_3/components/thousand-separator/thousand-separator.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/view/product-selector/product-selector.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  get isValid {
    return store != null && products.isNotEmpty;
  }

  _openStoreSelector() {
    showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: StoreSelector(),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          store = value as StoreModel;
        });
      }
    });
  }

  _openProductSelector() {
    showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            child: ProductSelectorPage(),
          );
        }).then((value) {
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

  _openQuantitySelector(int quantity, int index) {
    TextEditingController controller =
        TextEditingController(text: NumberFormat("#,##0").format(quantity));
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(
            10,
          ),
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Quantity"),
                ),
                // input formatters
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  DecimalFormatter(decimalDigits: 0),
                ],
                // keyboard
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  var quantity = controller.text.isEmpty
                      ? 0
                      : int.parse(
                          controller.text.replaceAll(",", ""),
                        );
                  Navigator.of(context).pop(quantity);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 25,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    // radius
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Save",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      // if integer
      if (value is int) {
        setState(() {
          products[index].quantity = value;
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
        ).create().then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Stock transfer request successfully created."),
            ),
          );

          setState(() {
            products.clear();
            store = null;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 15,
        ),
        Text(
          "Create stock transfer request",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(
          height: 35,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
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
                        "1. REQUEST OPTIONS",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                        15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            DateFormat("dd MMMM yyyy").format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Store",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  _openStoreSelector();
                                },
                                icon: const Icon(
                                  Icons.add,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          store == null
                              ? const Text("Store not selected")
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      store!.address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                          child: Row(
                            children: [
                              Text(
                                "YOUR REQUEST",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _openProductSelector,
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        products.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ),
                                child: Center(
                                  child: Text(
                                    "You have not selected any products",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      products[index].reference,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          products[index].description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: TextField(
                                                onTap: () {
                                                  _openQuantitySelector(
                                                    products[index].quantity,
                                                    index,
                                                  );
                                                },
                                                readOnly: true,
                                                controller:
                                                    TextEditingController(
                                                  text: NumberFormat("#,##0")
                                                      .format(products[index]
                                                          .quantity),
                                                ),
                                                textAlign: TextAlign.center,
                                                onChanged: (value) {
                                                  setState(() {
                                                    products[index].quantity =
                                                        value.isEmpty
                                                            ? 0
                                                            : int.parse(
                                                                value
                                                                    .replaceAll(
                                                                        ",",
                                                                        ""),
                                                              );
                                                  });
                                                },
                                                // only allow positive integer
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.]')),
                                                  DecimalFormatter(
                                                      decimalDigits: 0),
                                                ],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                maxLines: 1,
                                                // decoration
                                                decoration: InputDecoration(
                                                  prefix:
                                                      products[index]
                                                                  .quantity ==
                                                              1
                                                          ? IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                size: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .fontSize,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  products
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              },
                                                            )
                                                          : IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .exposure_minus_1,
                                                                size: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .fontSize,
                                                              ),
                                                              onPressed:
                                                                  products[index]
                                                                              .quantity ==
                                                                          1
                                                                      ? null
                                                                      : () {
                                                                          setState(
                                                                              () {
                                                                            products[index].quantity--;
                                                                          });
                                                                        },
                                                            ),
                                                  suffix: IconButton(
                                                    icon: Icon(
                                                      Icons.exposure_plus_1,
                                                      size: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .fontSize,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        products[index]
                                                            .quantity++;
                                                      });
                                                    },
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: isValid ? _createStockTransfer : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: isValid
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).disabledColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Submit",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isValid
                                  ? Colors.white
                                  : Theme.of(context).disabledColor,
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
      ],
    );
  }
}
