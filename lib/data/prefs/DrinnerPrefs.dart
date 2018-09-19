import 'dart:async';

import 'package:drinner_flutter/model/User.dart';

abstract class DrinnerPrefs {
  Future<User> getUser();
}
