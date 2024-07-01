import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:cstyle_cashier_3/utils/logger.utils.dart';
import 'package:dio/dio.dart';

class SyncUtils {
  static Future<void> sync() async {
    LoggerUtils().log("Sync started", LogType.info);

    SQLBillSyncModel.fetchUnsyncedBills().then((value) async {
      LoggerUtils().log("Found ${value.length} bills unsynced", LogType.info);
      if (value.isNotEmpty) {
        var store = await SQLStoreModel.getCurrentProfile();
        ApiUtils()
            .postRequest(
                "cashier/sync",
                {
                  "data": value.map((e) {
                    return e.toMap();
                  }).toList(),
                },
                Options(
                  headers: {"store": store!.code},
                ))
            .then((result) {})
            .catchError((error) {});
      } else {
        LoggerUtils().log("No bills to sync", LogType.info);
      }
    }).catchError((error) {
      LoggerUtils().log(error.toString(), LogType.error);
    }).whenComplete(() {
      LoggerUtils().log("Sync completed", LogType.info);
      Future.delayed(const Duration(seconds: 15), () {
        sync();
      });
    });
  }
}
