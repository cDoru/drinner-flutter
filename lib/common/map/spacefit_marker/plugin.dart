import 'package:drinner_flutter/common/map/animated_marker/plugin.dart';
import 'package:drinner_flutter/common/map/spacefit_marker/layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class SpaceFitMarkerPlugin extends MapPlugin {
  @override
  Widget createLayer(LayerOptions options, MapState mapState) =>
      SpaceFitMarkerLayer(options, mapState);

  @override
  bool supportsLayer(LayerOptions options) =>
      options is SpaceFitMarkerLayerOptions;
}

class SpaceFitMarkerLayerOptions extends LayerOptions {
  SpaceFitMarkerLayerOptions({
    @required this.animOptions,
    this.interval = const Duration(seconds: 5),
    this.showOffBounds = true,
    this.limit = 0,
  }) : assert(limit >= 0);

  final AnimatedMarkerLayerOptions animOptions;
  final Duration interval;
  final bool showOffBounds;
  final int limit;
}
