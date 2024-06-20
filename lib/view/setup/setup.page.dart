import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:flutter/material.dart';

class SetupStorePage extends StatefulWidget {
  const SetupStorePage({super.key});

  @override
  State<SetupStorePage> createState() => _SetupStorePageState();
}

class _SetupStorePageState extends State<SetupStorePage> {
  final TextEditingController _storeUIDFormField = TextEditingController();
  void _validateStore() {
    StoreModel.checkStoreUID(_storeUIDFormField.text).then((value) {
      if (value != null) {
        StoreModel(
          address: value.address,
          name: value.name,
          code: value.code,
        ).create().then((value) {
          // TODO: Sync the product stock
          router.replace("/main");
        }).catchError((error) {
          LoggerUtils().log(error.toString(), LogType.error);
        });
      } else {
        LoggerUtils().log("Failed to insert to database", LogType.error);
      }
    }).catchError((error) {
      LoggerUtils().log(error.toString(), LogType.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            TextFormField(
              controller: _storeUIDFormField,
            ),
            ElevatedButton(
              onPressed: _validateStore,
              child: const Text("Validate"),
            ),
          ],
        ),
      ),
    );
  }
}
