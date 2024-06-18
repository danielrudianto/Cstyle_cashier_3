import 'package:cstyle_cashier_3/model/model.cart-item.model.dart';
import 'package:cstyle_cashier_3/model/model.product-type.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-cart-selector.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-grid-list.dart';
import 'package:cstyle_cashier_3/view/dashboard/components/dashboard-search-bar.dart';
import 'package:cstyle_cashier_3/viewmodel/cart.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String keyword = "";
  int page = 1;
  bool isLoadingData = false;
  List<ProductModel> products = [];
  List<ProductTypeModel> productTypeNames = [];

  @override
  void initState() {
    fetchProductTypes();
    fetchProducts(1);
    super.initState();
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

  Future<void> fetchProducts(int page) async {
    LoggerUtils()
        .log("Fetching products started ${DateTime.now()}", LogType.info);
    setState(() {
      isLoadingData = true;
      page = page;
    });

    var productResult = await ProductModel.fetch(keyword, page);
    LoggerUtils().log("Found ${products.length} products", LogType.info);

    setState(() {
      products = productResult;
      isLoadingData = false;
    });

    LoggerUtils()
        .log("Fetching products completed ${DateTime.now()}", LogType.info);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addProductToCart(ProductModel product) async {
      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      var selectedCart = cartNotifier.selectedCart;

      if (selectedCart == null) {
        try {
          await cartNotifier.createNewCart();
          await cartNotifier.createNewProduct(
            CartItemModel(
              id: product.id,
              reference: product.reference,
              description: product.description,
              brand: product.brand,
              type: product.type,
              barcode: product.barcode ?? "",
              price: product.price,
              discount: 0,
              quantity: 1,
            ),
          );
        } catch (error) {
          LoggerUtils().log(error.toString(), LogType.error);
        }
      } else {
        var countProduct = cartNotifier.checkExistingProduct(product.id);
        LoggerUtils().log("Found $countProduct similar products", LogType.info);

        if (countProduct < 2) {
          await cartNotifier.createNewProduct(
            CartItemModel(
              id: product.id,
              reference: product.reference,
              description: product.description,
              brand: product.brand,
              type: product.type,
              barcode: product.barcode ?? "",
              price: product.price,
              discount: 0,
              quantity: 1,
            ),
          );
        } else {
          cartNotifier.createExistingProduct(product.id);
        }
      }
    }

    return Scaffold(
      body: Center(
        child: BarcodeKeyboardListener(
          bufferDuration: const Duration(milliseconds: 1000),
          onBarcodeScanned: (barcode) {
            LoggerUtils().log("Barcode scanned: $barcode", LogType.info);
            ProductModel.fetchByBarcode(barcode).then((value) {
              if (value == null) {
                LoggerUtils().log("Product not found", LogType.error);
              } else {
                LoggerUtils().log("Product found", LogType.info);
                // addProductToCart(value);
              }
            }).catchError((error) {
              LoggerUtils().log(error.toString(), LogType.error);
            });
          },
          useKeyDownEvent: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    DashboardSearchBar(
                      onChanged: (value) async {
                        setState(() {
                          keyword = value;
                          page = 1;
                        });
                        await fetchProducts(1);
                      },
                      isDisabled: false,
                    ),
                    Expanded(
                      child: DashboardGridList(
                        products: products,
                        onAddProduct: (ProductModel product) async {
                          await addProductToCart(product);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 600,
                child: CartSelector(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
