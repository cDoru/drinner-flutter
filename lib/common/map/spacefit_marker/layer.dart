import 'dart:async';
import 'dart:collection';

import 'package:drinner_flutter/common/map/animated_marker/layer.dart';
import 'package:drinner_flutter/common/map/animated_marker/plugin.dart';
import 'package:drinner_flutter/common/map/listener.dart';
import 'package:drinner_flutter/common/map/spacefit_marker/plugin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class SpaceFitMarkerLayer extends StatefulWidget {
  SpaceFitMarkerLayer(this._options, this._mapState);

  final SpaceFitMarkerLayerOptions _options;
  final MapState _mapState;

  @override
  SpaceFitMarkerLayerState createState() => SpaceFitMarkerLayerState();
}

class SpaceFitMarkerLayerState extends State<SpaceFitMarkerLayer> {
  AnimatedMarkerLayerController _markerController;
  MapMoveListener _mapListener;
  Queue<Marker> _queue = Queue();
  List<Marker> _visible = List();
  Timer _timer;

  List<Marker> get _markers => widget._options.animOptions.markers;
  SpaceFitMarkerLayerOptions get _options => widget._options;

  @override
  void initState() {
    super.initState();
    _markerController = AnimatedMarkerLayerController();
    _mapListener = MapMoveListener(_onMapMoved);
    _queue = Queue.from(_markers);
    _timer = Timer.periodic(_options.interval, (_) => _refreshMarkers());
  }

  @override
  void dispose() {
    _timer.cancel();
    _mapListener.dispose();
    super.dispose();
  }

  void _onMapMoved(MapPosition position) {
    _queue = Queue.from(_markers);
    _refreshMarkers();
  }

  void _refreshMarkers() {
    final picked = List<Marker>();
    final skipped = List<Marker>();
    final limit = _options.limit > 0 ? _options.limit : _queue.length;
    while (_queue.isNotEmpty) {
      final marker = _queue.removeFirst();
      _willOverlap(marker, picked) ? skipped.add(marker) : picked.add(marker);
      if (picked.length == limit) break;
    }
    _queue = Queue()..addAll(skipped)..addAll(_queue)..addAll(picked);
    _markerController
      ..hideAll(_queue.toList())
      ..showAll(picked);
    setState(() {});
  }

  bool _willOverlap(Marker marker, List<Marker> other) {
    final markerPoint = _getMarkerTopLeft(marker);
    final overlapped = other.firstWhere((it) {
      final point = _getMarkerTopLeft(it);
      final overlapX = (point.x - markerPoint.x).abs() <
          (point.x > markerPoint.x ? marker.width : it.width);
      final overlapY = (point.y - markerPoint.y).abs() <
          (point.y > markerPoint.y ? marker.height : it.height);
      return overlapX && overlapY;
    }, orElse: () => null);
    return overlapped != null;
  }

  Point _getMarkerTopLeft(Marker marker) {
    final center = widget._mapState.project(marker.point);
    return Point(
      center.x - marker.anchor.left,
      center.y - marker.anchor.top,
    );
  }

  @override
  Widget build(BuildContext context) {
    _mapListener.update(widget._mapState);
    final options = _cloneAnimOptions(_markerController, _markers);
    return AnimatedMarkerLayer(options, widget._mapState);
  }

  AnimatedMarkerLayerOptions _cloneAnimOptions(
    AnimatedMarkerLayerController controller,
    List<Marker> markers,
  ) {
    final old = _options.animOptions;
    return AnimatedMarkerLayerOptions(
      markers: markers,
      controller: controller,
      identifier: old.identifier,
      animBuilder: old.animBuilder,
      animDuration: old.animDuration,
      onTap: old.onTap,
    );
  }
}
