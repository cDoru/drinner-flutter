import 'package:drinner_flutter/bloc/AppBloc.dart';
import 'package:drinner_flutter/bloc/MainBloc.dart';
import 'package:drinner_flutter/bloc/MapBloc.dart';
import 'package:drinner_flutter/bloc/MeetingDetailsBloc.dart';
import 'package:drinner_flutter/bloc/MeetingsBloc.dart';
import 'package:drinner_flutter/bloc/SettingsBloc.dart';
import 'package:drinner_flutter/bloc/VenuesBloc.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/data/api/FakeApiImpl.dart';
import 'package:drinner_flutter/data/prefs/DrinnerPrefs.dart';
import 'package:drinner_flutter/data/prefs/FakePrefsImpl.dart';
import 'package:drinner_flutter/service/Locator.dart';

class BlocFactory {
  static DrinnerApi _drinnerApi = FakeApiImpl();
  static DrinnerPrefs _drinnerPrefs = FakePrefsImpl();
  static Locator _locator = FakeLocatorImpl();

  static AppBloc get appBloc => AppBloc();
  static MainBloc get mainBloc => MainBloc();
  static VenuesBloc get venuesBloc => VenuesBloc(_drinnerPrefs, _drinnerApi);
  static MapBloc get mapBloc => MapBloc();
  static SettingsBloc get settingsBloc =>
      SettingsBloc(_drinnerPrefs, _drinnerApi, _locator);
  static MeetingsBloc get meetingsBloc => MeetingsBloc(_drinnerApi);
  static MeetingDetailsBloc get meetingDetailsBloc =>
      MeetingDetailsBloc(_drinnerApi);
}
