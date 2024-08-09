import 'dart:async';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
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
  bool isLoading = false;
  List<ProductModel> products = [];
  int page = 1;
  int productCount = 0;

  TextEditingController searchController = TextEditingController();
  Timer? debounceTime;

  closeDialog(data) {
    router.pop(data);
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
        products = value['data'];
        productCount = value['count'];
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
    return Container(
      width: 400,
      height: 400,
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
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            products[index].reference,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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

            PaginationComponent(
                pageIndex: page - 1,
                dataCount: productCount,
                pageSize: 20,
                onPageChange: (selectedPage) {
                  setState(() {
                    page = selectedPage + 1;
                  });

                  fetchProducts(page);
                })
          ],
        ),
      ),
    );
  }
}
