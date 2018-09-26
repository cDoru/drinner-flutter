import 'dart:math';
import 'dart:typed_data';

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

  double get _imageHeight => _size * 0.75;
  double get _imagePadding => _size * 0.1;
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
              painter: _MarkerBubblePainter(_cuisine.color),
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

class _MarkerBubblePainter extends CustomPainter {
  _MarkerBubblePainter(this.color);

  final Path _basePath = _BaseMarkerPath.create();
  _SizedPath _lastPath = _SizedPath.blank();

  final Color color;

  double get _basePathSize => _BaseMarkerPath.SIZE;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isEmpty) {
      final path = _getMarkerPath(size);
      final paint = Paint()..color = color;
      canvas.drawShadow(path, Colors.black, 2.0, false);
      canvas.drawPath(path, paint);
    }
  }

  Path _getMarkerPath(Size size) {
    if (size != _lastPath.size) {
      final path = _basePath.transform(_getScaleMatrix(size));
      _lastPath = _SizedPath(size, path);
    }
    return _lastPath.path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  Float64List _getScaleMatrix(Size size) {
    return Float64List.fromList([
      size.width / _basePathSize, 0.0, 0.0, 0.0,
      0.0, size.height / _basePathSize, 0.0, 0.0, 
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0,
    ]);
  }
}

class _SizedPath {
  _SizedPath(this.size, this.path);
  factory _SizedPath.blank() => _SizedPath(Size.zero, Path());
  Size size;
  Path path;
}

class _BaseMarkerPath {
  _BaseMarkerPath._();
  static Path create() => _BaseMarkerPath._().path;

  static const SIZE = 64.0;

  final footTotalWidth = 20.0;
  final footTotalHeight = 16.0;
  final borderRadius = 4.0;
  final footTopRadius = 4.0;
  final footBottomRadius = 2.0;

  get borderTopWidth => SIZE - 2 * borderRadius;
  get borderBottomHalfWidth => (borderTopWidth - footTotalWidth) / 2;
  get borderHeight => SIZE - 2 * borderRadius - footTotalHeight;
  get footBottomDiameter => 2 * footBottomRadius;
  get footSlantHeight => footTotalHeight - footTopRadius - footBottomRadius;
  get footSlantWidth => footTotalWidth / 2 - (footTopRadius + footBottomRadius);
  get footConicXEnd => footTopRadius / 4;
  get footConicXStart => footTopRadius * 3 / 4;

  Path get path => Path()
    ..moveTo(borderRadius, 0.0)
    ..relativeLineTo(borderTopWidth, 0.0)
    ..relativeArcToPoint(Offset(borderRadius, borderRadius),
        radius: Radius.circular(borderRadius))
    ..relativeLineTo(0.0, borderHeight)
    ..relativeArcToPoint(Offset(-borderRadius, borderRadius),
        radius: Radius.circular(borderRadius))
    ..relativeLineTo(-borderBottomHalfWidth, 0.0)
    ..relativeConicTo(-footConicXStart, 0.0, -footTopRadius, footTopRadius, 1.0)
    ..relativeLineTo(-footSlantWidth, footSlantHeight)
    ..relativeArcToPoint(Offset(-footBottomDiameter, 0.0),
        radius: Radius.circular(footBottomRadius))
    ..relativeLineTo(-footSlantWidth, -footSlantHeight)
    ..relativeConicTo(
        -footConicXEnd, -footTopRadius, -footTopRadius, -footTopRadius, 1.0)
    ..relativeLineTo(-borderBottomHalfWidth, 0.0)
    ..relativeArcToPoint(Offset(-borderRadius, -borderRadius),
        radius: Radius.circular(borderRadius))
    ..relativeLineTo(0.0, -borderHeight)
    ..relativeArcToPoint(Offset(borderRadius, -borderRadius),
        radius: Radius.circular(borderRadius))
    ..close();
}
