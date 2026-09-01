import 'dart:async';

import 'package:cstyle_cashier_3/model/model.product-type.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-checkout.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-grid-list.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-header.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-search.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-type-selector.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<DashboardTypeSelectorState> typeSelectorState =
      GlobalKey<DashboardTypeSelectorState>();

  String keyword = "";
  int page = 1;
  bool isLoadingData = false;
  List<ProductModel> products = [];
  List<ProductTypeModel> productTypeNames = [];
  List<String> selectedProductTypes = [];
  bool isLastPage = false;
  Timer? _debounce;
  Timer? _debounceBarcode;

  bool _isFocusing = false;

  int maxPage = 3;

  ScrollController scrollController = ScrollController();
  FocusNode barcodeFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    Timer(const Duration(milliseconds: 300), () {
      fetchProductTypes();
      fetchProducts(1);
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
    });
  }

  Future<void> addProductToCart(ProductModel product) async {
    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
    var selectedCart = cartNotifier.selectedCart;
    LoggerUtils().log(
        "Add Product to Cart terpanggil ${DateTime.now()}", LogType.warning);

    if (selectedCart == null) {
      try {
        await cartNotifier.createNewCart();
        await cartNotifier.createNewProduct(product);
      } catch (error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
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

  void _onBarcodeScanned() {
    LoggerUtils().log("Barcode scanned: $barcode", LogType.info);
    if (barcode.length < 2) {
      return;
    } else {
      ProductModel.fetchByBarcode(barcode).then((product) {
        if (product == null) {
          LoggerUtils().log("Product not found", LogType.error);
          showSnackbar("Product not found.");
        } else {
          LoggerUtils().log("Product found", LogType.info);
          if ((product.stock ?? 0) <= 0) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Insufficient stock. If you have reported this issue and adjustment has been made, please go to setting and override manually.",
                ),
                action: SnackBarAction(
                  label: "OK",
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else {
            addProductToCart(product);
          }
        }
      }).catchError((error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
        showSnackbar("Product not found");
      });
    }
  }

  var barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
        Transparan: gradien permukaan kerja dilukis di akar halaman utama, dan
        latar Scaffold yang buram akan menutupinya. Lihat pageview.page.dart.
      */
      backgroundColor: Colors.transparent,
      key: scaffoldKey,
      // ignore: deprecated_member_use
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: barcodeFocusNode,
        onKey: (event) {
          if (_isFocusing) {
            barcode = "";
            return;
          } else {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey.keyLabel.length == 1 &&
                  event.logicalKey.keyLabel.contains(RegExp(r'[0-9]'))) {
                barcode += event.logicalKey.keyLabel;
                _debounceBarcode?.cancel();
                _debounceBarcode = Timer(const Duration(milliseconds: 100), () {
                  // Reset the state here
                  setState(() {
                    barcode = '';
                  });
                });
              } else if (event.logicalKey.keyLabel == 'Enter') {
                if (barcode.length < 2) {
                  return;
                } else {
                  _onBarcodeScanned();
                }
              }
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardTypeSelector(
                    key: typeSelectorState,
                    productTypes: productTypeNames.map((x) => x.name).toList(),
                    selectedTypes: selectedProductTypes,
                    onUpdateSelectedTypes: (List<String> types) {
                      setState(() {
                        selectedProductTypes = types;
                      });

                      fetchProducts(1);
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        /*
                          Pencarian duduk bersama tabel yang disaringnya, tepat
                          di atas kepala kolomnya. Sebelumnya ia berada di kolom
                          kiri, sehingga mengetik di satu sisi layar dan melihat
                          hasilnya di sisi lain.
                        */
                        DashboardSearch(
                          onSearch: (value) => onSearch(value),
                          onFocus: () => setState(() => _isFocusing = true),
                          onUnfocus: () => setState(() {
                            _isFocusing = false;
                            barcodeFocusNode.requestFocus();
                          }),
                        ),
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
                  DashboardCheckout(
                    onComingBack: () {
                      fetchProducts(1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
