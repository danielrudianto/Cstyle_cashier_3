import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckStockPage extends StatefulWidget {
  const CheckStockPage({super.key});

  @override
  State<CheckStockPage> createState() => _CheckStockPageState();
}

class _CheckStockPageState extends State<CheckStockPage> {
  StoreModel? store;

  List<StoreModel> stores = [];
  List<ProductStockFetchItemModel> items = [];

  int page = 1;
  TextEditingController controller = TextEditingController();

  _fetchStock(int selectedPage) {
    setState(() {
      page = selectedPage;
    });

    ProductStockFetchModel.checkServerStock(selectedPage, controller.text)
        .then((value) {
      setState(() {
        stores = value.stores;
        items = value.data;
      });
    });
  }

  @override
  void initState() {
    StoreModel.getCurrentProfile().then((value) {
      setState(() {
        store = value;
      });
    });

    _fetchStock(page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Form field
          TextField(),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                children: [
                  TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Text("Product"),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Text(store?.name ?? ""),
                    ),
                    ...stores.map((e) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        child: Text(e.name),
                      );
                    }),
                  ]),
                  ...items.map((e) {
                    return TableRow(children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Text(e.reference),
                      ),
                      Container(),
                      ...stores.map((store) {
                        var currentStock = e.stock.firstWhereOrNull(
                            (element) => element.storeID == store.id);
                        return Container(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            NumberFormat.decimalPattern().format(
                                currentStock == null
                                    ? 0
                                    : currentStock.quantity),
                          ),
                        );
                      }),
                    ]);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
