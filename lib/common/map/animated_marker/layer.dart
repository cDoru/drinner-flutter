import 'package:drinner_flutter/common/map/animated_marker/builder.dart';
import 'package:drinner_flutter/common/map/animated_marker/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class AnimatedMarkerLayerController {
  _AnimatedMarkerLayerState _state;

  void show(Marker marker) => _state?._showMarkers([marker]);

  void showAll(List<Marker> markers) => _state?._showMarkers(markers);

  void showWhere(Predicate<Marker> predicate) =>
      _state?._showMarkers(_state._markers.where(predicate).toList());

  void hide(Marker marker) => _state?._hideMarkers([marker]);

  void hideAll(List<Marker> markers) => _state?._hideMarkers(markers);

  void hideWhere(Predicate<Marker> predicate) =>
      _state?._hideMarkers(_state._markers.where(predicate).toList());

  void toggle(Marker marker) => _state?._toggleMarkers([marker]);

  void toggleAll(List<Marker> markers) => _state?._toggleMarkers(markers);

  void toggleWhere(Predicate<Marker> predicate) =>
      _state?._toggleMarkers(_state._markers.where(predicate).toList());

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
  CachingBuilder<_AnimDirectedMarker, AnimationController> _animatorBuilder;

  AnimatedMarkerLayerOptions get _options => widget.options;
  List<Marker> get _markers => widget.options.markers;

  @override
  void initState() {
    super.initState();
    _staticAnimator = AnimationController(vsync: this, value: 1.0);
    _animatorBuilder =
        CachingBuilder(_createAnimator, _shouldAnimate, _staticAnimator);
  }

  @override
  void dispose() {
    _staticAnimator.dispose();
    super.dispose();
  }

  void _toggleMarkers(List<Marker> markers) {
    final toShow = List<Marker>();
    final toHide = List<Marker>();
    markers.forEach((it) {
      final status = _animatorBuilder[_AnimDirectedMarker(it)]?.status;
      final shouldShow = status == AnimationStatus.reverse ||
          status == AnimationStatus.dismissed;
      shouldShow ? toShow.add(it) : toHide.add(it);
    });
    _showMarkers(toShow);
    _hideMarkers(toHide);
  }

  void _showMarkers(List<Marker> markers) =>
      _animateMarkers(markers, _AnimationDirection.FORWARD);

  void _hideMarkers(List<Marker> markers) =>
      _animateMarkers(markers, _AnimationDirection.REVERSE);

  void _animateMarkers(List<Marker> markers, _AnimationDirection direction) {
    if (markers.isEmpty) return;
    markers
        .map((it) => _AnimDirectedMarker(it, direction))
        .forEach(_animatorBuilder.request);
    _animatorBuilder.collect().forEach((it) {
      _isForward(direction) ? it.forward() : it.reverse();
    });
    setState(() {});
  }

  bool _isForward(_AnimationDirection direction) =>
      direction == _AnimationDirection.FORWARD;

  bool _shouldAnimate(
      _AnimDirectedMarker directedMarker, AnimationController previous) {
    final status = previous.status;
    final isForward = directedMarker.direction == _AnimationDirection.FORWARD;
    return isForward
        ? status == AnimationStatus.dismissed ||
            status == AnimationStatus.reverse
        : status == AnimationStatus.completed ||
            status == AnimationStatus.forward;
  }

  AnimationController _createAnimator(
      _AnimDirectedMarker directedMarker, AnimationController previous) {
    final isForward = _isForward(directedMarker.direction);
    final endStatus =
        isForward ? AnimationStatus.completed : AnimationStatus.dismissed;
    final value = previous?.value ?? (isForward ? 0.0 : 1.0);
    final animator = AnimationController(
      duration: _options.animDuration,
      value: value,
      vsync: this,
    );
    animator.addStatusListener((it) {
      if (it == endStatus) animator.dispose();
    });
    return animator;
  }

  @override
  Widget build(BuildContext context) {
    _options.controller?._init(this);
    final markersSwitch = Map();
    final markers =
        _markers.map((it) => _createAnimatedMarker(it, markersSwitch)).toList();
    final options = MarkerLayerOptions(
      markers: markers,
      onTap: (it) => _options.onTap(markersSwitch[it]),
    );
    return MarkerLayer(options, widget.mapState);
  }

  Marker _createAnimatedMarker(Marker marker, Map _markersSwitch) {
    final animator = _animatorBuilder[_AnimDirectedMarker(marker)];
    final animMarker = _cloneMarkerWithAnimator(marker, animator);
    _markersSwitch[animMarker] = marker;
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

enum _AnimationDirection { FORWARD, REVERSE, UNSPEC }

class _AnimDirectedMarker {
  _AnimDirectedMarker(this.marker,
      [this.direction = _AnimationDirection.UNSPEC]);
  final Marker marker;
  final _AnimationDirection direction;
}
