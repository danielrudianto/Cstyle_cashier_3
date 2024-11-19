import 'package:cstyle_cashier_3/components/pagination/pagination.dart';
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to send stock transfer.")));
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 15,
        ),
        Text(
          "Send stock transfer request",
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
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(0),
                  //     border: Border.all(
                  //       color: Colors.grey.shade300,
                  //       width: 1,
                  //     ),
                  //     color: Colors.transparent,
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         width: double.infinity,
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 15,
                  //           horizontal: 20,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(0),
                  //           color: Colors.black87,
                  //         ),
                  //         child: Text(
                  //           "2. CONFIRMATION OPTIONS",
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .headlineMedium!
                  //               .copyWith(
                  //                 color: Colors.white,
                  //               ),
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.all(
                  //           15,
                  //         ),
                  //         child: Container(
                  //           padding: const EdgeInsets.all(
                  //             15,
                  //           ),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               // option between confirm and reject
                  //               RadioListTile<bool>(
                  //                   title: const Text("Confirm"),
                  //                   groupValue: isConfirm,
                  //                   value: true,
                  //                   activeColor: Colors.black54,
                  //                   onChanged: isFetchingStockTransferData
                  //                       ? null
                  //                       : (value) {
                  //                           setState(() {
                  //                             isConfirm = true;
                  //                           });
                  //                         }),
                  //               RadioListTile<bool>(
                  //                   title: const Text("Reject"),
                  //                   groupValue: isConfirm,
                  //                   value: false,
                  //                   activeColor: Colors.black54,
                  //                   onChanged: isFetchingStockTransferData
                  //                       ? null
                  //                       : (value) {
                  //                           setState(() {
                  //                             isConfirm = false;
                  //                           });
                  //                         }),
                  //               const SizedBox(
                  //                 height: 15,
                  //               ),
                  //               TextFormField(
                  //                 controller: controller,
                  //                 enabled: !isConfirm,
                  //                 decoration: InputDecoration(
                  //                   labelText: "Rejection note",
                  //                   border: OutlineInputBorder(
                  //                     borderRadius: BorderRadius.circular(10),
                  //                   ),
                  //                 ),
                  //                 maxLines: 4,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                                .withOpacity(0.8),
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
                    onTap: isValid ? _sendStockTransfer : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isValid
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).disabledColor.withOpacity(0.2),
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

    // return Scaffold(
    //   body: Column(
    //     children: [
    //       const TopStockTransfer(),
    //       SingleChildScrollView(
    //         child: Stack(
    //           alignment: Alignment.topCenter,
    //           children: [
    //             ClipPath(
    //               clipper: TrapezoidClipPath(),
    //               child: Container(
    //                 width: double.infinity,
    //                 color: const Color.fromARGB(255, 211, 212, 253),
    //                 height: 420,
    //               ),
    //             ),
    //             ClipPath(
    //               clipper: InversedTrapezoidClipPath(),
    //               child: Container(
    //                 width: double.infinity,
    //                 color: const Color.fromARGB(180, 124, 136, 248),
    //                 height: 420,
    //               ),
    //             ),
    //             SizedBox(
    //               width: ResponsiveUtils.getContainerSize(context),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   const SizedBox(
    //                     height: 15,
    //                   ),
    //                   Row(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       IconButton(
    //                           icon: const Icon(Icons.arrow_back),
    //                           onPressed: () {
    //                             router.pop();
    //                           }),
    //                       const Text(
    //                         "Send stock transfer",
    //                         style: TextStyle(
    //                           color: Color.fromARGB(255, 4, 30, 73),
    //                           fontSize: 28,
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(
    //                     height: 25,
    //                   ),
    //                   Container(
    //                     width: double.infinity,
    //                     padding: const EdgeInsets.all(20.0),
    //                     decoration: BoxDecoration(
    //                       color: Colors.white,
    //                       // Radius 10
    //                       borderRadius: BorderRadius.circular(10),
    //                       // elevation
    //                       boxShadow: [
    //                         BoxShadow(
    //                           color:
    //                               const Color.fromARGB(0, 0, 0, 0).withOpacity(0.1),
    //                           spreadRadius: 5,
    //                           blurRadius: 7,
    //                           offset: const Offset(0, 3),
    //                         ),
    //                       ],
    //                     ),
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Row(
    //                           children: [
    //                             const CircleAvatar(
    //                               radius: 15,
    //                               backgroundColor:
    //                                   Color.fromARGB(255, 201, 170, 252),
    //                               child: Text("1"),
    //                             ),
    //                             const SizedBox(
    //                               width: 15,
    //                             ),
    //                             Text(
    //                               "Select stock transfer",
    //                               style: Theme.of(context).textTheme.labelLarge,
    //                             ),
    //                           ],
    //                         ),
    //                         const SizedBox(
    //                           height: 15,
    //                         ),
    //                         ElevatedButton(
    //                           // dark blue background
    //                           style: ElevatedButton.styleFrom(
    //                             backgroundColor: const Color.fromARGB(255, 0, 32, 92),
    //                             shape: RoundedRectangleBorder(
    //                               borderRadius: BorderRadius.circular(25),
    //                               // padding vertical 15, horizontal 35
    //                             ),
    //                           ),
    //                           onPressed: _openStockTransferSelector,
    //                           child: const Padding(
    //                             padding: EdgeInsets.symmetric(
    //                               horizontal: 35,
    //                               vertical: 10,
    //                             ),
    //                             child: Text(
    //                               "Select stock transfer",
    //                               style: TextStyle(
    //                                 color: Color.fromARGB(255, 255, 255, 255),
    //                                 fontWeight: FontWeight.normal,
    //                                 fontSize: 18,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 15,
    //                   ),
    //                   Container(
    //                     width: double.infinity,
    //                     padding: const EdgeInsets.all(20),
    //                     decoration: BoxDecoration(
    //                       color: Colors.white,
    //                       // Radius 10
    //                       borderRadius: BorderRadius.circular(10),
    //                       // elevation
    //                       boxShadow: [
    //                         BoxShadow(
    //                           color:
    //                               const Color.fromARGB(0, 0, 0, 0).withOpacity(0.1),
    //                           spreadRadius: 5,
    //                           blurRadius: 7,
    //                           offset: const Offset(0, 3),
    //                         ),
    //                       ],
    //                     ),
    //                     child: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Row(
    //                           children: [
    //                             const CircleAvatar(
    //                               radius: 15,
    //                               backgroundColor:
    //                                   Color.fromARGB(255, 201, 170, 252),
    //                               child: Text("2"),
    //                             ),
    //                             const SizedBox(
    //                               width: 15,
    //                             ),
    //                             Text(
    //                               "Send stock transfer",
    //                               style: Theme.of(context).textTheme.labelLarge,
    //                             ),
    //                           ],
    //                         ),
    //                         const SizedBox(
    //                           height: 15,
    //                         ),
    //                         ...buildStockTransferText(),
    //                         const SizedBox(
    //                           height: 25,
    //                         ),
    //                         Row(
    //                           children: [
    //                             const Spacer(),
    //                             ElevatedButton(
    //                               // dark blue background
    //                               style: ElevatedButton.styleFrom(
    //                                 backgroundColor:
    //                                     const Color.fromARGB(255, 0, 32, 92),
    //                                 shape: RoundedRectangleBorder(
    //                                   borderRadius: BorderRadius.circular(25),
    //                                   // padding vertical 15, horizontal 35
    //                                 ),
    //                               ),
    //                               onPressed:
    //                                   stockTransferModel == null || isSubmitting
    //                                       ? null
    //                                       : _sendStockTransfer,
    //                               child: const Padding(
    //                                 padding: EdgeInsets.symmetric(
    //                                   horizontal: 35,
    //                                   vertical: 10,
    //                                 ),
    //                                 child: Text(
    //                                   "Send stock transfer",
    //                                   style: TextStyle(
    //                                     color:
    //                                         Color.fromARGB(255, 255, 255, 255),
    //                                     fontWeight: FontWeight.normal,
    //                                     fontSize: 18,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
