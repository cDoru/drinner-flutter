import 'dart:math';
import 'dart:typed_data';

import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart' show LatLng;

class VenueMarker {
  VenueMarker._(this._venue, this._zoom);

  static Marker create(Venue venue, double zoom) =>
      VenueMarker._(venue, zoom).marker;

  Venue _venue;
  double _zoom;

  final _minZoom = 1.0;
  final _maxZoom = 20.0;
  final _minSize = 4.0;
  final _maxSize = 64.0;
  
  double get _sizeFactor =>
      (_maxSize - _minSize) / (pow(_maxZoom, 3) - pow(_minZoom, 3));
  double get _baseSize => _minSize - pow(_minZoom, 3) * _sizeFactor;

  Marker get marker {
    final size = (_baseSize + pow(_zoom, 3) * _sizeFactor).roundToDouble();
    return Marker(
      width: size,
      height: size,
      point: LatLng(_venue.location.lat, _venue.location.lon),
      builder: (_) => CustomPaint(
            painter: _VenueMarkerPainter(),
            size: Size(size, size),
          ),
    );
  }
}

class _VenueMarkerPainter extends CustomPainter {
  Path _basePath = _BaseMarkerPath.create();
  _SizedPath _lastPath = _SizedPath.blank();

  double get _basePathSize => _BaseMarkerPath.SIZE;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.isEmpty) {
      final path = _getMarkerPath(size);
      final paint = Paint()..color = Colors.amber;
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
