import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:quiver/core.dart';

class MapCamera {
  const MapCamera({
    @required this.lat,
    @required this.lon,
    @required this.zoom,
  });

  final double lat;
  final double lon;
  final double zoom;

  static MapCamera fromPosition(MapPosition position) => MapCamera(
        lat: position.center.latitude,
        lon: position.center.longitude,
        zoom: position.zoom,
      );

  MapCamera copy({double lat, double lon, double zoom}) => MapCamera(
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        zoom: zoom ?? this.zoom,
      );

  @override
  String toString() => 'MapCamera(lat: $lat, lon: $lon, zoom: $zoom)';

  @override
  int get hashCode => hash3(lat, lon, zoom);

  bool operator ==(other) =>
      other is MapCamera &&
      (other.lat == lat && other.lon == lon && other.zoom == zoom);

  MapCamera operator +(MapCamera other) => MapCamera(
      lat: lat + other.lat, lon: lon + other.lon, zoom: zoom + other.zoom);

  MapCamera operator -(MapCamera other) => MapCamera(
      lat: lat - other.lat, lon: lon - other.lon, zoom: zoom - other.zoom);

  MapCamera operator *(double ratio) =>
      MapCamera(lat: lat * ratio, lon: lon * ratio, zoom: zoom * ratio);
}
