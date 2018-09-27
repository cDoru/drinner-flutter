import 'dart:math';

import 'package:drinner_flutter/common/marker/MarkerBubblePainter.dart';
import 'package:drinner_flutter/model/Cuisine.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart' show LatLng;

class VenueMarker extends Marker {
  VenueMarker._(this.venue, double size, WidgetBuilder builder)
      : super(
          width: size,
          height: size,
          anchor: AnchorPos.top,
          point: LatLng(venue.location.lat, venue.location.lon),
          builder: builder,
        );

  factory VenueMarker.create(Venue venue, double zoom) {
    final dims = _VenueMarkerDims(zoom);
    final builder = _VenueMarkerBuilder(dims, venue);
    return VenueMarker._(venue, dims.size, builder.buildMarker);
  }

  Venue venue;
}

class _VenueMarkerBuilder {
  _VenueMarkerBuilder(this._dims, this._venue);

  Venue _venue;
  _VenueMarkerDims _dims;

  Cuisine get _cuisine =>
      _venue.cuisines.isNotEmpty ? _venue.cuisines.first : Cuisine.UNKNOWN;

  Widget buildMarker(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: _buildBubble()),
      Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: _buildImage(),
      ),
    ]);
  }

  Padding _buildImage() {
    return Padding(
      padding: EdgeInsets.all(_dims.imagePadding),
      child: Image.asset(
        'images/food/${_cuisine.image}.png',
        color: Colors.white,
        height: _dims.imageHeight,
        colorBlendMode: BlendMode.srcATop,
      ),
    );
  }

  Widget _buildBubble() {
    return CustomPaint(
      painter: VenueMarkerBubblePainter(
        footHeightRatio: _dims.footHeightRatio,
        color: _cuisine.color,
      ),
      size: Size(_dims.size, _dims.size),
    );
  }
}

class _VenueMarkerDims {
  _VenueMarkerDims(this._zoom);

  final _minZoom = 1.0;
  final _maxZoom = 20.0;
  final _minSize = 4.0;
  final _maxSize = 96.0;
  final _imageHeightRatio = 0.75;
  final _imagePaddingRatio = 0.1;

  double _zoom;
  double _size;

  double get size => _size ??= _calcMarkerSize();
  double get footHeightRatio => 1 - _imageHeightRatio;
  double get imageHeight => size * _imageHeightRatio - 2 * imagePadding;
  double get imagePadding => size * _imagePaddingRatio;

  double _calcMarkerSize() {
    final exponent = 4.0;
    final baseSize = _minSize - pow(_minZoom, exponent);
    final sizeFactor = (_maxSize - _minSize) /
        (pow(_maxZoom, exponent) - pow(_minZoom, exponent));
    return (baseSize + pow(_zoom, exponent)) * sizeFactor;
  }
}
