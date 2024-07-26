import 'dart:typed_data';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
import 'package:printing/printing.dart';

class PrintingUtils {
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
                                    "${NumberFormat().format(e.quantity)} x ${NumberFormat().format(e.price - (100 - e.discount) / 100)}",
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
                              (e.price - (100 - e.discount) / 100)),
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
                      "Subtotal",
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
                              (element.quantity *
                                  (element.price -
                                      (100 - element.discount) / 100)),
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
      LoggerUtils().log(error.toString(), LogType.error);
      throw Exception(error);
    }
  }
}
