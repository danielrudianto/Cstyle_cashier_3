import 'dart:async';

import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductSelectorPage extends StatefulWidget {
  final String? storeID;
  final List<dynamic> selectedItems;
  const ProductSelectorPage({
    super.key,
    this.storeID,
    required this.selectedItems,
  });

  @override
  State<ProductSelectorPage> createState() => _ProductSelectorPageState();
}

class _ProductSelectorPageState extends State<ProductSelectorPage> {
  bool isLoading = false;
  List<ProductModel> products = [];
  int page = 1;
  int productCount = 0;
  List<dynamic> selectedItems = [];

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

    selectedItems = widget.selectedItems;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 750,
      height: 500,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).cardColor,
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
                          leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: selectedItems
                                      .any((e) => e['id'] == products[index].id)
                                  ? const Icon(Icons.check)
                                  : const Icon(
                                      Icons.add,
                                    )),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 25,
                          ),
                          title: Text(
                            products[index].reference,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                products[index].description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                "Current stock: ${NumberFormat.decimalPattern().format(products[index].stock)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () {
                            // closeDialog(products[index]);
                            var itemIndex = selectedItems.indexWhere(
                                (e) => e['id'] == products[index].id);

                            if (itemIndex == -1) {
                              setState(() {
                                selectedItems.add({
                                  "id": products[index].id,
                                  "reference": products[index].reference,
                                  "description": products[index].description,
                                });
                              });
                            } else {
                              setState(() {
                                selectedItems.removeAt(itemIndex);
                              });
                            }
                          },
                        );
                      },
                    ),
            ),
            // Paginator

            Row(
              children: [
                Expanded(
                  child: PaginationComponent(
                      pageIndex: page - 1,
                      dataCount: productCount,
                      pageSize: 20,
                      onPageChange: (selectedPage) {
                        setState(() {
                          page = selectedPage + 1;
                        });

                        fetchProducts(page);
                      }),
                ),
                // button to apply
                ElevatedButton(
                  onPressed: () {
                    closeDialog(selectedItems);
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
