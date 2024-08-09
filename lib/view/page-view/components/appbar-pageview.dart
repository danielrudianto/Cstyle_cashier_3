import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 125,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: page == 0
                                ? Theme.of(context).secondaryHeaderColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        color: Colors.transparent,
                      ),
                      height: 80,
                      child: InkWell(
                        onTap: page == 0
                            ? null
                            : () {
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
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: page == 1
                                ? Theme.of(context).secondaryHeaderColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      height: 80,
                      child: InkWell(
                        onTap: page == 1
                            ? null
                            : () {
                                changePage(1);
                              },
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Store",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: page == 1
                                        ? Theme.of(context).secondaryHeaderColor
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
                  ],
                ),
              ),
            ),
            Flexible(
              // Fit to right
              fit: FlexFit.loose,
              flex: 1,
              child: Badge(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                label: Text(
                  value.cartCount.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.inventory,
                    color: value.cartCount == 0
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: value.cartCount == 0
                      ? null
                      : () {
                          onOpenCartList();
                        },
                ),
              ),
            ),
            Flexible(
              // Fit to right
              fit: FlexFit.loose,
              flex: 1,
              child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    router.push("/settings");
                  }),
            )
          ],
        );
      }),
    );
  }
}
