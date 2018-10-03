import 'package:drinner_flutter/common/map/animated/layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

export './layer.dart' show AnimatedMarkerLayerController;

typedef bool Predicate<T>(T item);
typedef Animation<T> AnimationBuilder<T>(AnimationController animator);
typedef K Identifier<T, K>(T item);

class AnimatedMarkerPlugin extends MapPlugin {
  @override
  Widget createLayer(LayerOptions options, MapState mapState) =>
      AnimatedMarkerLayer(options as AnimatedMarkerLayerOptions, mapState);

  @override
  bool supportsLayer(LayerOptions options) =>
      options is AnimatedMarkerLayerOptions;
}

class AnimatedMarkerLayerOptions<T extends Marker> extends LayerOptions {
  AnimatedMarkerLayerOptions({
    @required this.markers,
    @required this.identifier,
    this.onTap,
    this.controller,
    Duration animDuration,
    MarkerTransitionBuilder animBuilder,
  })  : this.animBuilder = animBuilder ?? defaultBuilder,
        this.animDuration = animDuration ?? defaultDuration;

  static final defaultDuration = Duration(milliseconds: 500);
  static final defaultBuilder = (context, child, animator) => ScaleTransition(
        alignment: Alignment.bottomCenter,
        child: child,
        scale: Tween(begin: 0.0, end: 1.0).animate(animator),
      );

  final List<T> markers;
  final MarkerTapCallback onTap;
  final Identifier<T, Object> identifier;
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
