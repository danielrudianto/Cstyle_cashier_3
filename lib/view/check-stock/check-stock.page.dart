import 'dart:async';
import 'dart:io';
import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
  bool isDownloading = false;

  ScrollController controller = ScrollController();
  TextEditingController searchController = TextEditingController();

  _fetchItems(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });

    StoreModel.getCurrentProfile().then((store) {
      ProductStockFetchModel.checkServerStock(page, searchController.text)
          .then((value) {
        ProductStockModel.fetchLocalStock(value.data.map((e) {
          return e.id;
        }).toList())
            .then((stocks) {
          List<ProductStockFetchItemModel> itemList = [];
          for (var e in value.data) {
            var stockIndex = stocks.indexWhere((x) => x.mongoID == e.id);
            var availableStocks = [
              ProductStockFetchStoreModel(
                storeID: store!.code,
                quantity: stockIndex == -1 ? 0 : stocks[stockIndex].stock,
              ),
            ];
            availableStocks.addAll(e.stock);

            itemList.add(
              ProductStockFetchItemModel(
                id: e.id,
                reference: e.reference,
                description: e.description,
                brand: e.brand,
                type: e.type,
                stock: availableStocks,
              ),
            );
          }

          List<StoreModel> finalStores = [
            StoreModel(
              name: store!.name,
              address: store.address,
              id: store.code,
            )
          ];
          finalStores.addAll(value.stores);

          setState(() {
            isLoading = false;
            stores = finalStores;
            items = itemList;
            count = value.count;
          });
        });
      }).catchError((error) {
        LoggerUtils().log("Error", LogType.error,
            error: error, stackTrace: StackTrace.current);
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future<List<int>?> _downloadStocks() async {
    var value = await ProductStockFetchModel.downloadServerStock();

    var excel = Excel.createExcel();
    for (var i = 0; i < value.stores.length; i++) {
      // create sheet
      var sheet =
          excel[value.stores[i].id == null ? "Office" : value.stores[i].name];

      // create header which consist of reference, description, brand, type, and stock
      /*
        Tanpa `const`. TextCellValue pada paket excel versi baru bukan lagi
        const constructor, jadi daftar ini tidak bisa lagi dinyatakan const.
      */
      sheet.appendRow([
        TextCellValue("Reference"),
        TextCellValue("Description"),
        TextCellValue("Brand"),
        TextCellValue("Type"),
        TextCellValue("Stock"),
      ]);

      // create rows
      for (var j = 0; j < value.data.length; j++) {
        var storeID = value.stores[i].id;
        var dataStockIndex = value.data[j].stock.indexWhere(
          (e) => e.storeID == storeID,
        );

        int quantity = dataStockIndex == -1
            ? 0
            : value.data[j].stock[dataStockIndex].quantity;

        sheet.appendRow([
          TextCellValue(value.data[j].reference),
          TextCellValue(value.data[j].description),
          TextCellValue(value.data[j].brand),
          TextCellValue(value.data[j].type),
          TextCellValue(quantity.toString()),
        ]);

        CellStyle style = CellStyle(numberFormat: NumFormat.standard_1);
        var cell = sheet.cell(CellIndex.indexByString('E${j + 2}'));
        cell.value = IntCellValue(quantity);
        cell.cellStyle = style;

        // make the column A to D to be auto fit
        sheet.setColumnAutoFit(0);
        sheet.setColumnAutoFit(1);
        sheet.setColumnAutoFit(2);
        sheet.setColumnAutoFit(3);
      }
    }

    return excel.encode();
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
    // controller.addListener(() {
    //   // debounce 500ms
    //   if (_debounce?.isActive ?? false) _debounce?.cancel();
    //   _debounce = Timer(const Duration(milliseconds: 500), () {
    //     _fetchItems(1);
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    // color
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: isDownloading
                  ? null
                  : () {
                      setState(() {
                        isDownloading = true;
                      });
                      _downloadStocks().then((value) async {
                        try {
                          Directory? directory = await getDownloadsDirectory();
                          if (directory == null) {
                          } else {
                            String filePath =
                                "${directory.path}/stock_${DateTime.now().microsecondsSinceEpoch.toString()}.xlsx";
                            if (value == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Failed to encode Excel fild"),
                              ));
                            } else {
                              File(filePath)
                                ..createSync(recursive: false)
                                ..writeAsBytesSync(value);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text("Stock card downloaded successfully."),
                              ));

                              LoggerUtils().log(
                                  "Stock card downloaded successfully.",
                                  LogType.info);
                            }
                          }
                        } catch (error) {
                          LoggerUtils().log("Error", LogType.error,
                              error: error, stackTrace: StackTrace.current);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        }
                      }).catchError((error) {
                        LoggerUtils().log("Error", LogType.error,
                            error: error, stackTrace: StackTrace.current);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())));
                      }).whenComplete(() {
                        setState(() {
                          isDownloading = false;
                        });
                      });
                    },
              icon: Icon(
                Icons.download,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 286,
          child: items.isEmpty
              ? const Center(
                  child: Text("Data not found."),
                )
              : StickyHeadersTable(
                  scrollControllers:
                      ScrollControllers(verticalBodyController: controller),
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
                  legendCell: Text(
                    'Product',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  columnsTitleBuilder: (i) {
                    return Text(
                      "${stores[i].name.split(" ").first}\n${stores[i].name.split(" ").skip(1).join(" ")}",
                      style: Theme.of(context).textTheme.bodyLarge,
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
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          items[rowIndex].description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                  contentCellBuilder: (i, j) {
                    var storeID = stores[i].id;
                    var dataStockIndex =
                        items[j].stock.indexWhere((e) => e.storeID == storeID);

                    return Text(
                      dataStockIndex == -1
                          ? "0"
                          : NumberFormat().format(
                              items[j].stock[dataStockIndex].quantity,
                            ),
                      style: Theme.of(context).textTheme.bodyLarge,
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
              // scroll controller, go to top
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }),
      ],
    );
  }
}
