import 'package:drinner_flutter/app/AppAttrs.dart';
import 'package:drinner_flutter/app/AppConfig.dart';
import 'package:drinner_flutter/common/map/marker/VenueMarker.dart';
import 'package:drinner_flutter/common/rx/SafeStreamBuilder.dart';
import 'package:drinner_flutter/common/typedefs.dart';
import 'package:drinner_flutter/model/MapCamera.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

class DrinnerMap extends StatefulWidget {
  DrinnerMap({
    BuildContext context,
    MapCamera camera,
    List<Venue> venues,
    Callback<MapCamera> onCameraChanged,
    MapController mapController,
  })  : this.source = _DrinnerMapSource.mapbox(context),
        this.camera = camera ?? MapCamera(lat: 51.11, lon: 17.03, zoom: 15.0),
        this.venues = venues ?? [],
        this.onCameraChanged = onCameraChanged ?? _blankOnCameraChanged,
        this.mapController = mapController ?? MapController();

  final _DrinnerMapSource source;
  final MapCamera camera;
  final List<Venue> venues;
  final Callback<MapCamera> onCameraChanged;
  final MapController mapController;

  static void _blankOnCameraChanged(MapCamera camera) {}

  @override
  DrinnerMapState createState() => DrinnerMapState();
}

class DrinnerMapState extends State<DrinnerMap> {
  static const double _MIN_ZOOM = 8.0;
  static const double _MAX_ZOOM = 19.0;

  Subject<MapCamera> _cameraSubject;

  Observable<double> get _zoomEvent => _cameraSubject
      .debounce(Duration(milliseconds: 100))
      .doOnData(widget.onCameraChanged)
      .map((it) => it.zoom.roundToDouble())
      .distinct();

  @override
  void initState() {
    super.initState();
    _cameraSubject = BehaviorSubject(seedValue: widget.camera);
  }

  @override
  void dispose() {
    _cameraSubject.close();
    super.dispose();
  }

  void _onPositionChanged(MapPosition position) {
    Future.value(position)
        .then(MapCamera.fromPosition)
        .then(_cameraSubject.add);
  }

  @override
  Widget build(BuildContext context) {
    return SafeStreamBuilder(
      stream: _zoomEvent,
      builder: (_, snapshot) => _buildDrinnerMap(snapshot.data),
    );
  }

  FlutterMap _buildDrinnerMap(double zoom) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        minZoom: _MIN_ZOOM,
        maxZoom: _MAX_ZOOM,
        zoom: widget.camera.zoom,
        center: LatLng(widget.camera.lat, widget.camera.lon),
        onPositionChanged: _onPositionChanged,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: widget.source.url,
          additionalOptions: {
            'accessToken': widget.source.token,
            'id': widget.source.style,
          },
        ),
        MarkerLayerOptions(
          markers: widget.venues.map((it) => VenueMarker(it, zoom)).toList(),
        ),
      ],
    );
  }
}

class _DrinnerMapSource {
  _DrinnerMapSource._(this.url, this.token, this.style);

  final String url;
  final String token;
  final String style;

  factory _DrinnerMapSource.mapbox(BuildContext context) {
    final attrs = AppAttrs.of(context);
    return _DrinnerMapSource._(
      AppConfig.MAPBOX_URL,
      AppConfig.MAPBOX_TOKEN,
      attrs.mapboxStyle,
    );
  }
}
