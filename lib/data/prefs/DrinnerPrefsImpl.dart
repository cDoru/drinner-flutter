import 'dart:async';

import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrinnerPrefsImpl extends DrinnerPrefs {
  static const USER_NAME_KEY = 'userName';
  static const USER_CITY_KEY = 'userCity';
  static const USER_IMAGE_URL_KEY = 'userImageUrl';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<User> getUser() async => _prefs.then((it) => User(
        it.getString(USER_NAME_KEY),
        it.getString(USER_CITY_KEY),
        it.getString(USER_IMAGE_URL_KEY),
      ));
}