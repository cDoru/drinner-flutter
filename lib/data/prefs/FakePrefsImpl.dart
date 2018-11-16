import 'dart:async';

import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

class FakePrefsImpl extends DrinnerPrefs {
  FakePrefsImpl() {
    _emitUser();
  }

  User _user = User(
    name: 'test user',
    avatarId: 1,
    city: 'Wrocław',
  );

  final Subject<User> _userSubject = BehaviorSubject();

  @override
  Observable<User> getUser() => _userSubject;

  @override
  Future<bool> saveUser(User user) async {
    _user = user;
    _emitUser();
    return true;
  }

  void _emitUser() => _userSubject.add(_user);
}
