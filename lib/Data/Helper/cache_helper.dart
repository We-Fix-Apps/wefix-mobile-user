import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic getData({required String key}) {
    try {
      if (_sharedPreferences == null) {
        return null;
      }
      return _sharedPreferences!.get(key);
    } catch (e) {
      return null;
    }
  }

  static dynamic removeData({required String key}) {
    try {
      if (_sharedPreferences == null) {
        return false;
      }
      return _sharedPreferences!.remove(key);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveData(
      {required String key, required dynamic value}) async {
    try {
      if (_sharedPreferences == null) {
        await init();
      }
      if (value is int) return await _sharedPreferences!.setInt(key, value);
      if (value is double) return await _sharedPreferences!.setDouble(key, value);
      if (value is bool) return await _sharedPreferences!.setBool(key, value);
      if (value is List<String>) {
        return await _sharedPreferences!.setStringList(key, value);
      }
      return await _sharedPreferences!.setString(key, value);
    } catch (e) {
      return false;
    }
  }

  static String lang = 'LANGUAGEAPP';
  static String userData = 'USER_DATA';
  static String clearUserData = 'CLEAR_USER_DATA';
  static String showTour = 'SHOW_TOUR';
  static String accessToken = 'ACCESS_TOKEN';
  static String refreshToken = 'REFRESH_TOKEN';
  static String tokenType = 'TOKEN_TYPE';
  static String expiresIn = 'EXPIRES_IN';
  static String tokenExpiresAt = 'TOKEN_EXPIRES_AT';
  static String isLoggedOut = 'IS_LOGGED_OUT'; // Track if user manually logged out
  static String lastLoginType = 'LAST_LOGIN_TYPE'; // Track last login type: 'Business Services' or 'My Services'
  
}
