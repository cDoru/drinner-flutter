import 'dart:async';

import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

class FakePrefsImpl extends DrinnerPrefs {
  static User _user = User(
    name: 'test user',
    avatarId: 0,
    city: 'Wrocław',
  );

  final Subject<User> _userSubject = BehaviorSubject(seedValue: _user);

  @override
  void dispose() {
    _userSubject.close();
  }

  @override
  Observable<User> getUser() => _userSubject.delay(Duration(milliseconds: 500));

  @override
  Future<bool> saveUser(User user) async {
    await Future.delayed(Duration(seconds: 3));
    _user = user;
    _emitUser();
    return true;
  }

  void _emitUser() => _userSubject.add(_user);
}
