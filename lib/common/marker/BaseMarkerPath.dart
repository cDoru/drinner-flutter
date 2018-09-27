import 'dart:ui';

class BaseMarkerPath {
  BaseMarkerPath._(double footHeightRatio)
      : footTotalHeight = SIZE * footHeightRatio;
  static Path create(double footHeightRatio) =>
      BaseMarkerPath._(footHeightRatio).path;

  static const SIZE = 64.0;

  final footTotalHeight;
  final footTotalWidth = 20.0;
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
