import 'dart:async';

import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

abstract class DrinnerPrefs {
  Observable<User> getUser();
  Future<bool> saveUser(User user);
}
