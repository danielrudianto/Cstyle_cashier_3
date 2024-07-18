import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';

class UnreceivedStockTransferPage extends StatefulWidget {
  const UnreceivedStockTransferPage({super.key});

  @override
  State<UnreceivedStockTransferPage> createState() =>
      _UnreceivedStockTransferPageState();
}

class _UnreceivedStockTransferPageState
    extends State<UnreceivedStockTransferPage> {
  bool isOpened = false;
  bool isLoading = false;
  List<StockTransferFetchmodel> stockTransfers = [];
  int dataCount = 0;
  int page = 1;

  fetchUnreceivedStockTransfers(int selectedPage) {
    setState(() {
      isLoading = true;
      page = selectedPage;
    });

    StockTransferFetchmodel.fetchUnreceived(page).then((value) {
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

  fetchStockTransferByID(String id) {
    StockTransferFetchmodel.fetchByID(id).then((value) {
      router.pop(value);
    }).catchError((error) {
      router.pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    });
  }

  closeDialog(data) {
    setState(() {
      isOpened = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      router.pop(data);
    });
  }

  @override
  void initState() {
    fetchUnreceivedStockTransfers(1);
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        isOpened = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        closeDialog(null);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOpened ? 1 : 0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(50, 0, 0, 0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 0.8 * ResponsiveUtils.getContainerSize(context),
                height: 0.8 * MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      10,
                    ),
                    topRight: Radius.circular(
                      10,
                    ),
                  ),
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Stock transfer selector",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      closeDialog(null);
                                    },
                                    icon: Icon(Icons.close),
                                  )
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: stockTransfers.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(stockTransfers[index].name),
                                      subtitle: Text(
                                          stockTransfers[index].requestFrom ==
                                                  null
                                              ? "Office"
                                              : stockTransfers[index]
                                                  .requestFrom?['name']),
                                      onTap: () {
                                        fetchStockTransferByID(
                                            stockTransfers[index].id!);
                                      },
                                    );
                                  },
                                ),
                              ),
                              // Paginator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: page == 1
                                        ? null
                                        : () {
                                            fetchUnreceivedStockTransfers(
                                                page - 1);
                                          },
                                    icon: Icon(Icons.arrow_back),
                                  ),
                                  Text("$page"),
                                  IconButton(
                                    onPressed: stockTransfers.length < 10
                                        ? null
                                        : () {
                                            fetchUnreceivedStockTransfers(
                                                page + 1);
                                          },
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
