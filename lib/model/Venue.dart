import 'package:drinner_flutter/model/Cuisine.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';

class Venue {
  Venue(this.name, this.address, this.location, this.cuisines);

  String name;
  String address;
  GeoPoint location;
  List<Cuisine> cuisines;
}
