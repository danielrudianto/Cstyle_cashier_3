import 'dart:async';
import 'package:cstyle_cashier_3/components/clip-path/trapezoid.clip-path.dart';
import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class CheckStockPage extends StatefulWidget {
  const CheckStockPage({super.key});

  @override
  State<CheckStockPage> createState() => _CheckStockPageState();
}

class _CheckStockPageState extends State<CheckStockPage> {
  GlobalKey flushBarKey = GlobalKey();

  Timer? _debounce;
  bool isLoading = true;
  int page = 1;
  String keyword = "";
  List<StoreModel> stores = [];
  List<ProductStockFetchItemModel> items = [];
  int count = 0;

  ScrollController controller = ScrollController();
  TextEditingController searchController = TextEditingController();

  _fetchItems(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });

    ProductStockFetchModel.checkServerStock(page, searchController.text)
        .then((value) {
      setState(() {
        isLoading = false;
        stores = value.stores;
        items = value.data;
        count = value.count;
      });
    }).catchError((error) {
      LoggerUtils().log(error.toString(), LogType.error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.error)));
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        page = 1;
      });

      _fetchItems(1);
    });
  }

  @override
  void initState() {
    _fetchItems(1);
    controller.addListener(() {
      // debounce 500ms
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _fetchItems(1);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black54,
          ),
          onPressed: () {
            router.pop();
          },
        ),
        title: Text("Check stock",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black54,
            )),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: TrapezoidClipPath(),
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 211, 212, 253),
              height: 500,
            ),
          ),
          ClipPath(
            clipper: InversedTrapezoidClipPath(),
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(180, 124, 136, 248),
              height: 500,
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // Box shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                width: ResponsiveUtils.getContainerSize(context),
                child: Column(
                  children: [
                    TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 280,
                      child: items.isEmpty
                          ? Center(
                              child: Text("Data not found."),
                            )
                          : StickyHeadersTable(
                              scrollControllers: ScrollControllers(
                                  verticalBodyController: controller),
                              cellAlignments: const CellAlignments.fixed(
                                contentCellAlignment: Alignment.center,
                                stickyLegendAlignment: Alignment.center,
                                stickyColumnAlignment: Alignment.centerLeft,
                                stickyRowAlignment: Alignment.center,
                              ),
                              cellDimensions: const CellDimensions.fixed(
                                contentCellWidth: 150,
                                contentCellHeight: 100,
                                stickyLegendWidth: 250,
                                stickyLegendHeight: 100,
                              ),
                              columnsLength: stores.length,
                              legendCell: const Text(
                                'Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              columnsTitleBuilder: (i) {
                                return Text(
                                  "${stores[i].name.split(" ").first}\n${stores[i].name.split(" ").skip(1).join(" ")}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                              rowsLength: items.length,
                              rowsTitleBuilder: (rowIndex) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      items[rowIndex].reference,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      items[rowIndex].description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                              },
                              contentCellBuilder: (i, j) {
                                var storeID = stores[i].id;
                                var dataStockIndex = items[j]
                                    .stock
                                    .indexWhere((e) => e.storeID == storeID);

                                return Text(
                                  dataStockIndex == -1
                                      ? "0"
                                      : NumberFormat().format(
                                          items[j]
                                              .stock[dataStockIndex]
                                              .quantity,
                                        ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                );
                              },
                            ),
                    ),
                    PaginationComponent(
                        pageIndex: page - 1,
                        dataCount: count,
                        pageSize: 20,
                        onPageChange: (value) {
                          page = value + 1;
                          _fetchItems(page);
                        }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
