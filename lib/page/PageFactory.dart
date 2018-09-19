import 'package:drinner_flutter/app/AppConfig.dart';
import 'package:drinner_flutter/page/HomePage.dart';
import 'package:drinner_flutter/page/MainPage.dart';
import 'package:drinner_flutter/page/MeetingsPage.dart';
import 'package:drinner_flutter/page/SettingsPage.dart';
import 'package:drinner_flutter/page/VenuesPage.dart';

class PageFactory {
  static MainPage get mainPage => MainPage();
  static MeetingsPage get meetingsPage => MeetingsPage();
  static HomePage get homePage => HomePage();
  static SettingsPage get settingsPage => SettingsPage();
  static VenuesPage get venuesPage =>
      VenuesPage(AppConfig.MAPBOX_URL, AppConfig.MAPBOX_TOKEN);
}
