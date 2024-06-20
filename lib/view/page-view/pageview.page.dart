import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/dashboard.page.dart';
import 'package:cstyle_cashier_3/view/history/history.page.dart';
import 'package:cstyle_cashier_3/view/inventory/inventory.page.dart';
import 'package:cstyle_cashier_3/view/member/member.page.dart';
import 'package:cstyle_cashier_3/view/page-view/components/appbar-pageview.dart';
import 'package:cstyle_cashier_3/view/setting/setting.page.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PageViewPage extends StatefulWidget {
  const PageViewPage({super.key});

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  int currentPage = 0;

  Future<void> openProductCart() async {
    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
    var selectedCart = cartNotifier.selectedCart;
    if (selectedCart != null) {
      LoggerUtils().log("Cart found", LogType.info);
      showDialog(
        barrierColor: const Color.fromARGB(103, 148, 148, 148),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 90,
                  right: 15,
                ),
                child: Container(
                  height: (MediaQuery.of(context).size.height - 90) * 0.9,
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
                              "Order ${cartNotifier.selectedCart!.name}",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Clear cart
                            },
                            child: Text(
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
                            children:
                                cartNotifier.selectedCart!.products.map((e) {
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
                                        Text(
                                          e.reference,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          e.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        Text(
                                          NumberFormat.decimalPattern("en_US")
                                              .format(e.price),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        Divider(
                                          color: Colors.grey.shade300,
                                        )
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
                            flex: 4,
                            child: Text(
                              "Total",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              NumberFormat.decimalPattern("en_US")
                                  .format(234123),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      );
    } else {
      LoggerUtils().log("Cart not found", LogType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: 0);
    return Scaffold(
      body: Column(
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
          ),
          Expanded(
            child: PageView(
              pageSnapping: true,
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: const [
                DashboardPage(),
                MemberPage(),
                HistoryPage(),
                InventoryPage(),
                SettingPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
