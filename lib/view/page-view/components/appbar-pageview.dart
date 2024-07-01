import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppbarPageView extends StatelessWidget {
  final int page;
  final Function changePage;
  final Function onOpenCartList;
  final Function onOpenCart;
  const AppbarPageView({
    super.key,
    required this.page,
    required this.changePage,
    required this.onOpenCartList,
    required this.onOpenCart,
  });

  /// Builds the widget tree for the current widget.
  /// The [context] parameter is the BuildContext of the widget.
  /// Returns a [Container] widget that contains the app bar.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        // Border bottom
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Consumer<CartNotifier>(builder: (_, value, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                "assets/images/icon.webp",
                width: 40,
                height: 40,
              ),
            ),
            Expanded(
              flex: 24,
              child: Center(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: page == 0
                                  ? const Color.fromARGB(255, 109, 78, 137)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        height: 80,
                        child: InkWell(
                          onTap: () {
                            changePage(0);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Dashboard",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: page == 0
                                          ? const Color.fromARGB(
                                              255, 109, 78, 137)
                                          : Colors.grey.shade500,
                                      fontWeight: page == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: page == 1
                                  ? const Color.fromARGB(255, 109, 78, 137)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        height: 80,
                        child: InkWell(
                          onTap: () {
                            changePage(1);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Member",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: page == 1
                                          ? const Color.fromARGB(
                                              255, 109, 78, 137)
                                          : Colors.grey.shade500,
                                      fontWeight: page == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: page == 2
                                  ? const Color.fromARGB(255, 109, 78, 137)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        height: 80,
                        child: InkWell(
                          onTap: () {
                            changePage(2);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "History",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: page == 2
                                          ? const Color.fromARGB(
                                              255, 109, 78, 137)
                                          : Colors.grey.shade500,
                                      fontWeight: page == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: page == 3
                                  ? const Color.fromARGB(255, 109, 78, 137)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        height: 80,
                        // Border bottom
                        child: InkWell(
                          onTap: () {
                            changePage(3);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Inventory",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: page == 3
                                          ? const Color.fromARGB(
                                              255, 109, 78, 137)
                                          : Colors.grey.shade500,
                                      fontWeight: page == 3
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: page == 4
                                  ? const Color.fromARGB(255, 109, 78, 137)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        height: 80,
                        child: InkWell(
                          onTap: () {
                            changePage(4);
                          },
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Setting",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              flex: 1,
              child: IconButton(
                icon: Icon(Icons.upload_file, color: Colors.grey.shade500),
                onPressed: () {
                  router.go("/upload");
                },
              ),
            ),
            Flexible(
              // Fit to right
              fit: FlexFit.loose,
              flex: 1,
              child: Badge(
                backgroundColor: const Color.fromARGB(255, 109, 78, 137),
                label: Text(
                  value.cartCount.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.inventory, color: Colors.grey.shade500),
                  onPressed: () {
                    onOpenCartList();
                  },
                ),
              ),
            ),
            Flexible(
              // Fit to right
              fit: FlexFit.loose,
              flex: 1,
              child: Badge(
                backgroundColor: const Color.fromARGB(255, 109, 78, 137),
                label: Text(
                  value.selectedCart == null
                      ? "0"
                      : NumberFormat.compact()
                          .format(value.selectedCart!.products.length),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_bag, color: Colors.grey.shade500),
                  onPressed: value.selectedCart == null
                      ? null
                      : () {
                          onOpenCart();
                        },
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
