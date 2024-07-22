import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:flutter/material.dart';

class StoreSelector extends StatefulWidget {
  final Function onStoreSelected;
  const StoreSelector({super.key, required this.onStoreSelected});

  @override
  State<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  List<StoreModel> stores = [];
  bool selected = false;
  bool isLoadingStores = true;

  _fetchStores() async {
    StoreModel.fetchStores().then((value) {
      setState(() {
        stores = value;
        isLoadingStores = false;
      });
    });
  }

  @override
  initState() {
    _fetchStores();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<StoreModel?>(
      label: Text("Store"),
      width: 400,
      dropdownMenuEntries: stores.map((e) {
        return DropdownMenuEntry(value: e, label: e.name);
      }).toList(),
      // outline text box
      onSelected: (value) {
        setState(() {
          selected = true;
          widget.onStoreSelected(value);
        });
      },
      // white background
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.all(10.0),
        // borer
        border: OutlineInputBorder(),
        // border when focused
        focusedBorder: OutlineInputBorder(),
      ),
    );
  }
}
