import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/view/stock-transfer/components/panel-transfer.dart';
import 'package:cstyle_cashier_3/components/select-employee/select-employee.dart';
import 'package:cstyle_cashier_3/db/db.product.model.dart';
import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/model/model.user.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/components/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiveStockTransferPage extends StatefulWidget {
  const ReceiveStockTransferPage({super.key});

  @override
  State<ReceiveStockTransferPage> createState() =>
      _ReceiveStockTransferPageState();
}

class _ReceiveStockTransferPageState extends State<ReceiveStockTransferPage> {
  bool isSubmitting = false;
  bool isLoading = false;
  bool isLoadingStockTransfer = false;
  bool isConfirm = true;

  int page = 1;
  int dataCount = 0;

  StockTransferFetchmodel? stockTransferModel;
  List<StockTransferFetchmodel> stockTransfers = [];
  TextEditingController controller = TextEditingController();

  get isValid {
    if (stockTransferModel == null) {
      return false;
    }

    if (!isConfirm && controller.text.isEmpty) {
      return false;
    }

    return true;
  }

  _fetchStockTransfers(int selectedPage) {
    setState(() {
      page = selectedPage;
      isLoading = true;
    });

    StockTransferFetchmodel.fetchUnreceived(page).then((value) {
      setState(() {
        stockTransfers = value['data'];
        dataCount = value['count'];
      });
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
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
      isLoadingStockTransfer = true;
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
        isLoadingStockTransfer = false;
      });
    });
  }

  _receiveStockTransfer() {
    showModalBottomSheet<UserModel?>(
        // ignore: use_build_context_synchronously
        context: context,
        showDragHandle: false,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return const SelectEmployee();
        }).then((value) {
      if (value != null) {
        setState(() {
          isSubmitting = true;
        });

        StockTransferModel.receive(
          stockTransferModel!.id!,
          value.code,
        ).then((value) {
          stockTransferModel!.items.forEach((x) async {
            await SQLProductModel.updateStock(x.id, x.quantity * -1);
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Stock transfer successfully received")));

          setState(() {
            stockTransferModel = null;
          });

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

  _preRejectStockTransfer() {
    showModalBottomSheet<UserModel?>(
        // ignore: use_build_context_synchronously
        context: context,
        showDragHandle: false,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return const SelectEmployee();
        }).then((user) {
      if (user != null) {
        bukaDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 50,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                          "Are you sure you want to reject this stock transfer?"),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                // padding vertical 15, horizontal 35
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text(
                              "Reject",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ).then((value) {
          if (value == true) {
            _rejectStockTransfer(user.code);
          }
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
    });
  }

  _rejectStockTransfer(String userCode) {
    setState(() {
      isSubmitting = true;
    });

    StockTransferModel.reject(
      stockTransferModel!.id!,
      userCode,
      controller.text,
    ).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock transfer rejected")));

      setState(() {
        stockTransferModel = null;
      });

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

  @override
  initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
    _fetchStockTransfers(page);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const KepalaHalaman(
          penanda: "INVENTORY",
          judul: "Receive transfer",
          keterangan: "Confirm the stock another store sent here, or turn "
              "it back with a note.",
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
                  const JudulBagian("WAITING TO BE RECEIVED", atas: 0),
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
                    memuat: isLoadingStockTransfer,
                  ),
                  /*
                    Keputusannya berdampingan dengan rinciannya, bukan di bawah
                    daftar di kolom sebelah: urutan kerjanya baca dulu, baru
                    putuskan, dan mata tidak perlu menyeberang halaman di
                    antara keduanya.
                  */
                  const JudulBagian("DECISION"),
                  PilihanSegmen<bool>(
                    terpilih: isConfirm,
                    aktif: !isLoadingStockTransfer,
                    opsi: const [
                      OpsiSegmen(
                        nilai: true,
                        label: "Confirm",
                        ikon: Icons.check_rounded,
                      ),
                      OpsiSegmen(
                        nilai: false,
                        label: "Reject",
                        ikon: Icons.close_rounded,
                      ),
                    ],
                    onPilih: (nilai) => setState(() => isConfirm = nilai),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller,
                    enabled: !isConfirm,
                    decoration: dekorasiIsian(
                      context,
                      petunjuk: "Why this transfer is being turned back",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    /*
                      Tombolnya dulu bertuliskan "Send" untuk dua tindakan yang
                      berlawanan — menerima maupun menolak. Sekarang labelnya
                      menyebut yang akan terjadi.
                    */
                    child: FilledButton(
                      onPressed: !isValid || isSubmitting
                          ? null
                          : isConfirm
                              ? _receiveStockTransfer
                              : _preRejectStockTransfer,
                      child: Text(
                        isSubmitting
                            ? "Working..."
                            : isConfirm
                                ? "Receive transfer"
                                : "Reject transfer",
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
