import 'dart:async';

import 'package:drinner_flutter/common/rx/Disposable.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

abstract class DrinnerPrefs with Disposable {
  Observable<User> getUser();
  Future<bool> saveUser(User user);
}
