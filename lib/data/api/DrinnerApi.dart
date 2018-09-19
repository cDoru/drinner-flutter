import 'package:drinner_flutter/model/City.dart';
import 'package:drinner_flutter/model/Venue.dart';

abstract class DrinnerApi {
  List<City> getCities();
  List<Venue> getCityVenues(String city);
}
