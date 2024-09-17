
import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/components/product-image.component.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  TextEditingController noteController1 = TextEditingController();
  TextEditingController noteController2 = TextEditingController();
  TextEditingController noteController3 = TextEditingController();

  ScreenshotController screenshotController = ScreenshotController();
  bool isGenerating = false;

  int? prefered;

  _shareProductsComparison() async {
    setState(() {
      isGenerating = true;
    });

    var image = await _generateImage();
    screenshotController
        .captureFromWidget(image)
        .then((Uint8List? image) async {
      // copy image to clipboard
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        return; // Clipboard API is not supported on this platform.
      }

      final item = DataWriterItem();
      item.add(Formats.png(image!));
      await clipboard.write([item]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image copied to clipboard"),
        ),
      );
    }).catchError((error) {
      LoggerUtils().log(
        "Error capturing image: $error",
        LogType.error,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error capturing image"),
        ),
      );
    }).whenComplete(() {
      setState(() {
        isGenerating = false;
      });
    });
  }

  Future<Widget> _generateImage() async {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 25,
        ),
        Container(
          padding: const EdgeInsets.all(20.0),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Product Comparisson",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                DateFormat("dd MMMM yyyy hh:mm:ss").format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: ResponsiveUtils.getContainerSize(context) - 40,
                    child: Table(
                      // Border horizontal only black12
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.black12,
                          width: 1,
                        ),
                        verticalInside: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        top: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: _buildPrintedRows(Provider.of<CompareNotifier>(
                        context,
                        listen: false,
                      ).selectedComparisson),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Status mentioned above is only an opinion from our personel. The actual status may vary based on the actual product. We are not responsible for any loss or damage caused by this comparison.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildRows(List<ProductModel> products) {
    return <TableRow>[
      TableRow(children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Product name",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ...products.map((e) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.reference,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  e.description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          );
        })
      ]),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Images",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ProductImageComponent(
                  autoPlay: false,
                  id: e.id,
                  bordered: true,
                  static: false,
                ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Brand",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                e.brand,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Type",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                e.type,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Price",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                NumberFormat.decimalPattern().format(e.price),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Notes",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.mapIndexed((index, e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: index == 0
                    ? noteController1
                    : index == 1
                        ? noteController2
                        : noteController3,
                // Decoration
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  // hint note
                  hintText: "Notes",
                ),
                maxLines: 3,
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Status",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.mapIndexed((index, e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: prefered == index
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          prefered = null;
                        });
                      },
                      child: const Text("Recommended by CSTYLE INDONESIA",
                          textAlign: TextAlign.center),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          setState(() {
                            prefered = index;
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "-",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            );
          })
        ],
      ),
    ];
  }

  List<TableRow> _buildPrintedRows(List<ProductModel> products) {
    return <TableRow>[
      TableRow(children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Product name",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ...products.map((e) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.reference,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  e.description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          );
        })
      ]),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Images",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ProductImageComponent(
                  autoPlay: false,
                  id: e.id,
                  bordered: false,
                  static: true,
                ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Brand",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                e.brand,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Type",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                e.type,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Price",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.map((e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                NumberFormat.decimalPattern().format(e.price),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Notes",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.mapIndexed((index, e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                index == 0
                    ? noteController1.text
                    : index == 1
                        ? noteController2.text
                        : noteController3.text,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
              ),
            );
          })
        ],
      ),
      TableRow(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Status",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ...products.mapIndexed((index, e) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: prefered == index
                  ? const Text("Recommended by CSTYLE INDONESIA",
                      textAlign: TextAlign.center)
                  : const Text("-"),
            );
          })
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isGenerating ? null : _shareProductsComparison,
        child: Icon(isGenerating ? Icons.bubble_chart : Icons.share),
      ),
      appBar: AppBar(
        title: Text(
          "Compare products",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Theme.of(context).canvasColor,
        // border bottom 1px divider color
        shadowColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Theme.of(context).dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: Consumer<CompareNotifier>(builder: (_, value, __) {
        return SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: ResponsiveUtils.getContainerSize(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hi! Here are your products to compare. Please note that this feature is only available for 2 - 3 products at a time. You can also share this table via Whatsapp application using the share button on the top right corner.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: ResponsiveUtils.getContainerSize(context) -
                                  40,
                              child: Table(
                                // Border horizontal only black12
                                border: const TableBorder(
                                  horizontalInside: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                  verticalInside: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  top: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                columnWidths: const <int, TableColumnWidth>{
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: _buildRows(value.selectedComparisson),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Status mentioned above is only an opinion from our personel. The actual status may vary based on the actual product. We are not responsible for any loss or damage caused by this comparison.",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
