import 'package:cstyle_cashier_3/model/model.stock-transfer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListStockTransferDetail extends StatefulWidget {
  final String id;
  const ListStockTransferDetail({required this.id, super.key});

  @override
  State<ListStockTransferDetail> createState() =>
      _ListStockTransferDetailState();
}

class _ListStockTransferDetailState extends State<ListStockTransferDetail> {
  StockTransferFetchmodel? stockTransfer;
  bool isLoading = true;

  _fetchStockTransferDetail() async {
    var fetchedStockTransfer = await StockTransferFetchmodel.fetchByID(
      widget.id,
    );

    setState(() {
      stockTransfer = fetchedStockTransfer;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _fetchStockTransferDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: stockTransfer == null
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Name",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    stockTransfer!.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Request From",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    stockTransfer!.requestFrom == null
                        ? "Office"
                        : stockTransfer!.requestFrom!['name'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Request To",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    stockTransfer!.requestTo == null
                        ? "Office"
                        : stockTransfer!.requestTo!['name'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Created by",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    stockTransfer!.createdBy,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Created at",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    DateFormat("dd MMM yyyy HH:mm")
                        .format(stockTransfer!.createdAt),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Items",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: stockTransfer!.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          stockTransfer!.items[index].reference,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        subtitle: Text(
                          stockTransfer!.items[index].description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Text(
                          NumberFormat.decimalPattern()
                              .format(stockTransfer!.items[index].quantity),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
