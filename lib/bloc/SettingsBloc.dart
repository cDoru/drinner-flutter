import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/Pair.dart';
import 'package:drinner_flutter/common/rx/VoidSubject.dart';
import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:drinner_flutter/service/Locator.dart';
import 'package:rxdart/rxdart.dart';

class SettingsBloc extends BaseBloc {
  SettingsBloc(this._drinnerPrefs, this._drinnerApi, this._locator) {
    _initAvatarStreams();
    _initViewObservables();
  }

  final DrinnerPrefs _drinnerPrefs;
  final DrinnerApi _drinnerApi;
  final Locator _locator;

  Observable<bool> userSaveResult;
  Observable<ViewState<String>> userName;
  Observable<ViewState<String>> userCity;
  Observable<ViewState<SettingsAvatar>> userAvatar;
  Observable<Observable<ViewState<ViewEditCityData>>> editCityData;
  Observable<City> nearestCity;

  VoidSubject changeAvatarInput = VoidSubject.publish();
  VoidSubject acceptAvatarInput = VoidSubject.publish();
  VoidSubject rejectAvatarInput = VoidSubject.publish();
  VoidSubject editNameInput = VoidSubject.publish();
  VoidSubject editCityInput = VoidSubject.publish();
  VoidSubject locateCityInput = VoidSubject.publish();
  Subject<String> updateNameInput = PublishSubject();
  Subject<String> updateCityInput = PublishSubject();
  Subject<String> editCityQueryInput = BehaviorSubject(seedValue: '');
  Subject<SettingsAvatar> _currentRandomAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentUserAvatar = BehaviorSubject();
  Subject<SettingsAvatar> _currentAvatar = BehaviorSubject();

  StreamSubscription _currentRandomAvatarSub;
  StreamSubscription _currentUserAvatarSub;
  StreamSubscription _currentAvatarSub;

  Observable<String> get _distinctCityInput =>
      updateCityInput.flatMap(_filterCityChanged);
  Observable<User> get _user => _drinnerPrefs.getUser();
  Observable<String> get editNameValue =>
      editNameInput.mapLatestFrom(_user).map((it) => it.name);

  @override
  void dispose() {
    updateNameInput.close();
    updateCityInput.close();
    changeAvatarInput.close();
    acceptAvatarInput.close();
    rejectAvatarInput.close();
    editNameInput.close();
    editCityQueryInput.close();
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
    final _rejectRandomAvatar =
        rejectAvatarInput.mapLatestFrom(_currentUserAvatar);
    _currentAvatarSub = Observable.merge([
      _currentRandomAvatar,
      _currentUserAvatar,
      _rejectRandomAvatar,
    ]).listen(_currentAvatar.add);
  }

  void _initViewObservables() {
    _initUserAvatarObservable();
    _initNameAndCityObservables();
    _initEditObservables();
    _initUserSaveResultObservables();
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
      _distinctCityInput.map((_) => LoadingState()),
      Observable.merge([
        Observable.just(LoadingState()),
        _user.map((it) => it.city).distinct().map(DataState.create),
      ]),
    ]);
  }

  void _initEditObservables() {
    nearestCity = locateCityInput
        .flatMap(_zipCitiesAndPosition)
        .flatMap((it) => _calcCitiesDists(it.first, it.second))
        .doOnData((it) => it.sort((p1, p2) => p1.second.compareTo(p2.second)))
        .map((it) => it.first.first)
        .asBroadcastStream();
    editCityData = editCityInput.map(() => Observable.merge([
          Observable.just(LoadingState()),
          getCityDialogData().map(DataState.create),
        ]));
  }

  Observable<ViewEditCityData> getCityDialogData() {
    final isLocalizingCity = Observable.merge([
      locateCityInput.map(() => true),
      nearestCity.map((_) => false),
    ]).startWith(false);
    return Observable.combineLatest3(
      _user.flatMap(_loadEditCityData),
      editCityQueryInput,
      isLocalizingCity,
      _filterCitiesByQuery,
    );
  }

  ViewEditCityData _filterCitiesByQuery(
      ViewEditCityData data, String query, bool isLocalizing) {
    final regex = RegExp(query, caseSensitive: false);
    final filtered = data.all.where((it) => regex.hasMatch(it.name)).toList();
    return data.copy(isLocalizing: isLocalizing, all: filtered);
  }

  Observable<Pair<List<City>, GeoPoint>> _zipCitiesAndPosition() =>
      Observable.zip2(
        Observable.fromFuture(_drinnerApi.getCities()),
        Observable.fromFuture(_locator.getCurrentPosition()),
        Pair.create,
      );

  Observable<List<Pair<City, double>>> _calcCitiesDists(
      List<City> cities, GeoPoint position) {
    final citiesDists = cities.map((it) async {
      final dist = await _locator.getDistance(it.center, position);
      return Pair(it, dist);
    });
    return Observable.fromFuture(Future.wait(citiesDists));
  }

  void _initUserSaveResultObservables() {
    final _acceptRandomAvatar =
        acceptAvatarInput.mapLatestFrom(_currentRandomAvatar);
    final pendingUser = Observable.merge([
      updateNameInput.map((it) => User(name: it)),
      _distinctCityInput.map((it) => User(city: it)),
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

  Observable<ViewEditCityData> _loadEditCityData(User user) {
    return Observable.fromFuture(_drinnerApi.getCities()).map((cities) {
      final current = cities.firstWhere((it) => it.name == user.city);
      return ViewEditCityData(false, current, cities);
    });
  }

  Observable<String> _filterCityChanged(String city) {
    return Observable.just(city)
        .distinct()
        .flatMap((it) => Observable.zip2(Observable.just(it), _user,
            (String city, User user) => city != user.city ? city : null))
        .where((it) => it != null);
  }
}

class ViewEditCityData {
  ViewEditCityData(this.isLocalizing, this.current, this.all);
  final bool isLocalizing;
  final City current;
  final List<City> all;

  ViewEditCityData copy({bool isLocalizing, City current, List<City> all}) =>
      ViewEditCityData(
        isLocalizing ?? this.isLocalizing,
        current ?? this.current,
        all ?? this.all,
      );
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
