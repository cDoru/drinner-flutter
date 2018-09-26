import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/BBox.dart';
import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';
import 'package:drinner_flutter/model/Cuisine.dart';

class FakeApiImpl extends DrinnerApi {
  @override
  List<City> getCities() => _cities;

  @override
  List<Venue> getCityVenues(String city) => _venues;

  final List<City> _cities = [
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

  final List<Venue> _venues = [
    Venue("The Root", GeoPoint(lat: 51.1083784, lon: 17.0268721), []),
    Venue("Convivio", GeoPoint(lat: 51.1100508, lon: 17.0391776), []),
    Venue("Pod Papugami", GeoPoint(lat: 51.1101758, lon: 17.0313678), []),
    Venue("Masala Grill", GeoPoint(lat: 51.110848, lon: 17.0338452), []),
    Venue("Chatka przy Jatkach", GeoPoint(lat: 51.1119831, lon: 17.0314141),
        [Cuisine.REGIONAL, Cuisine.POLISH]),
    Venue("Sushi Darea", GeoPoint(lat: 51.1129193, lon: 17.0344004),
        [Cuisine.JAPANESE, Cuisine.KOREAN, Cuisine.SUSHI]),
    Venue("Trattoria Pesto", GeoPoint(lat: 51.1115553, lon: 17.0334811),
        [Cuisine.ITALIAN]),
    Venue("Pattie's", GeoPoint(lat: 51.1114546, lon: 17.0334811),
        [Cuisine.PANCAKES]),
    Venue("Kurna Chata", GeoPoint(lat: 51.1130591, lon: 17.0317662),
        [Cuisine.POLISH]),
    Venue("Osiem Misek", GeoPoint(lat: 51.1095493, lon: 17.0232535),
        [Cuisine.ASIAN]),
  ];
}
