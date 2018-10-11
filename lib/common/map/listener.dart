import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

typedef void MapCenterCallback(LatLng center);
typedef void MapZoomCallback(double zoom);

abstract class Disposable {
  void dispose();
}

class MapMoveListener extends Disposable {
  MapMoveListener(this._onMovedCallback) {
    _updateSubject
        .debounce(Duration(milliseconds: 100))
        .where(_hasChanged)
        .doOnData(_updateLast)
        .listen(_onMovedCallback);
  }

  Subject<MapPosition> _updateSubject = PublishSubject();

  PositionCallback _onMovedCallback;

  MapPosition _lastPosition;

  bool _hasChanged(MapPosition position) {
    _lastPosition ??= position;
    return position.zoom != _lastPosition.zoom ||
        position.center != _lastPosition.center;
  }

  void _updateLast(MapPosition position) => _lastPosition = position;

  void update(MapState mapState) => _updateSubject
      .add(MapPosition(center: mapState.center, zoom: mapState.zoom));

  @override
  void dispose() => _updateSubject.close();
}
