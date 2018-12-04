import 'dart:math';

import 'package:drinner_flutter/common/map/marker/MarkerBubblePainter.dart';
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
          anchorPos: AnchorPos.align(AnchorAlign.top),
          point: LatLng(venue.location.lat, venue.location.lon),
          builder: builder,
        );

  factory VenueMarker(Venue venue, double zoom) {
    final dimens = _VenueMarkerDimens(zoom);
    final builder = _VenueMarkerBuilder(dimens, venue);
    return VenueMarker._(venue, dimens.size, builder.buildMarker);
  }

  Venue venue;
}

class _VenueMarkerBuilder {
  _VenueMarkerBuilder(this._dimens, this._venue);

  final Venue _venue;
  final _VenueMarkerDimens _dimens;

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
      padding: EdgeInsets.all(_dimens.imagePadding),
      child: Image.asset(
        'images/food/${_cuisine.image}.png',
        color: Colors.white,
        height: _dimens.imageHeight,
        colorBlendMode: BlendMode.srcATop,
      ),
    );
  }

  Widget _buildBubble() {
    return CustomPaint(
      painter: VenueMarkerBubblePainter(
        footHeightRatio: _dimens.footHeightRatio,
        color: _cuisine.color,
      ),
      size: Size(_dimens.size, _dimens.size),
    );
  }
}

class _VenueMarkerDimens {
  _VenueMarkerDimens(this._zoom);

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
