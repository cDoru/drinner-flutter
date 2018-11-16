import 'dart:typed_data';

import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:http/http.dart' as http;

class DrinnerApiImpl extends DrinnerApi {
  DrinnerApiImpl(this._baseUrl);

  String _baseUrl;
  String get _avatarsUrl => _baseUrl + 'avatars/';
  String get _randomAvatarUrl => _avatarsUrl + 'random/';

  @override
  Future<List<City>> getCities() {
    return Future.value(List());
  }

  @override
  Future<List<Venue>> getCityVenues(String city) {
    return Future.value(List());
  }

  @override
  Future<int> getRandomAvatarId() =>
      http.get(_randomAvatarUrl).then((it) => int.tryParse(it.body));

  @override
  Future<Uint8List> getAvatar(int id) =>
      http.get(_avatarsUrl + '$id').then((it) => it.bodyBytes);
}
