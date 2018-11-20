import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/Pair.dart';
import 'package:drinner_flutter/common/rx/VoidSubject.dart';
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
  VoidSubject editNameInput = VoidSubject.publish();
  VoidSubject editCityInput = VoidSubject.publish();
  Subject<String> updateNameInput = PublishSubject();
  Subject<String> updateCityInput = PublishSubject();
  Subject<SettingsAvatar> _currentRandomAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentUserAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentAvatar = BehaviorSubject();

  StreamSubscription _currentRandomAvatarSub;
  StreamSubscription _currentUserAvatarSub;
  StreamSubscription _currentAvatarSub;

  Observable<String> get editNameValue =>
      editNameInput.withLatestFrom(_user, (_, User user) => user.name);
  Observable<String> get editCityValue =>
      editCityInput.withLatestFrom(_user, (_, User user) => user.city);
  Observable<User> get _user => _drinnerPrefs.getUser();

  @override
  void dispose() {
    updateNameInput.close();
    updateCityInput.close();
    changeAvatarInput.close();
    acceptAvatarInput.close();
    rejectAvatarInput.close();
    editNameInput.close();
    editCityInput.close();
    _currentRandomAvatar.close();
    _currentUserAvatar.close();
    _currentAvatar.close();
    _currentAvatarSub.cancel();
    _currentUserAvatarSub.cancel();
    _currentRandomAvatarSub.cancel();
  }

  void _initAvatarStreams() {
    _initRandomAndUserAvatarStream();
    _initCurrentAvatarStream();
  }

  void _initRandomAndUserAvatarStream() {
    _currentRandomAvatarSub = changeAvatarInput
        .flatMap(_getNextAvatarId)
        .flatMap((it) => _getSettingsAvatar(it, true))
        .listen(_currentRandomAvatar.add);
    _currentUserAvatarSub = _user
        .map((it) => it.avatarId)
        .distinct()
        .flatMap((it) => _getSettingsAvatar(it, false))
        .listen(_currentUserAvatar.add);
  }

  Observable<int> _getNextAvatarId() {
    final latestAvatarsSource = () => Observable.combineLatest2(
          _currentAvatar,
          _currentUserAvatar,
          (a1, a2) => Twin<SettingsAvatar>(a1, a2),
        );
    final nextIdSource = () =>
        Observable.fromFuture(_drinnerApi.getRandomAvatarId())
            .withLatestFrom(latestAvatarsSource(), _retainIdIfChanged)
            .map((it) => it != null ? it : throw Exception());
    return Observable.retry(nextIdSource);
  }

  int _retainIdIfChanged(int id, Twin<SettingsAvatar> avatars) {
    final changed = id != avatars.first.id && id != avatars.second.id;
    return changed ? id : null;
  }

  Observable<SettingsAvatar> _getSettingsAvatar(int id, bool isRandom) {
    return Observable.fromFuture(_drinnerApi.getAvatar(id))
        .map((it) => SettingsAvatar(id, it, isRandom));
  }

  void _initCurrentAvatarStream() {
    final _rejectRandomAvatar = rejectAvatarInput.withLatestFrom(
        _currentUserAvatar, (_, SettingsAvatar avatar) => avatar);
    _currentAvatarSub = Observable.merge([
      _currentRandomAvatar,
      _currentUserAvatar,
      _rejectRandomAvatar,
    ]).listen(_currentAvatar.add);
  }

  void _initViewObservables() {
    _initUserAvatarObservable();
    _initNameAndCityObservables();
    _initUserSaveResultObservable();
  }

  void _initUserAvatarObservable() {
    final _avatarInput = VoidObservable.merge([
      changeAvatarInput,
      acceptAvatarInput,
      rejectAvatarInput,
    ]);
    userAvatar = Observable.merge([
      _avatarInput.map(() => LoadingState()),
      _currentAvatar.map(DataState.create),
    ]);
  }

  void _initNameAndCityObservables() {
    userName = Observable.merge([
      updateNameInput.map((_) => LoadingState()),
      _user.map((it) => it.name).distinct().map(DataState.create),
    ]);
    userCity = Observable.merge([
      updateCityInput.map((_) => LoadingState()),
      _user.map((it) => it.city).distinct().map(DataState.create),
    ]);
  }

  void _initUserSaveResultObservable() {
    final _acceptRandomAvatar = acceptAvatarInput.withLatestFrom(
        _currentRandomAvatar, (_, SettingsAvatar avatar) => avatar);
    final pendingUser = Observable.merge([
      updateNameInput.map((it) => User(name: it)),
      updateCityInput.map((it) => User(city: it)),
      _acceptRandomAvatar.map((it) => User(avatarId: it.id)),
    ]);
    userSaveResult = pendingUser
        .withLatestFrom(_user, _copyLatestUser)
        .asyncMap(_drinnerPrefs.saveUser);
  }

  User _copyLatestUser(User pending, User latest) {
    return latest.copy(
      name: pending.name,
      city: pending.city,
      avatarId: pending.avatarId,
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
