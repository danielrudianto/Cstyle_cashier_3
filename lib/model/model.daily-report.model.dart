import 'package:cstyle_cashier_3/model/model.store.model.dart';
import 'package:cstyle_cashier_3/utils/api.utils.dart';
import 'package:dio/dio.dart';

class DailyReportModel {
  static downloadDailyReport() async {
    try {
      var store = await StoreModel.getCurrentProfile();
      var report = await ApiUtils().getRequest(
          "cashier/report", {}, Options(headers: {"store": store!.code}));

      return report;
    } catch (e) {
      throw Exception(e);
    }
  }
}
