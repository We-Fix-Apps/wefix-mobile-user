import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/l10n/l10n.dart';

class LanguageProvider with ChangeNotifier {
  Locale? _locale;
  String? lang;
  Locale? get locale => _locale;

  void setLocal({required Locale locale}) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    lang = locale.languageCode;
    CacheHelper.saveData(key: LANG_CACHE, value: lang);
    notifyListeners();
  }

  void clearLocal() {
    _locale = null;
    notifyListeners();
  }
}
