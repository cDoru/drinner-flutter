import 'package:drinner_flutter/common/map/animated_marker/layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

export './layer.dart' show AnimatedMarkerLayerController;

typedef bool Predicate<T>(T item);
typedef K Identifier<T, K>(T item);

class AnimatedMarkerPlugin extends MapPlugin {
  @override
  Widget createLayer(LayerOptions options, MapState mapState) =>
      AnimatedMarkerLayer(options as AnimatedMarkerLayerOptions, mapState);

  @override
  bool supportsLayer(LayerOptions options) =>
      options is AnimatedMarkerLayerOptions;
}

class AnimatedMarkerLayerOptions extends LayerOptions {
  AnimatedMarkerLayerOptions({
    @required this.markers,
    @required this.identifier,
    this.onTap,
    this.controller,
    this.startHidden = true,
    this.animDuration = const Duration(milliseconds: 500),
    MarkerTransitionBuilder animBuilder,
  }) : this.animBuilder = animBuilder ?? defaultBuilder;

  static final defaultBuilder = (context, child, animator) => ScaleTransition(
        alignment: Alignment.bottomCenter,
        child: child,
        scale: Tween(begin: 0.0, end: 1.0).animate(animator),
      );

  final bool startHidden;
  final List<Marker> markers;
  final MarkerTapCallback onTap;
  final Identifier<Marker, Object> identifier;
  final AnimatedMarkerLayerController controller;
  final Duration animDuration;
  // NOTE: marker widget is placed in the tree underneath Positioned widget
  // which takes width and height of given marker. If specified transition
  // is going to change widget's bounds beyond marker's size, GestureDetector
  // won't be able to detect tap events outside its bounds (e.g. slide/scale
  // transition with offset/scale bigger than 1).
  final MarkerTransitionBuilder animBuilder;
}

typedef Widget MarkerTransitionBuilder(
    BuildContext context, Widget child, AnimationController animator);
