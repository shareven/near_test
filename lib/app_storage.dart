import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String ACCOUNT_KEY = "ACCOUNT_KEY";

class AppStorage {
  static Future<Map?> getAccount() async {
    String? data = await getKV(ACCOUNT_KEY);
    if (data != null) {
      try {
        Map account = jsonDecode(data);
        return account;
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  static Future<void> setAccount(Map? account) async {
    String? data;
    if (account != null) {
      try {
        data = jsonEncode(account);
      } catch (e) {
        print(e);
      }
    }
    await setKV(ACCOUNT_KEY, data);
  }

  static Future<String?> getKV(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setKV(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      prefs.remove(key);
    } else {
      prefs.setString(key, value);
    }
  }
}
