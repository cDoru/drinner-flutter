import 'package:drinner_flutter/app/AppAttrs.dart';
import 'package:drinner_flutter/app/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class VenuesPage extends StatelessWidget {
  static const _MAPBOX_TOKEN = AppConfig.MAPBOX_TOKEN;
  static const _MAPBOX_URL =
      'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}';
  static const _START_LAT = 51.11;
  static const _START_LON = 17.03;
  static const _START_ZOOM = 11.0;

  final _controller = MapController();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        center: LatLng(_START_LAT, _START_LON),
        zoom: _START_ZOOM,
      ),
      layers: <LayerOptions>[
        TileLayerOptions(
          urlTemplate: _MAPBOX_URL,
          additionalOptions: {
            'accessToken': _MAPBOX_TOKEN,
            'id': AppAttrs.of(context).mapboxStyle,
          },
        ),
      ],
    );
  }
}
