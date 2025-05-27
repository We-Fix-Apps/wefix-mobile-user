import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/contract_details_model.dart';

class ContractsApis {
  static ContractDetails? contractModel;
  static Future<ContractDetails?> getContractDetails(
      {required String token}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.contractDetails,
        token: token,
      );

      log('getContractDetails() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        contractModel = ContractDetails.fromJson(body);

        return contractModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getContractDetails() [ ERROR ] -> $e');
      return null;
    }
  }
}
