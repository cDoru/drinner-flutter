import 'package:drinner_flutter/model/BBox.dart';
import 'package:drinner_flutter/model/GeoPoint.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

abstract class Locator {
  Future<GeoPoint> getCurrentPosition();
  Future<double> getDistance(GeoPoint p1, GeoPoint p2);
}

class FakeLocatorImpl extends Locator {
  final BBox _bbox = BBox(
      N: 54.8515359564, E: 24.0299857927, S: 49.0273953314, W: 14.0745211117);

  @override
  Future<GeoPoint> getCurrentPosition() =>
      Future.delayed(Duration(milliseconds: 2000), () => _bbox.randomPoint);

  @override
  Future<double> getDistance(GeoPoint p1, GeoPoint p2) {
    final radDist = acos(sin(p1.radLat) * sin(p2.radLat) +
        cos(p1.radLat) * cos(p2.radLat) * cos(p2.radLon - p1.radLon));
    final kmDist = radDist * 111.195 / GeoPoint.RAD_DEG_RATIO;
    return Future.value(kmDist);
  }
}

class LocatorImpl extends Locator {
  final _geolocator = Geolocator();

  @override
  Future<double> getDistance(GeoPoint p1, GeoPoint p2) =>
      _geolocator.distanceBetween(p1.lat, p1.lon, p2.lat, p2.lon);

  @override
  Future<GeoPoint> getCurrentPosition() => _geolocator
      .getCurrentPosition()
      .then((it) => GeoPoint(lat: it.latitude, lon: it.longitude));
}
