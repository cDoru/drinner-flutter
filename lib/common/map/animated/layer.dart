import 'package:drinner_flutter/common/map/animated/plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class AnimatedMarkerLayerController<T extends Marker> {
  _AnimatedMarkerLayerState<T> _state;

  void show(Marker marker) => _state?._showMarkers([marker]);

  void showAll(List<Marker> markers) => _state?._showMarkers(markers);

  void showWhere(Predicate<T> predicate) =>
      _state?._showMarkers(_state._markers.where(predicate).toList());

  void hide(Marker marker) => _state?._hideMarkers([marker]);

  void hideAll(List<Marker> markers) => _state?._hideMarkers(markers);

  void hideWhere(Predicate<T> predicate) =>
      _state?._hideMarkers(_state._markers.where(predicate).toList());

  void toggle(Marker marker) => _state?._toggleMarkers([marker]);

  void toggleAll(List<Marker> markers) => _state?._toggleMarkers(markers);

  void toggleWhere(Predicate<T> predicate) =>
      _state?._toggleMarkers(_state._markers.where(predicate).toList());

  void _init(_AnimatedMarkerLayerState<T> state) => _state = state;
}

class AnimatedMarkerLayer<T extends Marker> extends StatefulWidget {
  AnimatedMarkerLayer(this.options, this.mapState);

  final AnimatedMarkerLayerOptions<T> options;
  final MapState mapState;

  @override
  State<StatefulWidget> createState() => _AnimatedMarkerLayerState<T>();
}

class _AnimatedMarkerLayerState<T extends Marker>
    extends State<AnimatedMarkerLayer<T>> with TickerProviderStateMixin {
  final Map<Object, AnimationController> _animators = Map();

  AnimationController _staticAnimator;
  Map<Marker, T> _markersSwitch;

  AnimatedMarkerLayerOptions<T> get _options => widget.options;
  List<T> get _markers => widget.options.markers;

  @override
  void initState() {
    super.initState();
    _staticAnimator = AnimationController(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _staticAnimator.dispose();
    super.dispose();
  }

  void _showMarkers(List<T> markers) =>
      _animateMarkers(markers, _AnimationDirection.FORWARD);

  void _hideMarkers(List<T> markers) =>
      _animateMarkers(markers, _AnimationDirection.REVERSE);

  void _toggleMarkers(List<T> markers) {
    final toShow = List<T>();
    final toHide = List<T>();
    markers.forEach((it) {
      final status = _animators[_options.identifier(it)]?.status;
      final shouldShow = status == AnimationStatus.reverse ||
          status == AnimationStatus.dismissed;
      shouldShow ? toShow.add(it) : toHide.add(it);
    });
    _showMarkers(toShow);
    _hideMarkers(toHide);
  }

  void _animateMarkers(List<T> markers, _AnimationDirection direction) {
    if (markers.isEmpty) return;
    final animsSwitch = Map<AnimationController, AnimationController>();
    final pendingAnims = List<AnimationController>();
    final defaultStartValue = direction.isForward ? 0.0 : 1.0;
    final endStatus = direction.isForward
        ? AnimationStatus.completed
        : AnimationStatus.dismissed;
    markers.forEach((it) {
      final markerId = _options.identifier(it);
      final oldAnim = _animators[markerId];
      if (animsSwitch.containsKey(oldAnim)) {
        // another marker already requested new animator for the old one
        _animators[markerId] = animsSwitch[oldAnim];
      } else if (_shouldAnimate(oldAnim, direction)) {
        // marker hasn't been animated yet or already finished previous transition
        final startValue = oldAnim?.value ?? defaultStartValue;
        final newAnim = _createAnimator(endStatus, value: startValue);
        animsSwitch[oldAnim] = newAnim;
        _animators[markerId] = newAnim;
        pendingAnims.add(newAnim);
      } else {
        // animator is already in desired state or animating towards it
        animsSwitch[oldAnim] = oldAnim;
      }
    });
    pendingAnims.forEach((it) {
      direction.isForward ? it.forward() : it.reverse();
    });
    setState(() {});
  }

  bool _shouldAnimate(
      AnimationController animator, _AnimationDirection direction) {
    final status = animator.status;
    return direction.isForward
        ? status == AnimationStatus.reverse ||
            status == AnimationStatus.dismissed
        : status == AnimationStatus.forward ||
            status == AnimationStatus.completed;
  }

  AnimationController _createAnimator(AnimationStatus endStatus,
      {@required double value}) {
    final animator = AnimationController(
      vsync: this,
      duration: _options.animDuration,
      value: value,
    );
    animator.addStatusListener((it) {
      if (it == endStatus) animator.dispose();
    });
    return animator;
  }

  @override
  Widget build(BuildContext context) {
    _markersSwitch = Map();
    _options.controller?._init(this);
    final markers = _markers.map(_buildMarkerWidgets).toList();
    final options = MarkerLayerOptions(markers: markers, onTap: _onMarkerTap);
    return MarkerLayer(options, widget.mapState);
  }

  void _onMarkerTap(Marker marker) => _options.onTap(_markersSwitch[marker]);

  Marker _buildMarkerWidgets(T marker) {
    final animator = _animators.putIfAbsent(
        _options.identifier(marker), () => _staticAnimator);
    final animMarker = _buildAnimatedMarker(marker, animator);
    _markersSwitch[animMarker] = marker;
    return animMarker;
  }

  Marker _buildAnimatedMarker(T marker, AnimationController animator) {
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

class _AnimationDirection {
  const _AnimationDirection(this.isForward);
  static const FORWARD = _AnimationDirection(true);
  static const REVERSE = _AnimationDirection(false);
  final bool isForward;
}
