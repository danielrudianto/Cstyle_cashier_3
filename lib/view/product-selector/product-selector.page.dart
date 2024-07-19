import 'dart:async';

import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductSelectorPage extends StatefulWidget {
  final String? storeID;
  const ProductSelectorPage({super.key, this.storeID});

  @override
  State<ProductSelectorPage> createState() => _ProductSelectorPageState();
}

class _ProductSelectorPageState extends State<ProductSelectorPage> {
  bool isOpened = false;
  bool isLoading = false;
  List<ProductModel> products = [];
  int page = 1;
  int productCount = 0;

  TextEditingController searchController = TextEditingController();
  Timer? debounceTime;

  closeDialog(data) {
    setState(() {
      isOpened = false;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      router.pop(data);
    });
  }

  fetchProducts(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });
    ProductModel.fetchServerProducts(
      page,
      widget.storeID,
      searchController.text,
    ).then((value) {
      setState(() {
        products = value;
      });
    }).catchError((error) {
      closeDialog(null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    fetchProducts(1);
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isOpened = true;
      });
    });

    searchController.addListener(() {
      if (debounceTime != null) {
        debounceTime!.cancel();
      }
      debounceTime = Timer(const Duration(milliseconds: 500), () {
        fetchProducts(1);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        closeDialog(null);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(50, 0, 0, 0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 0.8 * ResponsiveUtils.getContainerSize(context),
              height: 0.8 * MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    10,
                  ),
                  topRight: Radius.circular(
                    10,
                  ),
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: "Search product",
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    closeDialog(null);
                                  },
                                  icon: Icon(Icons.close),
                                )
                              ],
                            ),

                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      products[index].reference,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          products[index].description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Current stock: ${NumberFormat.decimalPattern().format(products[index].stock)}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      closeDialog(products[index]);
                                    },
                                  );
                                },
                              ),
                            ),
                            // Paginator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    fetchProducts(page - 1);
                                  },
                                  icon: Icon(Icons.arrow_back),
                                ),
                                Text("$page"),
                                IconButton(
                                  onPressed: products.length < 10
                                      ? null
                                      : () {
                                          fetchProducts(page + 1);
                                        },
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
