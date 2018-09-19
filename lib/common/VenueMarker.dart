import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:math';

class VenueMarker {
  static const _MIN_ZOOM = 1.0;
  static const _MAX_ZOOM = 20.0;
  static const _MIN_SIZE = 4.0;
  static const _MAX_SIZE = 64.0;
  static const _SIZE_DIVIDER =
      (_MAX_ZOOM * _MAX_ZOOM * _MAX_ZOOM - _MIN_ZOOM * _MIN_ZOOM * _MIN_ZOOM) /
          (_MAX_SIZE - _MIN_SIZE);
  static const _BASE_SIZE =
      _MIN_SIZE - _MIN_ZOOM * _MIN_ZOOM * _MIN_ZOOM / _SIZE_DIVIDER;

  static Marker create(Venue venue, double zoom) {
    final size = (_BASE_SIZE + pow(zoom, 3) / _SIZE_DIVIDER).roundToDouble();
    return Marker(
      width: size,
      height: size,
      point: LatLng(venue.location.lat, venue.location.lon),
      builder: (_) => FlutterLogo(),
    );
  }
}
