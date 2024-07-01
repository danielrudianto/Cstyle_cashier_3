import 'dart:async';

import 'package:cstyle_cashier_3/model/model.product-type.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-grid-list.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-header.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-type-selector.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  String keyword = "";
  int page = 1;
  bool isLoadingData = false;
  List<ProductModel> products = [];
  List<ProductTypeModel> productTypeNames = [];
  List<String> selectedProductTypes = [];
  bool isLastPage = false;
  Timer? _debounce;

  int maxPage = 3;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Timer(const Duration(milliseconds: 250), () {
      fetchProductTypes();
      fetchProducts(1);
    });

    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.offset >=
              scrollController.position.maxScrollExtent - 100 &&
          !isLastPage &&
          !isLoadingData) {
        fetchProducts(page + 1);
      }
    });

    super.initState();
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchProductTypes() async {
    LoggerUtils()
        .log("Fetching product types started ${DateTime.now()}", LogType.info);
    var result = await ProductTypeModel.getList();
    setState(() {
      productTypeNames = result;
    });
    LoggerUtils().log(
        "Fetching product types completed ${DateTime.now()}", LogType.info);
  }

  Future<void> onSearch(String selectedKeyword) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        keyword = selectedKeyword;
      });
      fetchProducts(1);
    });
  }

  Future<void> fetchProducts(int selectedPage) async {
    LoggerUtils()
        .log("Fetching products started ${DateTime.now()}", LogType.info);
    setState(() {
      isLoadingData = true;
      page = selectedPage;
    });

    if (page == 1) {
      setState(() {
        products = [];
        isLastPage = false;
      });
    }

    ProductModel.fetch(selectedProductTypes, keyword, page)
        .then((productResult) {
      LoggerUtils().log("Found ${productResult.length} products", LogType.info);

      setState(() {
        products.addAll(productResult);
        isLoadingData = false;
      });

      if (products.length < 25) {
        setState(() {
          isLastPage = true;
        });
      }

      if (products.length >= maxPage * 25) {
        setState(() {
          isLastPage = true;
        });
      }

      LoggerUtils()
          .log("Fetching products completed ${DateTime.now()}", LogType.info);
    }).catchError((error) {
      LoggerUtils().log(error.toString(), LogType.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addProductToCart(ProductModel product) async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var selectedCart = cartNotifier.selectedCart;

      if (selectedCart == null) {
        try {
          await cartNotifier.createNewCart();
          await cartNotifier.createNewProduct(product);
        } catch (error) {
          LoggerUtils().log(error.toString(), LogType.error);
          showSnackbar(error.toString());
        }
      } else {
        var countProduct = cartNotifier.checkExistingProduct(product.id);
        LoggerUtils().log("Found $countProduct similar products", LogType.info);

        if (countProduct < 2) {
          await cartNotifier.createNewProduct(product);
        } else {
          cartNotifier.createExistingProduct(product.id);
        }
      }
    }

    return Consumer<CompareNotifier>(builder: (_, value, __) {
      return Scaffold(
        key: scaffoldKey,
        floatingActionButton: value.selectedComparisson.length <= 1
            ? null
            : FloatingActionButton(
                tooltip: "Compare products",
                child: const Icon(
                  Icons.compare_arrows,
                ),
                onPressed: () {
                  router.push("/compare");
                },
              ),
        body: BarcodeKeyboardListener(
          bufferDuration: const Duration(milliseconds: 500),
          onBarcodeScanned: (barcode) {
            LoggerUtils().log("Barcode scanned: $barcode", LogType.info);
            ProductModel.fetchByBarcode(barcode).then((product) {
              if (product == null) {
                LoggerUtils().log("Product not found", LogType.error);
                showSnackbar("Product not found.");
              } else {
                LoggerUtils().log("Product found", LogType.info);
                addProductToCart(product);
              }
            }).catchError((error) {
              LoggerUtils().log(error.toString(), LogType.error);
              showSnackbar("Product not found");
            });
          },
          useKeyDownEvent: true,
          child: Column(
            children: [
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: const Color.fromARGB(255, 224, 224, 224),
                  color: isLoadingData
                      ? const Color.fromARGB(255, 161, 121, 220)
                      : Colors.transparent,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardTypeSelector(
                      productTypes:
                          productTypeNames.map((x) => x.name).toList(),
                      selectedTypes: selectedProductTypes,
                      onUpdateSelectedTypes: (List<String> types) {
                        setState(() {
                          selectedProductTypes = types;
                        });

                        fetchProducts(1);
                      },
                      onSearch: (value) {
                        onSearch(value);
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const DashboardHeader(),
                          Expanded(
                            child: RawScrollbar(
                              controller: scrollController,
                              thumbColor:
                                  const Color.fromARGB(255, 161, 121, 220),
                              radius: const Radius.circular(8.0),
                              thickness: 8.0,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: DashboardGridList(
                                  products: products,
                                  onAddProduct: (ProductModel product) async {
                                    await addProductToCart(product);
                                  },
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
      );
    });
  }
}
