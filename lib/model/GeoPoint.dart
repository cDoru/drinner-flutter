import 'package:flutter/foundation.dart';
import 'dart:math';

class GeoPoint {
  GeoPoint({@required this.lat, @required this.lon});

  static const RAD_DEG_RATIO = pi / 180;

  final double lat;
  final double lon;

  double get radLat => lat * RAD_DEG_RATIO;
  double get radLon => lon * RAD_DEG_RATIO;
}
