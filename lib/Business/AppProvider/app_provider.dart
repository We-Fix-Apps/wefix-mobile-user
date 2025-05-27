import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';

import 'package:wefix/Data/model/all_products_model.dart';
import 'package:wefix/Data/model/app_languege_model.dart';
import 'package:wefix/Data/model/user_model.dart';

class AppProvider with ChangeNotifier {
  UserModel? userModel;
  String? fcmToken;
  String? accessToken;
  LatLng? currentLocation;

  List<Placemark>? places;
  int? cartCount;

  LatLng? position;
  String? lang;
  String? appColor;

  DateTime? selectedDate;

  List<Map<String, dynamic>> _selectedAnswers = [];

  List<Map<String, dynamic>> get selectedAnswers => _selectedAnswers;

  void selectAnswer(int questionId, String rating) {
    final index =
        _selectedAnswers.indexWhere((a) => a["QuestionId"] == questionId);
    if (index != -1) {
      _selectedAnswers[index]["Rating"] = rating;
    } else {
      _selectedAnswers.add({"QuestionId": questionId, "Rating": rating});
    }
    notifyListeners();
  }

  String? realStateId;
  setRealStateId(String id) {
    realStateId = id;

    log("realStateId : $realStateId");
    notifyListeners();
  }

  clearRealState() {
    realStateId = null;

    log("realStateId : $realStateId");
    notifyListeners();
  }

  String? getRating(int questionId) {
    final found = _selectedAnswers.firstWhere(
      (a) => a["QuestionId"] == questionId,
      orElse: () => {},
    );
    return found["Rating"];
  }

  void clearAnswers() {
    _selectedAnswers.clear();
    notifyListeners();
  }

  TextEditingController tellUsMore = TextEditingController();
  TextEditingController phone = TextEditingController();
  saveTellUsMore({String? desc, String? mobile}) {
    tellUsMore.text = desc ?? '';
    phone.text = mobile ?? '';

    log("tellUsMore : ${tellUsMore.text} , phone : ${phone.text}");
    notifyListeners();
  }

  List<AppLanguages> allLanguage = [];

  void addColor(String color) {
    appColor = color.replaceAll(' ', '');
    notifyListeners();
  }

  void saveCusrrentLocation(LatLng target) {
    currentLocation = target;
    notifyListeners();
  }

  bool? isMaterialFromProvider = false;
  isMaterailFromProvider(v) {
    isMaterialFromProvider = v;
    notifyListeners();
  }

  List attachments = [];

  clearAttachments() {
    attachments.clear();
    notifyListeners();
  }

  saveAttachments(List att) {
    attachments = att;
    notifyListeners();
  }

  void createSelectedDate(DateTime date) {
    selectedDate = date ?? DateTime.now();
    notifyListeners();
  }

  Map appoitmentInfo = {};

  void saveAppoitmentInfo(Map<String, dynamic> info) {
    appoitmentInfo = info;

    log(appoitmentInfo.toString());
    notifyListeners();
  }

  void clearAppoitmentInfo() {
    appoitmentInfo = {};
    notifyListeners();
  }

  void addCartCount(int count) {
    cartCount = count;
    notifyListeners();
  }

  void addUser({UserModel? user}) {
    userModel = user;
    CacheHelper.saveData(
        key: CacheHelper.userData, value: json.encode(userModel));
    notifyListeners();
  }

  Locale? locale;

  void setLanguae(String langCode) {
    lang = langCode;

    locale = Locale(langCode);

    CacheHelper.saveData(key: LANG_CACHE, value: langCode);

    notifyListeners();
  }

  // void updateUserData({
  //   String? email,
  //   String? name,
  //   String? image,
  //   String? phone,
  // }) {
  //   userModel?.userInfo?.email = email;
  //   userModel?.userInfo?.fullName = name;
  //   userModel?.userInfo?.image = image;
  //   CacheHelper.saveData(
  //       key: CacheHelper.userData, value: json.encode(userModel));
  //   notifyListeners();
  // }

  List<Locale> allLocale = [const Locale('ar')];

  void addLang(List<AppLanguages> languages) {
    allLanguage = languages;

    notifyListeners();
  }

  void addGlobal(List<String> global) {
    for (var element in global) {
      if (allLocale.where((e) => e.languageCode == element).isEmpty) {
        allLocale.add(Locale(element));
      }
    }
  }

  TextEditingController desc = TextEditingController();

  saveDesc(String? value) {
    desc.text = value ?? '';
    notifyListeners();
  }

  void clearUser() {
    userModel = null;
    CacheHelper.saveData(
        key: CacheHelper.userData, value: CacheHelper.clearUserData);
    notifyListeners();
  }

  TextEditingController ad = TextEditingController();
  Future addAddress({List<Placemark>? placemarks}) async {
    places = placemarks;

    ad.text =
        "${placemarks?[0].country ?? ""} ,${placemarks?[0].subAdministrativeArea ?? ""} , ${placemarks?[0].street ?? ""}";

    notifyListeners();
  }

  void addLatAndLong({LatLng? pos}) {
    position = pos;

    notifyListeners();
  }

  List<AllProducts> allProducts = [];
  List<String> suggestionList = [];
  List<String> searchResults = [];

  void addProductsSearch(List<AllProducts> products) {
    allProducts = products;
    suggestionList =
        products.map((item) => item.productName?.toLowerCase() ?? '').toList();
    searchResults =
        products.map((item) => item.productName?.toLowerCase() ?? '').toList();
    notifyListeners();
  }

  void clearProductsSearch() {
    allProducts = [];
    suggestionList = [];
    searchResults = [];
    notifyListeners();
  }

  //  Todo : internet connection
  ConnectivityResult? connectivityResult;
}
