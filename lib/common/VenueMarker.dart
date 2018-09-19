import 'dart:math';
import 'dart:typed_data';

import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart' show LatLng;

class VenueMarker {
  static const _MIN_ZOOM = 1.0;
  static const _MAX_ZOOM = 20.0;
  static const _MIN_SIZE = 4.0;
  static const _MAX_SIZE = 64.0;
  static const _SIZE_FACTOR = (_MAX_SIZE - _MIN_SIZE) /
      (_MAX_ZOOM * _MAX_ZOOM * _MAX_ZOOM - _MIN_ZOOM * _MIN_ZOOM * _MIN_ZOOM);
  static const _BASE_SIZE =
      _MIN_SIZE - _MIN_ZOOM * _MIN_ZOOM * _MIN_ZOOM * _SIZE_FACTOR;

  static Marker create(Venue venue, double zoom) {
    final size = (_BASE_SIZE + pow(zoom, 3) * _SIZE_FACTOR).roundToDouble();
    return Marker(
      width: size,
      height: size,
      point: LatLng(venue.location.lat, venue.location.lon),
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
  get footSlantHeight =>
      footTotalHeight - footTopRadius - footBottomRadius;
  get footSlantWidth =>
      footTotalWidth / 2 - (footTopRadius + footBottomRadius);
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
    ..relativeConicTo(-footConicXEnd, -footTopRadius, -footTopRadius, -footTopRadius, 1.0)
    ..relativeLineTo(-borderBottomHalfWidth, 0.0)
    ..relativeArcToPoint(Offset(-borderRadius, -borderRadius),
        radius: Radius.circular(borderRadius))
    ..relativeLineTo(0.0, -borderHeight)
    ..relativeArcToPoint(Offset(borderRadius, -borderRadius),
        radius: Radius.circular(borderRadius))
    ..close();
}
