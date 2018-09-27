import 'dart:math';

import 'package:drinner_flutter/common/marker/MarkerBubblePainter.dart';
import 'package:drinner_flutter/model/Cuisine.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart' show LatLng;

class VenueMarker {
  VenueMarker._(this._venue, this._zoom) {
    _size = _calcMarkerSize();
  }

  static Marker create(Venue venue, double zoom) =>
      VenueMarker._(venue, zoom).marker;

  Venue _venue;
  double _zoom;
  double _size;

  final _minZoom = 1.0;
  final _maxZoom = 20.0;
  final _minSize = 4.0;
  final _maxSize = 96.0;
  final _imageHeightRatio = 0.75;
  final _imagePaddingRatio = 0.1;

  double get _imageHeight => _size * _imageHeightRatio;
  double get _imagePadding => _size * _imagePaddingRatio;
  Cuisine get _cuisine =>
      _venue.cuisines.isNotEmpty ? _venue.cuisines.first : Cuisine.UNKNOWN;

  Marker get marker {
    return Marker(
      width: _size,
      height: _size,
      anchor: AnchorPos.top,
      point: LatLng(_venue.location.lat, _venue.location.lon),
      builder: (_) => Stack(children: [
            CustomPaint(
              painter: VenueMarkerBubblePainter(
                footHeightRatio: 1 - _imageHeightRatio,
                color: _cuisine.color,
              ),
              size: Size(_size, _size),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: EdgeInsets.all(_imagePadding),
                child: Image.asset(
                  'images/food/${_cuisine.image}.png',
                  color: Colors.white,
                  height: _imageHeight - 2 * _imagePadding,
                  colorBlendMode: BlendMode.srcATop,
                ),
              ),
            ),
          ]),
    );
  }

  double _calcMarkerSize() {
    final exponent = 4.0;
    final baseSize = _minSize - pow(_minZoom, exponent);
    final sizeFactor = (_maxSize - _minSize) /
        (pow(_maxZoom, exponent) - pow(_minZoom, exponent));
    return (baseSize + pow(_zoom, exponent)) * sizeFactor;
  }
}
