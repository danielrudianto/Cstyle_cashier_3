import 'package:cstyle_cashier_3/db/db.bill_code.model.dart';
import 'package:cstyle_cashier_3/db/db.store.model.dart';
import 'package:cstyle_cashier_3/model/model.bill-code.model.dart';
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
            .then((result) async {
          for (var i = 0; i < result.length; i++) {
            await BillCodeModelSync.updateSync(
                result[i]['name'], result[i]['_id']);
          }
        }).catchError((error) {
          LoggerUtils().log("Error", LogType.error,
              error: error, stackTrace: StackTrace.current);
        });
      } else {
        LoggerUtils().log("No bills to sync", LogType.info);
      }
    }).catchError((error) {
      LoggerUtils().log("Error", LogType.error,
          error: error, stackTrace: StackTrace.current);
    }).whenComplete(() {
      LoggerUtils().log("Sync completed", LogType.info);
      Future.delayed(const Duration(seconds: 30), () {
        sync();
      });
    });
  }
}
