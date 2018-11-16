import 'dart:async';
import 'dart:collection';

import 'package:drinner_flutter/common/map/animated_marker/layer.dart';
import 'package:drinner_flutter/common/map/animated_marker/plugin.dart';
import 'package:drinner_flutter/common/map/spacefit_marker/plugin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:rxdart/rxdart.dart';

class SpaceFitMarkerLayer extends StatefulWidget {
  SpaceFitMarkerLayer(this._options, this._mapState)
      : this._markerMap = _createMarkerMap(_options.animOptions);

  static Map<Object, Marker> _createMarkerMap(
      AnimatedMarkerLayerOptions options) {
    final entries = options.markers.map(
      (it) => MapEntry(options.identifier(it), it),
    );
    return Map.fromEntries(entries);
  }

  final SpaceFitMarkerLayerOptions _options;
  final MapState _mapState;
  final Map<Object, Marker> _markerMap;

  @override
  SpaceFitMarkerLayerState createState() => SpaceFitMarkerLayerState();
}

class SpaceFitMarkerLayerState extends State<SpaceFitMarkerLayer> {
  Queue<Object> _markerQueue = Queue();
  Map<Object, bool> _inBoundsMap = Map();
  List<Marker> _visible = List();

  AnimatedMarkerLayerController _markerController;
  Subject _updateSubject;
  LatLngBounds _lastBounds;

  SpaceFitMarkerLayerOptions get _options => widget._options;
  LatLngBounds get _mapBounds => widget._mapState.bounds;
  Identifier<Marker, Object> get _identifier => _options.animOptions.identifier;

  @override
  void initState() {
    super.initState();
    _markerController = AnimatedMarkerLayerController();
    _updateSubject = _listenWidgetUpdates();
    _markerQueue = Queue.from(widget._markerMap.keys.toList()..shuffle());
    _awaitMapReady().then(_runUpdateLoop);
  }

  Subject _listenWidgetUpdates() {
    final subject = PublishSubject();
    subject.debounce(Duration(milliseconds: 100)).listen((_) {
      _syncQueueWithWidget();
      _updateIfMapMoved();
    });
    return subject;
  }

  void _updateIfMapMoved() {
    final bounds = widget._mapState.bounds;
    if (_lastBounds != bounds) {
      _lastBounds = bounds;
      _inBoundsMap = Map();
      _visible.reversed.map(_identifier).forEach((it) => _markerQueue
        ..remove(it)
        ..addFirst(it));
      _updateMarkers();
    }
  }

  Future _awaitMapReady() async {
    while (widget._mapState.zoom == null) {
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  void _runUpdateLoop(void v) {
    Future.doWhile(() async {
      _updateMarkers();
      await Future.delayed(_options.interval, () {});
      return mounted;
    });
  }

  @override
  void didUpdateWidget(SpaceFitMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSubject.add(null);
  }

  @override
  void dispose() {
    _updateSubject.close();
    super.dispose();
  }

  void _syncQueueWithWidget() {
    final markerIds = widget._markerMap.keys;
    _markerQueue..retainWhere(markerIds.contains);
    final toAdd = markerIds.where((it) => !_markerQueue.contains(it));
    _markerQueue.addAll(toAdd);
  }

  void _updateMarkers() {
    final picked = List<Marker>();
    final skipped = List<Marker>();
    _selectMarkers(picked, skipped);
    _swapMarkers(picked, skipped);
    setState(() {});
  }

  void _selectMarkers(List<Marker> picked, List<Marker> skipped) {
    final limit = _options.limit > 0 ? _options.limit : _markerQueue.length;
    while (_markerQueue.isNotEmpty) {
      final marker = widget._markerMap[_markerQueue.removeFirst()];
      final shouldPick = !_willOverlap(marker, picked) &&
          (_options.showOffBounds || _isMarkerInBounds(marker));
      shouldPick ? picked.add(marker) : skipped.add(marker);
      if (picked.length == limit) break;
    }
  }

  void _swapMarkers(List<Marker> picked, List<Marker> skipped) {
    _markerQueue = Queue()
      ..addAll(skipped.map(_identifier))
      ..addAll(_markerQueue)
      ..addAll(picked.map(_identifier));
    _markerController
      ..hideAll(_visible)
      ..showAll(picked);
    _visible = picked;
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

  bool _isMarkerInBounds(Marker marker) {
    return _inBoundsMap.putIfAbsent(
      _identifier(marker),
      () => _mapBounds.contains(marker.point),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget._options.animOptions.markers;
    final options = _cloneAnimOptions(_markerController, markers);
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
