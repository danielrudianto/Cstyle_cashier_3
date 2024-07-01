import 'package:cstyle_cashier_3/model/model.product-stock.model.dart';
import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:cstyle_cashier_3/utils/responsive.utils.dart';
import 'package:cstyle_cashier_3/utils/router.utils.dart';
import 'package:cstyle_cashier_3/utils/sync.utils.dart';
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
      LoggerUtils()
          .log("Store found, applying to local database", LogType.info);
      StoreModel(
        address: value.address,
        name: value.name,
        code: value.code,
        phoneNumber: value.phoneNumber,
      ).create().then((store) {
        LoggerUtils().log("Fetching stock from server", LogType.info);
        ProductStockModel.fetchServerStock(value.code).then((stocks) async {
          await ProductStockModel.updateServerStock(stocks);
          LoggerUtils().log("Stock updated", LogType.info);
          SyncUtils.sync();
          router.replace("/main");
        }).catchError((error) {
          LoggerUtils().log(error.toString(), LogType.error);
        });
      }).catchError((error) {
        LoggerUtils().log(error.toString(), LogType.error);
      });
    }).catchError((error) {
      LoggerUtils().log(error.toString(), LogType.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        161,
        121,
        220,
      ),
      body: Center(
        child: SizedBox(
          width: ResponsiveUtils.getContainerSizeMultiplier(context, [
            0.5,
            0.75,
            1,
            1,
          ]),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/IconReverted.webp",
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "CSTYLE CASHIER APPLICATION",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _storeUIDFormField,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Store Code",
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: _validateStore,
                  child: const Text("Validate"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
