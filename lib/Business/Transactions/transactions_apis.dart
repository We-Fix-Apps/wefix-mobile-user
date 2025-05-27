import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/model/transactions_model.dart';

import '../../Data/Api/http_request.dart';

class Transactions {
  static TransactionsModel? transactionsModel;

// * Get All Subcategory
  static Future getAllTransactions({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.transactions,
        token: token,
      );

      log('getAllTransactions() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        transactionsModel = TransactionsModel.fromJson(body);

        return transactionsModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getAllTransactions() [ ERROR ] -> $e');
      return [];
    }
  }

  // * Register
  static Future createTransactins({
    required String token,
    required String type,
    required String amount,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.createTransactions,
        token: token,
        data: {
          "Amount": amount,
          "type": type,
        },
      );

      log('createTransactins() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return false;
      }
    } catch (e) {
      log('createTransactins() [ ERROR ] -> $e');
      return false;
    }
  }
}
