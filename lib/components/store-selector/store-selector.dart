import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:flutter/material.dart';

class StoreSelector extends StatefulWidget {
  const StoreSelector({super.key});

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  bool isLoading = true;
  List<StoreModel> stores = [];

  _fetchStores() {
    StoreModel.fetchStores().then((fetchedStores) {
      setState(() {
        stores = fetchedStores;
      });
    }).catchError((error) {
      LoggerUtils().log(
        error,
        LogType.error,
      );

      // close dialog
      Navigator.pop(context);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  initState() {
    super.initState();
    _fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 480,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              // border width 0
              border: Border.all(
                width: 0,
                color: Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Select store",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            stores[index].name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          onTap: () {
                            Navigator.pop(context, stores[index]);
                          },
                        );
                      },
                      itemCount: stores.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
