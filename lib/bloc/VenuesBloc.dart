import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:rxdart/rxdart.dart';

class VenuesBloc extends BaseBloc {
  VenuesBloc(this._drinnerPrefs, this._drinnerApi) {
    venues =
        _userSubject.map((it) => it.city).asyncMap(_drinnerApi.getCityVenues);
    _drinnerPrefs.getUser().listen(_userSubject.add);
  }

  final DrinnerPrefs _drinnerPrefs;
  final DrinnerApi _drinnerApi;

  Subject<User> _userSubject = PublishSubject();
  Observable<List<Venue>> venues;

  @override
  void dispose() {
    _userSubject.close();
  }
}
