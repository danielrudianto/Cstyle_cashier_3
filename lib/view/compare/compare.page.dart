import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cstyle_cashier_3/model/model.product.model.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/components/clip-path/trapezoid.clip-path.dart';
import 'package:cstyle_cashier_3/components/product-image.component.dart';
import 'package:cstyle_cashier_3/viewmodel/compare.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  TextEditingController noteController1 = TextEditingController();
  TextEditingController noteController2 = TextEditingController();
  TextEditingController noteController3 = TextEditingController();

  int? prefered;

  _shareProductsComparison() {
    Uint8List? images;
    _generatePDF().then((value) async {
      await for (var page in Printing.raster(value)) {
        images = page.asImage().toUint8List();
      }

      if (images != null) {
        await Share.shareXFiles([
          XFile.fromData(
            images!,
            mimeType: 'image/png',
          ),
        ],
            text:
                "Hi, I just asked CStyle to compare these products and here are the results.");
      }
    });
  }

  _generatePDF() async {
    var items = Provider.of<CompareNotifier>(context, listen: false)
        .selectedComparisson;
    final doc = pw.Document();
    var rows = await _buildPwRows(items);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text("Product comparisson"),
            pw.Text(DateFormat("dd/MM/yyyy").format(DateTime.now())),
            pw.Divider(),
            pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
              },
              children: rows,
            ),
            // Same as the table below, but only the first image
          ]);
        },
      ),
    );

    return doc.save();
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
                child: ProductImageComponent(autoPlay: false, id: e.id),
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
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/recommended.png",
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text("Recommended by CSTYLE INDONESIA",
                              textAlign: TextAlign.center),
                        ],
                      ),
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

  Future<List<pw.TableRow>> _buildPwRows(List<ProductModel> products) async {
    final image = await imageFromAssetBundle('assets/images/logo-bill.png');
    final preferedImage =
        await imageFromAssetBundle("assets/images/recommended.png");
    return <pw.TableRow>[
      pw.TableRow(children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            "Product name",
            style: pw.TextStyle(
              color: PdfColors.black,
            ),
          ),
        ),
        ...products.map((e) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  e.reference,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  e.description,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          );
        })
      ]),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Images",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.map((e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text("Daniel"),
            );
          })
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Brand",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.map((e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                e.brand,
                style: pw.TextStyle(
                  color: PdfColors.black,
                ),
              ),
            );
          })
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Type",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.map((e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                e.type,
                style: pw.TextStyle(
                  color: PdfColors.black,
                ),
              ),
            );
          })
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Price",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.map((e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(NumberFormat.decimalPattern().format(e.price),
                  style: pw.TextStyle(
                    color: PdfColors.grey800,
                  )),
            );
          })
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Notes",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.mapIndexed((index, e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(index == 0
                  ? (noteController1.text.isEmpty ? "-" : noteController1.text)
                  : index == 1
                      ? (noteController2.text.isEmpty
                          ? "-"
                          : noteController3.text)
                      : (noteController3.text.isEmpty
                          ? "-"
                          : noteController3.text)),
            );
          })
        ],
      ),
      pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              "Status",
              style: pw.TextStyle(
                color: PdfColors.black,
              ),
            ),
          ),
          ...products.mapIndexed((index, e) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              child: prefered == index
                  ? pw.Text(
                      "Recommended",
                      style: pw.TextStyle(
                        color: PdfColors.green,
                      ),
                    )
                  : pw.Container(
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        "-",
                        style: pw.TextStyle(
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
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
        onPressed: _shareProductsComparison,
        child: Icon(Icons.share),
      ),
      body: Consumer<CompareNotifier>(builder: (_, value, __) {
        return SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ClipPath(
                clipper: TrapezoidClipPath(),
                child: Container(
                  width: double.infinity,
                  color: Color.fromARGB(255, 211, 212, 253),
                  height: 500,
                ),
              ),
              ClipPath(
                clipper: InversedTrapezoidClipPath(),
                child: Container(
                  width: double.infinity,
                  color: Color.fromARGB(180, 124, 136, 248),
                  height: 500,
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getContainerSize(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              router.pop();
                            }),
                        Text(
                          "Compare products",
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 30, 73),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Radius 10
                        borderRadius: BorderRadius.circular(10),
                        // elevation
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                                width:
                                    ResponsiveUtils.getContainerSize(context) -
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
                                  children:
                                      _buildRows(value.selectedComparisson),
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
            ],
          ),
        );
      }),
    );
  }
}
