import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Data/model/questions_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';

class ReviewsApi {
  static QuestionsModel? questionsModel;
  static Future<QuestionsModel?> getQuestionsReviews(
      {required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.questions,
        token: token,
      );

      log('getQuestionsReviews() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        questionsModel = QuestionsModel.fromJson(body);
        if (questionsModel?.questions.isNotEmpty ?? false) {
          return questionsModel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('getQuestionsReviews() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future addReview(
      {required String token,
      String? phone,
      String? desc,
      List? customerQuestion}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.addReview,
        data: {
          "PhoneNumber": phone,
          "Description": desc,
          "CustomerQuestion": customerQuestion
        },
        token: token,
      );

      log('addReview() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return null;
      }
    } catch (e) {
      log('addReview() [ ERROR ] -> $e');
      return null;
    }
  }
}
