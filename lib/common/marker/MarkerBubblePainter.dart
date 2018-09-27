import 'dart:typed_data';

import 'package:drinner_flutter/common/marker/BaseMarkerPath.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VenueMarkerBubblePainter extends CustomPainter {
  VenueMarkerBubblePainter({
    @required double footHeightRatio,
    @required this.color,
  }) : _basePath = BaseMarkerPath.create(footHeightRatio);

  final Path _basePath;
  final Color color;

  _SizedPath _lastPath = _SizedPath.blank();

  double get _basePathSize => BaseMarkerPath.SIZE;

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
