import 'dart:async';

import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';

class FakePrefsImpl extends DrinnerPrefs {
  @override
  Future<User> getUser() async => User(
        'test user',
        'https://upload.wikimedia.org/wikipedia/commons/6/67/User_Avatar.png',
        'Wrocław',
      );
}
