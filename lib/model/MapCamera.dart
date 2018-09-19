import 'package:flutter/foundation.dart';

class MapCamera {
  const MapCamera({
    @required this.lat,
    @required this.lon,
    @required this.zoom,
  });

  final double lat;
  final double lon;
  final double zoom;
}
