import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/all_language_model.dart';
import 'package:wefix/Data/model/app_languege_model.dart';

class LanguageApis {
  // * Get Application Language
  static AppLanguageModel? appLanguageModel;
  static List<AppLanguages> allLanguage = [];
  static Future getAppLang({required String lang}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.lang,
      );

      log('getAppLang() => [ Status ] :- ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        appLanguageModel = AppLanguageModel.fromJson(body);
        if (appLanguageModel?.languages?.isNotEmpty ?? false) {
          allLanguage = appLanguageModel!.languages!;
          return allLanguage;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('getAppLang() => [ Error ] :- ${e.toString()}');
      return [];
    }
  }

  // * Get Language Code
  static AllLanguageModel? allLanguageModel;
  static List<AppLanguagess> allLanguages = [];
  static Future<List<AppLanguagess>> getAppLangCode() async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.langCode,
      );

      log('getAppLangCode() => [ Status ] :- ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        allLanguageModel = AllLanguageModel.fromJson(body);
        if (allLanguageModel?.appLanguages?.isNotEmpty ?? false) {
          allLanguages = allLanguageModel!.appLanguages!;
          return allLanguages;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('getAppLangCode() => [ Error ] :- ${e.toString()}');
      return [];
    }
  }
}
