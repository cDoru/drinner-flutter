import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/model/MapCamera.dart';
import 'package:rxdart/rxdart.dart';

class MapBloc extends BaseBloc {
  static const double _START_LAT = 51.11;
  static const double _START_LON = 17.03;
  static const double _START_ZOOM = 15.0;
  static const double _MIN_ZOOM = 8.0;
  static const double _MAX_ZOOM = 19.0;
  static const MapCamera _START_CAMERA =
      MapCamera(lat: _START_LAT, lon: _START_LON, zoom: _START_ZOOM);

  final Subject<MapCamera> _cameraSubject =
      BehaviorSubject(seedValue: _START_CAMERA);
  Subject<MapCamera> get cameraChangedEvent => _cameraSubject;
  Observable<double> get zoom => _cameraSubject
      .debounce(Duration(milliseconds: 100))
      .map((it) => it.zoom.roundToDouble())
      .distinct();

  MapCamera get startCamera => _START_CAMERA;
  double get minZoom => _MIN_ZOOM;
  double get maxZoom => _MAX_ZOOM;

  @override
  void dispose() {
    _cameraSubject.close();
  }
}
