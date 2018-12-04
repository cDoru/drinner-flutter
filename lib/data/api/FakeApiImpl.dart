import 'dart:math';
import 'dart:typed_data';

import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/BBox.dart';
import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';
import 'package:drinner_flutter/model/Cuisine.dart';
import 'package:flutter/services.dart';

class FakeApiImpl extends DrinnerApi {
  @override
  Future<List<City>> getCities() =>
      Future.delayed(Duration(milliseconds: 500), () => _cities);

  @override
  Future<List<Venue>> getCityVenues(String city) =>
      Future.delayed(Duration(milliseconds: 200), () => _venues);

  @override
  Future<int> getRandomAvatarId() =>
      Future.delayed(Duration(milliseconds: 300), () => Random().nextInt(10));

  @override
  Future<Uint8List> getAvatar(int id) => Future.delayed(
        Duration(milliseconds: Random().nextInt(2000) - 1000),
        () => rootBundle
            .load('images/avatars/$id.png')
            .then((it) => Uint8List.view(it.buffer)),
      );

  @override
  Future<List<Meeting>> getMeetings() =>
      Future.delayed(Duration(milliseconds: 600), () => _meetings);

  static T _randomItem<T>(List<T> list) => list[Random().nextInt(list.length)];
  static List<T> _randomSubList<T>(List<T> list) =>
      list.toList()..removeWhere((_) => Random().nextBool());

  static City get _randomCity => _randomItem(_cities);
  static final List<City> _cities = [
    City("Wrocław",
        BBox(W: 16.844444, S: 51.018506, E: 17.169914, N: 51.171164)),
    City(
        "Kraków", BBox(W: 19.851265, S: 49.994057, E: 20.055885, N: 50.110891)),
    City(
        "Poznań", BBox(W: 16.758614, S: 52.353796, E: 17.046661, N: 52.502012)),
    City("Łódź", BBox(W: 19.346924, S: 51.694054, E: 19.593773, N: 51.834292)),
    City("Trójmiasto",
        BBox(W: 18.545952, S: 54.320929, E: 18.767052, N: 54.429117)),
    City("Warszawa",
        BBox(W: 20.863724, S: 52.140231, E: 21.187134, N: 52.328206)),
  ];

  static Venue get _randomVenue => _randomItem(_venues);
  static final List<Venue> _venues = [
    Venue("The Root", "Krupnicza 3", GeoPoint(lat: 51.1083784, lon: 17.0268721),
        []),
    Venue("Convivio", "Purkyniego 1",
        GeoPoint(lat: 51.1100508, lon: 17.0391776), []),
    Venue("Pod Papugami", "Sukiennice 9a",
        GeoPoint(lat: 51.1101758, lon: 17.0313678), []),
    Venue("Masala Grill", "Kuźnicza 3",
        GeoPoint(lat: 51.110848, lon: 17.0338452), []),
    Venue(
        "Chatka przy Jatkach",
        "Odrzańska 7",
        GeoPoint(lat: 51.1119831, lon: 17.0314141),
        [Cuisine.REGIONAL, Cuisine.POLISH]),
    Venue(
        "Sushi Darea",
        "Kuźnicza 43/45",
        GeoPoint(lat: 51.1129193, lon: 17.0344004),
        [Cuisine.JAPANESE, Cuisine.KOREAN, Cuisine.SUSHI]),
    Venue("Trattoria Pesto", "Kotlarska 40",
        GeoPoint(lat: 51.1115553, lon: 17.0334811), [Cuisine.ITALIAN]),
    Venue("Pattie's", "Igielna 16", GeoPoint(lat: 51.1114546, lon: 17.0334811),
        [Cuisine.PANCAKES]),
    Venue("Kurna Chata", "Odrzańska 17",
        GeoPoint(lat: 51.1130591, lon: 17.0317662), [Cuisine.POLISH]),
    Venue("Osiem Misek", "Włodkowica 27",
        GeoPoint(lat: 51.1095493, lon: 17.0232535), [Cuisine.ASIAN]),
  ];

  static const EPOCH_FACTOR = 10000000000;
  static const EPOCH_START = 152 * EPOCH_FACTOR;
  static const EPOCH_END = 154 * EPOCH_FACTOR;
  static int get _randomEpoch =>
      (EPOCH_START + Random().nextDouble() * (EPOCH_END - EPOCH_START)).toInt();
  static DateTime get _randomDateTime =>
      DateTime.fromMillisecondsSinceEpoch(_randomEpoch);

  static final List<Meeting> _meetings = [
    Meeting(
        name: 'Paulable',
        dateTime: _randomDateTime,
        venue: _randomVenue,
        members: _randomPersons),
    Meeting(
        name: 'Confessions of a Blogging Freak',
        dateTime: _randomDateTime,
        venue: _randomVenue,
        members: _randomPersons),
    Meeting(
        name: 'Smart Arrogant Blog',
        dateTime: _randomDateTime,
        venue: _randomVenue,
        members: _randomPersons),
    Meeting(
        name: 'The P Word',
        dateTime: _randomDateTime,
        venue: _randomVenue,
        members: _randomPersons),
    Meeting(
        name: 'Sewing Overload',
        dateTime: _randomDateTime,
        venue: _randomVenue,
        members: _randomPersons),
  ];

  static List<User> get _randomPersons => _randomSubList(_persons);
  static final List<User> _persons = [
    User(name: 'Bessie Romero', city: _randomCity.name, avatarId: 0),
    User(name: 'Frederick Harvey', city: _randomCity.name, avatarId: 1),
    User(name: 'Jessica George', city: _randomCity.name, avatarId: 2),
    User(name: 'Miriam Franklin', city: _randomCity.name, avatarId: 3),
    User(name: 'Cory Matthews', city: _randomCity.name, avatarId: 4),
    User(name: 'Brent Fisher', city: _randomCity.name, avatarId: 5),
    User(name: 'Brett Holt', city: _randomCity.name, avatarId: 6),
    User(name: 'Claire Chapman', city: _randomCity.name, avatarId: 7),
    User(name: 'Norman Mason', city: _randomCity.name, avatarId: 8),
    User(name: 'Shawn Chambers', city: _randomCity.name, avatarId: 9),
  ];
}
