import 'dart:typed_data';
import 'package:cstyle_cashier_3/model/model.cart.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:printing/printing.dart';

class PrintingUtils {
  static Future<Uint8List> generateCartPDF(
    CartModel cart,
    List<Map<String, dynamic>> payments,
    String? memberID,
    UserModel employeeID,
  ) async {
    try {
      final doc = pw.Document();
      var store = await StoreModel.getCurrentProfile();

      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();

      final image = await imageFromAssetBundle('assets/images/logo-bill.png');

      double payment = payments.fold(
          0.0, (previousValue, element) => previousValue + element['amount']);

      double value = cart.products.fold(
          0,
          (previousValue, element) =>
              previousValue +
              (element.quantity *
                          element.price *
                          (100 - element.discount) /
                          100000)
                      .floor() *
                  1000);

      double changes = payment - value;

      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            75 * PdfPageFormat.mm,
            double.infinity,
            marginLeft: 20,
            marginRight: 15,
            marginTop: 15,
            marginBottom: 15,
            // add watermarkF
          ),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Image(
                  image,
                  width: 150,
                  height: 35,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  store!.name,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  store.address,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "${store.phoneNumber} - we ship worldwide.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 25,
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Date",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      DateFormat("dd/MM/yyyy").format(cart.date),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                // Create row for member
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Member",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.SizedBox(
                      width: 20,
                    ),
                    pw.Spacer(),
                    pw.Text(
                      (memberID == null
                          ? "Non-member"
                          : memberID.toString().toUpperCase()),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: pw.TextOverflow.span,
                    ),
                  ],
                ),
                pw.Divider(),
                ...cart.products.map(
                  (e) {
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                e.description,
                                style: pw.TextStyle(
                                  font: regularFont,
                                  fontSize: 8,
                                ),
                                maxLines: 2,
                                overflow: pw.TextOverflow.clip,
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Text(
                                    "${NumberFormat().format(e.quantity)} x ${NumberFormat().format((e.price * (100 - e.discount) / 100000).floor() * 1000)}",
                                    style: pw.TextStyle(
                                      font: regularFont,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Text(
                                    "${NumberFormat().format(e.discount)} %",
                                    style: pw.TextStyle(
                                      font: regularFont,
                                      fontSize: 8,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              ]),
                            ],
                          ),
                        ),
                        pw.Text(
                          NumberFormat().format((e.quantity *
                                      e.price *
                                      (100 - e.discount) /
                                      100000)
                                  .floor() *
                              1000),
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      NumberFormat().format(
                        cart.products.fold(
                          0.0,
                          (previousValue, element) =>
                              previousValue +
                              ((element.quantity *
                                          element.price *
                                          (100 - element.discount) /
                                          100000)
                                      .floor() *
                                  1000),
                        ),
                      ),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(children: [
                  pw.Text(
                    "Payments",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 6,
                    ),
                  ),
                  pw.Spacer(),
                ]),
                pw.Column(
                    children: payments.map((e) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        // Capitalize the first letter
                        "${e['method'].toString().substring(0, 1)}${e['method'].toString().substring(1)}",
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 6,
                        ),
                      ),
                      e['method'].toString() == "Cash"
                          ? pw.Text(
                              NumberFormat().format(e['amount'] - changes),
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 6,
                              ),
                            )
                          : pw.Text(
                              NumberFormat().format(e['amount']),
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 6,
                              ),
                            ),
                    ],
                  );
                }).toList()),
                pw.SizedBox(
                  height: 25,
                ),
                // Text "Thank you for your purchase"
                pw.Text(
                  "The manufacture offers 1 MONTH WARRANTY for your device.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "For more information, please refer to our TERMS AND CONDITIONS.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "We do not proceed to any refund or exchange.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Follow us on social media for more information and promotions.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "IG / FB : CSTYLE INDONESIA",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Thank you for your visit",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
                pw.Text(
                  "Have a nice day",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
                pw.Text(
                  "Created by ${employeeID.name}",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
              ],
            );
          },
        ),
      );
      return doc.save();
    } catch (error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      throw Exception(error);
    }
  }

  static Future<Uint8List> generatePDF(String name) async {
    try {
      final doc = pw.Document();
      var billCode = await BillCodeModelPrint.fetchByName(name);
      var store = await StoreModel.getCurrentProfile();

      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();

      final image = await imageFromAssetBundle('assets/images/logo-bill.png');

      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            75 * PdfPageFormat.mm,
            double.infinity,
            marginLeft: 20,
            marginRight: 15,
            marginTop: 15,
            marginBottom: 15,
          ),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Image(
                  image,
                  width: 150,
                  height: 35,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  store!.name,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  store.address,
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "${store.phoneNumber} - we ship worldwide.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 25,
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Date",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      DateFormat("dd/MM/yyyy").format(billCode.date),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                // Create row for member
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Member",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.SizedBox(
                      width: 20,
                    ),
                    pw.Spacer(),
                    pw.Text(
                      (billCode.memberID == null
                          ? "Non-member"
                          : billCode.memberID.toString().toUpperCase()),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: pw.TextOverflow.span,
                    ),
                  ],
                ),
                pw.Divider(),
                ...billCode.bills.map(
                  (e) {
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                e.description,
                                style: pw.TextStyle(
                                  font: regularFont,
                                  fontSize: 8,
                                ),
                                maxLines: 2,
                                overflow: pw.TextOverflow.clip,
                              ),
                              pw.Row(children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Text(
                                    "${NumberFormat().format(e.quantity)} x ${NumberFormat().format((e.price * (100 - e.discount) / 100000).floor() * 1000)}",
                                    style: pw.TextStyle(
                                      font: regularFont,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 1,
                                  child: pw.Text(
                                    "${NumberFormat().format(e.discount)} %",
                                    style: pw.TextStyle(
                                      font: regularFont,
                                      fontSize: 8,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                              ]),
                            ],
                          ),
                        ),
                        pw.Text(
                          NumberFormat().format(e.quantity *
                              (e.price * (100 - e.discount) / 100000).floor() *
                              1000),
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total",
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      NumberFormat().format(
                        billCode.bills.fold(
                          0.0,
                          (previousValue, element) =>
                              previousValue +
                              ((element.quantity *
                                          element.price *
                                          (100 - element.discount) /
                                          100000)
                                      .floor() *
                                  1000),
                        ),
                      ),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(children: [
                  pw.Text(
                    "Payments",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 6,
                    ),
                  ),
                  pw.Spacer(),
                ]),
                pw.Column(
                    children: billCode.payments.map((e) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        // Capitalize the first letter
                        "${e.paymentMethod[0].toUpperCase()}${e.paymentMethod.substring(1)}",
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 6,
                        ),
                      ),
                      pw.Text(
                        NumberFormat().format(e.amount),
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 6,
                        ),
                      ),
                    ],
                  );
                }).toList()),
                pw.SizedBox(
                  height: 25,
                ),
                // Text "Thank you for your purchase"
                pw.Text(
                  "The manufacture offers 1 MONTH WARRANTY for your device.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "For more information, please refer to our TERMS AND CONDITIONS.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "We do not proceed to any refund or exchange.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Follow us on social media for more information and promotions.",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "IG / FB : CSTYLE INDONESIA",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Thank you for your visit",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
                pw.Text(
                  "Have a nice day",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Text(
                  "Created by ${billCode.createdByName}",
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                  ),
                ),
              ],
            );
          },
        ),
      );
      return doc.save();
    } catch (error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
      throw Exception(error);
    }
  }

  static Future<Uint8List> generateStockTransferPDF(
      StockTransferFetchmodel transfer, UserModel user) async {
    try {
      final doc = pw.Document();

      final boldFont = await PdfGoogleFonts.nunitoBold();
      final regularFont = await PdfGoogleFonts.nunitoRegular();
      final mediumFont = await PdfGoogleFonts.nunitoSemiBold();

      final image = await imageFromAssetBundle('assets/images/logo-bill.png');

      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            75 * PdfPageFormat.mm,
            double.infinity,
            marginLeft: 20,
            marginRight: 15,
            marginTop: 15,
            marginBottom: 15,
          ),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Image(
                  image,
                  width: 150,
                  height: 35,
                ),
                pw.SizedBox(
                  height: 25,
                ),
                pw.Text("Stock Transfer Request",
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 10,
                    )),
                pw.Text(transfer.name,
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 8,
                    )),
                pw.SizedBox(height: 15),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Date',
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 10,
                          child: pw.Text(
                            ":",
                            style: pw.TextStyle(fontSize: 8, font: regularFont),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            DateFormat.yMMMMd().format(transfer.createdAt),
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: regularFont,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Request from',
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 10,
                          child: pw.Text(
                            ":",
                            style: pw.TextStyle(fontSize: 8, font: regularFont),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                transfer.requestFrom == null
                                    ? "Office"
                                    : transfer.requestFrom!['name'],
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: boldFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Printed by',
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 10,
                          child: pw.Text(
                            ":",
                            style: pw.TextStyle(fontSize: 8, font: regularFont),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                user.name,
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  font: boldFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Create a table with 6 columns
                pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.2,
                    ),
                    verticalInside: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.2,
                    ),
                    top: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.75,
                    ),
                    bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.75,
                    ),
                    left: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.75,
                    ),
                    right: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.75,
                    ),
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(8),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(3.5),
                    4: const pw.FlexColumnWidth(2),
                    5: const pw.FlexColumnWidth(3.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                width: 0.75,
                              ),
                            ),
                          ),
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            "#",
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                width: 0.75,
                              ),
                            ),
                          ),
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            "Description",
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                width: 0.75,
                              ),
                            ),
                          ),
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            "Qty",
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: boldFont,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    for (int i = 0; i < transfer.items.length; i++)
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            NumberFormat.decimalPattern().format(i + 1),
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: mediumFont,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            "[${transfer.items[i].reference}] ${transfer.items[i].description}",
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: mediumFont,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: pw.Text(
                            NumberFormat.decimalPattern()
                                .format(transfer.items[i].quantity),
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              font: mediumFont,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ]),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Note",
                      style: pw.TextStyle(fontSize: 8, font: boldFont),
                      textAlign: pw.TextAlign.left,
                    ),
                    pw.Text(
                      transfer.note == "" ? "-" : transfer.note,
                      textAlign: pw.TextAlign.left,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      return doc.save();
    } catch (e) {
      throw Exception(e);
    }
  }
}
