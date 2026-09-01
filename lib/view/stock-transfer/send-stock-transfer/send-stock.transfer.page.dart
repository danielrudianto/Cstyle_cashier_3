import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/components/panel-transfer.dart';
import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/printing.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendStockTransferPage extends StatefulWidget {
  const SendStockTransferPage({super.key});

  @override
  State<SendStockTransferPage> createState() => _SendStockTransferPageState();
}

class _SendStockTransferPageState extends State<SendStockTransferPage> {
  bool isSubmitting = false;
  StockTransferFetchmodel? stockTransferModel;
  List<StockTransferFetchmodel> stockTransfers = [];

  int page = 1;
  int dataCount = 0;
  bool isLoading = false;
  bool isFetchingStockTransferData = false;

  get isValid {
    // first of all, stock transfer may not be null
    if (stockTransferModel == null) {
      return false;
    }

    return true;
  }

  _fetchStockTransfers(int selectedPage) {
    setState(() {
      isLoading = true;
      page = selectedPage;
    });

    StockTransferFetchmodel.fetchUnsent(page).then((value) {
      setState(() {
        dataCount = value['count'];
        stockTransfers = value['data'];
      });
    }).catchError((error) {
      router.pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  _fetchStockTransferByID(String id) {
    setState(() {
      isFetchingStockTransferData = true;
    });

    StockTransferFetchmodel.fetchByID(id).then((value) {
      setState(() {
        stockTransferModel = value;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }).whenComplete(() {
      setState(() {
        isFetchingStockTransferData = false;
      });
    });
  }

  Future<Printer?> _checkPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("printer:name") == null ||
        prefs.getString("printer:url") == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Default printer is not found. Please select a printer"),
      ));
      return await Printing.pickPrinter(context: context);
    } else {
      return Printer(url: prefs.getString("printer:url")!);
    }
  }

  _sendStockTransfer() {
    _checkPrinter().then((printer) {
      if (printer == null || !printer.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Printer is not available"),
        ));
      } else {
        showModalBottomSheet<UserModel?>(
            // ignore: use_build_context_synchronously
            context: context,
            showDragHandle: false,
            enableDrag: false,
            isDismissible: false,
            builder: (context) {
              return const SelectEmployee();
            }).then((user) async {
          if (user != null) {
            setState(() {
              isSubmitting = true;
            });

            StockTransferModel.send({
              "id": stockTransferModel!.id,
              "items": stockTransferModel!.items.map((e) {
                return {
                  "itemID": e.id,
                  "quantity": e.quantity,
                };
              }).toList(),
            }).then((value) async {
              try {
                await Printing.directPrintPdf(
                  printer: printer,
                  onLayout: (format) => PrintingUtils.generateStockTransferPDF(
                      stockTransferModel!, user),
                );

                stockTransferModel!.items.forEach((x) async {
                  await SQLProductModel.updateStock(x.id, x.quantity);
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Stock transfer successfully sent")));

                setState(() {
                  stockTransferModel = null;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Failed to send stock transfer.")));
              }

              _fetchStockTransfers(1);
            }).catchError((error) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.toString())));
            }).whenComplete(() {
              setState(() {
                isSubmitting = false;
              });
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    _fetchStockTransfers(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        const KepalaHalaman(
          penanda: "INVENTORY",
          judul: "Send transfer",
          keterangan: "Pick a request another store has made, and send the "
              "stock out.",
        ),
        const SizedBox(height: 22),
        BarisMeta(
          isi: [
            Meta("DATE", DateFormat("d MMM yyyy").format(DateTime.now())),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JudulBagian("WAITING TO BE SENT", atas: 0),
                  DaftarTransfer(
                    transfers: stockTransfers,
                    terpilihID: stockTransferModel?.id,
                    memuat: isLoading,
                    page: page,
                    dataCount: dataCount,
                    onPilih: (transfer) =>
                        _fetchStockTransferByID(transfer.id!),
                    onPageChange: (value) => _fetchStockTransfers(value + 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JudulBagian("SELECTED TRANSFER", atas: 0),
                  RincianTransfer(
                    transfer: stockTransferModel,
                    memuat: isFetchingStockTransferData,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          isValid && !isSubmitting ? _sendStockTransfer : null,
                      child: Text(
                        isSubmitting ? "Sending..." : "Send transfer",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
