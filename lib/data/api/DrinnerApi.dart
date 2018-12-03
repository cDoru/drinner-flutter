import 'dart:typed_data';

import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:drinner_flutter/model/Venue.dart';

abstract class DrinnerApi {
  Future<List<City>> getCities();
  Future<List<Venue>> getCityVenues(String city);
  Future<int> getRandomAvatarId();
  Future<Uint8List> getAvatar(int id);
  Future<List<Meeting>> getMeetings();
}
