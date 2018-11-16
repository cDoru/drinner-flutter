import 'dart:async';

import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrinnerPrefsImpl extends DrinnerPrefs {
  DrinnerPrefsImpl() {
    _initUser();
  }

  static const USER_NAME_KEY = 'userName';
  static const USER_CITY_KEY = 'userCity';
  static const USER_AVATAR_ID = 'userAvatarId';

  final Subject<User> _userSubject = BehaviorSubject();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  void _initUser() {
    _prefs
        .then((it) => User(
              name: it.getString(USER_NAME_KEY),
              city: it.getString(USER_CITY_KEY),
              avatarId: it.getInt(USER_AVATAR_ID),
            ))
        .then(_userSubject.add);
  }

  @override
  Observable<User> getUser() => _userSubject;

  @override
  Future<bool> saveUser(User user) async => _prefs
      .then((it) => it
        ..setString(USER_NAME_KEY, user.name)
        ..setString(USER_CITY_KEY, user.city)
        ..setInt(USER_AVATAR_ID, user.avatarId))
      .then((_) => true);
}
