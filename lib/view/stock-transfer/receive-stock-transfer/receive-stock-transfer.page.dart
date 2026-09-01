import 'package:cstyle_cashier_3/utils/motion.utils.dart';
import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 25,
        ),
        Text(
          "Receive stock transfer request",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(
          height: 35,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Colors.black87,
                          ),
                          child: Text(
                            "1. REQUEST OPTIONS",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(
                            15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                DateFormat("dd MMMM yyyy")
                                    .format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Stock transfer",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              SizedBox(
                                height: 300,
                                child: isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : (!isLoading && stockTransfers.isEmpty)
                                        ? const Center(
                                            child: Text("Data not found."),
                                          )
                                        : ListView.builder(
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                onTap: () {
                                                  _fetchStockTransferByID(
                                                      stockTransfers[index]
                                                          .id!);
                                                },
                                                title: Text(
                                                  stockTransfers[index].name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                                subtitle: Text(
                                                  "Requsted from ${(stockTransfers[index].requestFrom == null ? 'Office' : stockTransfers[index].requestFrom!['name'])}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              );
                                            },
                                            itemCount: stockTransfers.length,
                                          ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              PaginationComponent(
                                  pageIndex: page - 1,
                                  dataCount: dataCount,
                                  pageSize: 10,
                                  onPageChange: (value) {
                                    _fetchStockTransfers(value + 1);
                                  })
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Colors.black87,
                          ),
                          child: Text(
                            "2. CONFIRMATION OPTIONS",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(
                            15,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // option between confirm and reject
                                /*
                                  DUA RadioListTile MENJADI SATU SAKELAR.

                                  Terima atau tolak adalah dua pilihan yang
                                  tidak akan pernah bertambah, dan keduanya
                                  saling meniadakan. Radio selebar kartu untuk
                                  itu menghabiskan seratus piksel lebih dan
                                  menyatakan bahwa daftarnya bisa memanjang.

                                  Komponennya sama dengan yang dipakai pemilih
                                  tema dan bahasa struk — lihat components/ui.
                                */
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
                                  onPilih: (nilai) =>
                                      setState(() => isConfirm = nilai),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  controller: controller,
                                  enabled: !isConfirm,
                                  decoration: InputDecoration(
                                    labelText: "Rejection note",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Theme.of(context)
                                .secondaryHeaderColor
                                .withValues(alpha: 0.8),
                          ),
                          child: Text(
                            "YOUR REQUEST",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        stockTransferModel == null
                            ? Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ),
                                child: Center(
                                  child: Text(
                                    "You have not selected any stock transfer",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Name",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      stockTransferModel!.name,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      "Requested from",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      stockTransferModel!.requestFrom == null
                                          ? "Office"
                                          : stockTransferModel!
                                              .requestFrom!['name'],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      "Requested by",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      stockTransferModel!.createdBy,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            stockTransferModel!
                                                .items[index].reference,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                stockTransferModel!
                                                    .items[index].description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                              Text(
                                                "${NumberFormat("#,##0").format(stockTransferModel!.items[index].quantity)} pcs",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount:
                                          stockTransferModel!.items.length,
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: isValid && isConfirm
                        ? _receiveStockTransfer
                        : (isValid && !isConfirm)
                            ? _preRejectStockTransfer
                            : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isValid
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Send",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: isValid
                                      ? Colors.white
                                      : Theme.of(context).disabledColor),
                        ),
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
