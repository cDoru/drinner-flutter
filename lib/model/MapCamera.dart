import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

class MapCamera {
  const MapCamera({
    @required this.lat,
    @required this.lon,
    @required this.zoom,
  });

  static MapCamera fromPosition(MapPosition position) => MapCamera(
        lat: position.center.latitude,
        lon: position.center.longitude,
        zoom: position.zoom,
      );

  final double lat;
  final double lon;
  final double zoom;
}
