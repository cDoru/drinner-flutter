import 'package:drinner_flutter/model/GeoPoint.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class BBox {
  BBox({
    @required this.N,
    @required this.S,
    @required this.E,
    @required this.W,
  });

  BBox fromPoints(GeoPoint p1, GeoPoint p2) => BBox(
        N: max(p1.lat, p2.lat),
        S: min(p1.lat, p2.lat),
        E: max(p1.lon, p2.lon),
        W: min(p1.lon, p2.lon),
      );

  final double N;
  final double S;
  final double E;
  final double W;
}
