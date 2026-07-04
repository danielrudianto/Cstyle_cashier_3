import 'package:cstyle_cashier_3/model/model.cart-item.model.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-checkout-footer.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardCheckout extends StatefulWidget {
  final Function onComingBack;
  const DashboardCheckout({
    super.key,
    required this.onComingBack,
  });

  @override
  State<DashboardCheckout> createState() => _DashboardCheckoutState();
}

class _DashboardCheckoutState extends State<DashboardCheckout> {
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
                              Tooltip(
                                message: "Delete this item instead",
                                child: IconButton(
                                  splashColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  onPressed: () {
                                    Provider.of<CartNotifier>(context,
                                            listen: false)
                                        .deleteProductFromCart(index);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(builder: (_, value, __) {
      return Container(
        padding: const EdgeInsets.all(15),
        width: 400,
        // left border 1px solid grey
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          color: Theme.of(context).cardColor,
        ),
        child: value.selectedCart == null ||
                value.selectedCart!.products.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 50,
                  ),
                  Text(
                    "Cart is empty",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.selectedCart!.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    DateFormat("dd/MM/yyyy").format(value.selectedCart!.date),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                            onTap: () {
                              _updatePriceDiscount(
                                  value.selectedCart!.products[index], index);
                            },
                            title: Text(
                              value.selectedCart!.products[index].reference,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.selectedCart!.products[index]
                                      .description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        value.selectedCart!.products[index]
                                                    .discount ==
                                                0
                                            ? NumberFormat.decimalPattern()
                                                .format(value.selectedCart!
                                                    .products[index].price)
                                            : NumberFormat.decimalPattern()
                                                .format((value
                                                            .selectedCart!
                                                            .products[index]
                                                            .price *
                                                        (100 -
                                                            value
                                                                .selectedCart!
                                                                .products[index]
                                                                .discount) /
                                                        100000) *
                                                    1000),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      "x${value.selectedCart!.products[index].quantity}",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ));
                      },
                      itemCount: value.selectedCart!.products.length,
                    ),
                  ),
                  DashboardCheckoutFooter(
                    value: value.totalPrice,
                    checkout: () {
                      router.push("/checkout").then((_) {
                        widget.onComingBack();
                      });
                    },
                  ),
                ],
              ),
      );
    });
  }
}
