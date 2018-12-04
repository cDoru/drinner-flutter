import 'package:drinner_flutter/common/map/layer/animated_marker/builder.dart';
import 'package:drinner_flutter/common/map/layer/animated_marker/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class AnimatedMarkerLayerController {
  _AnimatedMarkerLayerState _state;

  void show(Marker marker) => _state?._showMarkers([marker]);
  void showAll(Iterable<Marker> markers) => _state?._showMarkers(markers);
  void showWhere(Predicate<Marker> predicate) =>
      _state?._showMarkers(_state._markers.where(predicate));

  void hide(Marker marker) => _state?._hideMarkers([marker]);
  void hideAll(Iterable<Marker> markers) => _state?._hideMarkers(markers);
  void hideWhere(Predicate<Marker> predicate) =>
      _state?._hideMarkers(_state._markers.where(predicate));

  void toggle(Marker marker) => _state?._toggleMarkers([marker]);
  void toggleAll(Iterable<Marker> markers) => _state?._toggleMarkers(markers);
  void toggleWhere(Predicate<Marker> predicate) =>
      _state?._toggleMarkers(_state._markers.where(predicate));

  void _init(_AnimatedMarkerLayerState state) => _state = state;
}

class AnimatedMarkerLayer extends StatefulWidget {
  AnimatedMarkerLayer(this.options, this.mapState);

  final AnimatedMarkerLayerOptions options;
  final MapState mapState;

  @override
  State<StatefulWidget> createState() => _AnimatedMarkerLayerState();
}

class _AnimatedMarkerLayerState extends State<AnimatedMarkerLayer>
    with TickerProviderStateMixin {
  AnimationController _staticAnimator;
  CachingBuilder _animatorBuilder;

  AnimatedMarkerLayerOptions get _options => widget.options;
  Iterable<Marker> get _markers => widget.options.markers;

  @override
  void initState() {
    super.initState();
    _staticAnimator = AnimationController(
        vsync: this, value: _options.startHidden ? 0.0 : 1.0);
    _animatorBuilder = AnimatorCachingBuilder(
        this, _options.animDuration, _identifyMarker, _staticAnimator);
  }

  Object _identifyMarker(AnimDirectedMarker directedMarker) =>
      _options.identifier(directedMarker.marker);

  @override
  void dispose() {
    _staticAnimator.dispose();
    super.dispose();
  }

  void _toggleMarkers(Iterable<Marker> markers) {
    final toShow = List<Marker>();
    final toHide = List<Marker>();
    markers.forEach((it) {
      final status = _animatorBuilder[AnimDirectedMarker(it)]?.status;
      final shouldShow = status == AnimationStatus.reverse ||
          status == AnimationStatus.dismissed;
      shouldShow ? toShow.add(it) : toHide.add(it);
    });
    _showMarkers(toShow);
    _hideMarkers(toHide);
  }

  void _showMarkers(Iterable<Marker> markers) =>
      _animateMarkers(markers, AnimDirection.FORWARD);

  void _hideMarkers(Iterable<Marker> markers) =>
      _animateMarkers(markers, AnimDirection.REVERSE);

  void _animateMarkers(Iterable<Marker> markers, AnimDirection direction) {
    if (markers.isEmpty) return;
    final isForward = direction == AnimDirection.FORWARD;
    markers
        .map((it) => AnimDirectedMarker(it, direction))
        .forEach(_animatorBuilder.request);
    _animatorBuilder.collect().forEach((it) {
      isForward ? it.forward() : it.reverse();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _options.controller?._init(this);
    final markersSwitch = Map<Marker, Marker>();
    final markers =
        _markers.map((it) => _createAnimatedMarker(it, markersSwitch)).toList();
    final options = MarkerLayerOptions(
      markers: markers,
      onTap: (it) => _options.onTap?.call(
            markersSwitch[it],
          ),
    );
    return MarkerLayer(options, widget.mapState);
  }

  Marker _createAnimatedMarker(Marker marker, Map markersSwitch) {
    final animator = _animatorBuilder[AnimDirectedMarker(marker)];
    final animMarker = _cloneMarkerWithAnimator(marker, animator);
    markersSwitch[animMarker] = marker;
    return animMarker;
  }

  Marker _cloneMarkerWithAnimator(Marker marker, AnimationController animator) {
    return Marker(
      width: marker.width,
      height: marker.height,
      point: marker.point,
      anchorPos: AnchorPos.exactly(marker.anchor),
      builder: (context) =>
          _options.animBuilder(context, marker.builder(context), animator),
    );
  }
}

enum AnimDirection { FORWARD, REVERSE, UNSPEC }
