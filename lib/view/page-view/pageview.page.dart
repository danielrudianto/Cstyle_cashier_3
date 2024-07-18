import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/dashboard.page.dart';
import 'package:cstyle_cashier_3/view/history/history.page.dart';
import 'package:cstyle_cashier_3/view/inventory/inventory.page.dart';
import 'package:cstyle_cashier_3/view/store/store.page.dart';
import 'package:cstyle_cashier_3/view/page-view/components/appbar-pageview.dart';
import 'package:cstyle_cashier_3/view/setting/setting.page.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class PageViewPage extends StatefulWidget {
  const PageViewPage({super.key});

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);

    Widget? buildCartUpdateSection(int index) {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      var cartNotifier = Provider.of<CartNotifier>(context, listen: false);

      TextEditingController discountController = TextEditingController();
      TextEditingController quantityController = TextEditingController();

      discountController.text =
          cartNotifier.selectedCart!.products[index].discount.toString();

      quantityController.text =
          cartNotifier.selectedCart!.products[index].quantity.toString();

      updateCartItem() async {
        // Validate discount & quantity first
        if (discountController.text.isEmpty ||
            quantityController.text.isEmpty) {
          return;
        }

        var discount = double.parse(discountController.text);
        var quantity = int.parse(quantityController.text);

        if (discount < 0 || discount > 100) {
          return;
        }

        if (quantity < 0) {
          return;
        }

        await cartNotifier.updateQuantityDiscount(index, quantity, discount);
      }

      if (cartNotifier.selectedCart != null) {
        return Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  controller: discountController,
                  decoration: InputDecoration(
                    hintText: "Discount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.percent,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  controller: quantityController,
                  decoration: InputDecoration(
                    prefix: SizedBox(
                      width: 25,
                      height: 25,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          if (quantityController.text.isNotEmpty) {
                            var quantity = int.parse(quantityController.text);
                            if (quantity > 0) {
                              quantityController.text =
                                  (quantity - 1).toString();
                            } else {
                              return;
                            }
                          } else {
                            quantityController.text = "0";
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Colors.grey.shade700,
                          size: 8,
                        ),
                      ),
                    ),
                    suffix: SizedBox(
                      width: 25,
                      height: 25,
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          if (quantityController.text.isNotEmpty) {
                            var quantity = int.parse(quantityController.text);
                            quantityController.text = (quantity + 1).toString();
                          } else {
                            quantityController.text = "1";
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.grey.shade700,
                          size: 10,
                        ),
                      ),
                    ),
                    hintText: "Quantity",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              // Save button
              TextButton(
                onPressed: updateCartItem,
                child: const Text(
                  "Save",
                ),
              ),
            ],
          ),
        );
      } else {
        LoggerUtils().log(
            "Cart is not selected, cannot create cart update section",
            LogType.error);
        return null;
      }
    }

    Future<void> openProductCart() async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var selectedCart = cartNotifier.selectedCart;
      if (selectedCart != null) {
        LoggerUtils().log("Cart found", LogType.info);
        showDialog(
          barrierColor: const Color.fromARGB(103, 148, 148, 148),
          context: context,
          builder: (context) {
            int? openedIndex;

            return StatefulBuilder(builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 90,
                          right: 15,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            return;
                          },
                          child:
                              Consumer<CartNotifier>(builder: (_, value, __) {
                            return Container(
                              height:
                                  (MediaQuery.of(context).size.height - 90) *
                                      0.9,
                              width: 450,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Order ${value.selectedCart!.name}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop("archive");
                                        },
                                        child: const Text(
                                          "Archive",
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop("clear");
                                        },
                                        child: const Text(
                                          "Clear cart",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey.shade400,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: value.selectedCart!.products
                                            .mapIndexed((index, e) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            e.reference,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            if (openedIndex !=
                                                                null) {
                                                              setState(() {
                                                                openedIndex =
                                                                    null;
                                                              });
                                                            }

                                                            if (value
                                                                    .selectedCart!
                                                                    .products
                                                                    .length ==
                                                                1) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }

                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                                () {
                                                              cartNotifier
                                                                  .deleteProductFromCart(
                                                                      index);
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors
                                                                .grey.shade400,
                                                            size: 18,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      e.description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              if (index ==
                                                                  openedIndex) {
                                                                setState(() {
                                                                  openedIndex =
                                                                      null;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  openedIndex =
                                                                      index;
                                                                });
                                                              }
                                                            },
                                                            child: e.discount ==
                                                                    0
                                                                ? Text(
                                                                    "${NumberFormat.decimalPattern("en_US").format(e.quantity)} x ${NumberFormat.decimalPattern("en_US").format(e.price)}",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium)
                                                                : RichText(
                                                                    text: TextSpan(
                                                                        text: NumberFormat.decimalPattern("en_US").format(e
                                                                            .quantity),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                        children: <TextSpan>[
                                                                          const TextSpan(
                                                                            text:
                                                                                " x ",
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                NumberFormat.decimalPattern("en_US").format((e.price * (100 - e.discount)) / 100),
                                                                          ),
                                                                          const TextSpan(
                                                                            text:
                                                                                "  ",
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                NumberFormat.decimalPattern("en_US").format(e.price),
                                                                            style:
                                                                                const TextStyle(
                                                                              decoration: TextDecoration.lineThrough,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                          ),
                                                        ),
                                                        Text(
                                                          NumberFormat
                                                                  .decimalPattern(
                                                                      "en_US")
                                                              .format(e
                                                                      .quantity *
                                                                  (e.price *
                                                                      (100 -
                                                                          e.discount)) /
                                                                  100),
                                                        ),
                                                      ],
                                                    ),
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeInOut,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 5,
                                                        bottom: 5,
                                                      ),
                                                      width: double.infinity,
                                                      height:
                                                          openedIndex == index
                                                              ? 50
                                                              : 0,
                                                      child: AnimatedOpacity(
                                                        opacity:
                                                            openedIndex == index
                                                                ? 1
                                                                : 0,
                                                        duration:
                                                            const Duration(
                                                          milliseconds: 300,
                                                        ),
                                                        child:
                                                            buildCartUpdateSection(
                                                                index),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Total",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          NumberFormat.decimalPattern("en_US")
                                              .format(
                                            value.totalPrice,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Checkout button
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop("checkout");
                                      },
                                      child: const Text(
                                        "Checkout",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          },
        ).then((value) async {
          if (value == "checkout") {
            // Check stock first
            var validation = await cartNotifier.checkStock();
            if (!validation) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Insufficient stock")));
            } else {
              GoRouter.of(context).push("/checkout");
            }
          } else if (value == "clear") {
            Future.delayed(
                const Duration(
                  milliseconds: 300,
                ), () async {
              try {
                await cartNotifier.deleteCurrentCart();
              } catch (error) {
                LoggerUtils().log(error.toString(), LogType.error);
              }
            });
          } else if (value == "archive") {
            Future.delayed(
                const Duration(
                  milliseconds: 300,
                ), () async {
              try {
                cartNotifier.deselectCart();
              } catch (error) {
                LoggerUtils().log(error.toString(), LogType.error);
              }
            });
          }
        });
      } else {
        LoggerUtils().log("Cart not found", LogType.info);
      }
    }

    Future<void> openProductCartList() async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var carts = await cartNotifier.getCarts();
      showDialog(
        barrierColor: const Color.fromARGB(103, 148, 148, 148),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 90,
                        right: 15,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          return;
                        },
                        child: Container(
                            height:
                                (MediaQuery.of(context).size.height - 90) * 0.9,
                            width: 450,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).cardColor,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: cartNotifier.selectedCart != null &&
                                          cartNotifier.selectedCart!.id ==
                                              carts[index].id
                                      ? null
                                      : () async {
                                          // Get complete cart
                                          var cart = await CartModel.fetchByID(
                                              carts[index].id!);
                                          Provider.of<CartNotifier>(context,
                                                  listen: false)
                                              .selectCart(cart);

                                          Navigator.of(context).pop();
                                        },
                                  title: Text(carts[index].name),
                                  subtitle: Text(DateFormat("dd/MM/yyyy")
                                      .format(carts[index].date)),
                                  trailing: cartNotifier.selectedCart != null &&
                                          cartNotifier.selectedCart!.id ==
                                              carts[index].id
                                      ? const Icon(Icons.check)
                                      : null,
                                );
                              },
                              itemCount: carts.length,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    }

    return Material(
      child: Column(
        children: [
          AppbarPageView(
            page: currentPage,
            changePage: (page) {
              setState(() {
                currentPage = page;
              });

              pageController.animateToPage(
                currentPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            onOpenCart: () {
              openProductCart();
            },
            onOpenCartList: () {
              openProductCartList();
            },
          ),
          Expanded(
            child: PageView(
              pageSnapping: true,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: const [
                DashboardPage(),
                StorePage(),
                SettingPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
