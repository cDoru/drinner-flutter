import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/VoidSubject.dart';
import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

class SettingsBloc extends BaseBloc {
  SettingsBloc(this._drinnerPrefs, this._drinnerApi) {
    _initAvatarStreams();
    _initViewObservables();
  }

  final DrinnerPrefs _drinnerPrefs;
  final DrinnerApi _drinnerApi;

  Observable<bool> userSaveResult;
  Observable<ViewState<String>> userName;
  Observable<ViewState<String>> userCity;
  Observable<ViewState<SettingsAvatar>> userAvatar;

  VoidSubject changeAvatarInput = VoidSubject.publish();
  VoidSubject acceptAvatarInput = VoidSubject.publish();
  VoidSubject rejectAvatarInput = VoidSubject.publish();
  Subject<String> updateNameInput = PublishSubject();
  Subject<String> updateCityInput = PublishSubject();

  Subject<SettingsAvatar> _currentRandomAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentUserAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentAvatar = BehaviorSubject();

  StreamSubscription _currentRandomAvatarSub;
  StreamSubscription _currentUserAvatarSub;
  StreamSubscription _currentAvatarSub;

  Observable<User> get _user => _drinnerPrefs.getUser();
  Future<User> get latestUser => _user.take(1).last;

  @override
  void dispose() {
    updateNameInput.close();
    updateCityInput.close();
    changeAvatarInput.close();
    acceptAvatarInput.close();
    rejectAvatarInput.close();
    _currentRandomAvatar.close();
    _currentUserAvatar.close();
    _currentAvatar.close();
    _currentAvatarSub.cancel();
    _currentUserAvatarSub.cancel();
    _currentRandomAvatarSub.cancel();
  }

  void _initAvatarStreams() {
    _currentRandomAvatarSub = changeAvatarInput
        .asyncMap(_getNextAvatarId)
        .asyncMap((it) => _getSettingsAvatar(it, true))
        .listen(_currentRandomAvatar.add);
    _currentUserAvatarSub = _user
        .distinct((u1, u2) => u1.avatarId == u2.avatarId)
        .asyncMap((it) => _getSettingsAvatar(it.avatarId, false))
        .listen(_currentUserAvatar.add);

    final _rejectRandomAvatar = rejectAvatarInput.withLatestFrom(
        _currentUserAvatar, (_, SettingsAvatar avatar) => avatar);
    _currentAvatarSub = Observable.merge([
      _currentRandomAvatar,
      _currentUserAvatar,
      _rejectRandomAvatar,
    ]).listen(_currentAvatar.add);
  }

  void _initViewObservables() {
    final _avatarInput = VoidObservable.merge([
      changeAvatarInput,
      acceptAvatarInput,
      rejectAvatarInput,
    ]);
    userAvatar = Observable.merge([
      _avatarInput.map(() => LoadingState()),
      _currentAvatar.map(DataState.create),
    ]);

    userName = Observable.merge([
      updateNameInput.map((_) => LoadingState()),
      _user.map((it) => it.name).distinct().map(DataState.create),
    ]);
    userCity = Observable.merge([
      updateCityInput.map((_) => LoadingState()),
      _user.map((it) => it.city).distinct().map(DataState.create),
    ]);

    final _acceptRandomAvatar = acceptAvatarInput.withLatestFrom(
        _currentRandomAvatar, (_, SettingsAvatar avatar) => avatar);
    userSaveResult = Observable.merge([
      updateNameInput.map((it) => _copyLatestUser(name: it)),
      updateCityInput.map((it) => _copyLatestUser(city: it)),
      _acceptRandomAvatar.map((it) => _copyLatestUser(avatarId: it.id)),
    ]).asyncMap((it) => it.then(_drinnerPrefs.saveUser));
  }

  Future<int> _getNextAvatarId() async {
    final current = await _currentAvatar.take(1).last;
    final user = await _currentUserAvatar.take(1).last;
    while (true) {
      final nextId = await _drinnerApi.getRandomAvatarId();
      if (nextId != user.id && nextId != current.id) {
        return nextId;
      }
    }
  }

  Future<SettingsAvatar> _getSettingsAvatar(int id, bool isRandom) async {
    final image = await _drinnerApi.getAvatar(id);
    return SettingsAvatar(id, image, isRandom);
  }

  Future<User> _copyLatestUser({String name, String city, int avatarId}) {
    return latestUser.then(
      (it) => it.copy(name: name, city: city, avatarId: avatarId),
    );
  }
}

class ViewUser {
  ViewUser(this.name, this.city, this.avatar);

  final ViewState<String> name;
  final ViewState<String> city;
  final SettingsAvatar avatar;

  ViewUser copy({
    Future<String> name,
    Future<String> city,
    Future<Uint8List> avatar,
  }) =>
      ViewUser(name ?? this.name, city ?? this.city, avatar ?? this.avatar);
}

class SettingsAvatar {
  SettingsAvatar(this.id, this.image, this.isRandom);
  final int id;
  final Uint8List image;
  final bool isRandom;
}
