import 'package:drinner_flutter/model/BBox.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';

class City {
  City(this.name, this.bbox);

  final String name;
  final BBox bbox;
  GeoPoint get center => GeoPoint(
        lat: (bbox.N + bbox.S) / 2,
        lon: (bbox.W + bbox.E) / 2,
      );
}
