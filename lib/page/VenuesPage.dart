import 'package:drinner_flutter/app/AppAttrs.dart';
import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/bloc/MapBloc.dart';
import 'package:drinner_flutter/bloc/VenuesBloc.dart';
import 'package:drinner_flutter/common/SafeStreamBuilder.dart';
import 'package:drinner_flutter/common/marker/VenueMarker.dart';
import 'package:drinner_flutter/model/MapCamera.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

class VenuesPage extends StatefulWidget {
  VenuesPage(this._mapApiUrl, this._mapApiToken);

  final String _mapApiToken;
  final String _mapApiUrl;
  final MapController _mapController = MapController();

  @override
  VenuesPageState createState() => VenuesPageState();
}

class VenuesPageState extends State<VenuesPage> {
  VenuesBloc _venuesBloc = BlocFactory.venuesBloc;
  MapBloc _mapBloc = BlocFactory.mapBloc;
  Observable<_ZoomedVenues> _zoomedVenues;

  @override
  void initState() {
    _zoomedVenues = Observable.combineLatest2(
        _mapBloc.zoom, _venuesBloc.venues, _ZoomedVenues.create);
    super.initState();
  }

  void _onMapMoved(MapPosition position) =>
      _mapBloc.cameraChangedEvent.add(MapCamera(
        lat: position.center.latitude,
        lon: position.center.longitude,
        zoom: position.zoom,
      ));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: BlocFactory.venuesBloc,
      child: SafeStreamBuilder(
        stream: _zoomedVenues,
        builder: _buildVenuesMap,
      ),
    );
  }

  Widget _buildVenuesMap(
      BuildContext context, AsyncSnapshot<_ZoomedVenues> snapshot) {
    return FlutterMap(
      mapController: widget._mapController,
      options: MapOptions(
        onPositionChanged: _onMapMoved,
        center: LatLng(_mapBloc.startCamera.lat, _mapBloc.startCamera.lon),
        zoom: _mapBloc.startCamera.zoom,
        minZoom: _mapBloc.minZoom,
        maxZoom: _mapBloc.maxZoom,
      ),
      layers: <LayerOptions>[
        _buildMapLayer(context),
        _buildMarkersLayer(snapshot.data.venues, snapshot.data.zoom),
      ],
    );
  }

  MarkerLayerOptions _buildMarkersLayer(List<Venue> venues, double zoom) {
    venues.sort((v1, v2) => (v2.location.lat - v1.location.lat).ceil());
    return MarkerLayerOptions(
      markers: venues.map((it) => VenueMarker.create(it, zoom)).toList(),
    );
  }

  TileLayerOptions _buildMapLayer(BuildContext context) {
    return TileLayerOptions(
      urlTemplate: widget._mapApiUrl,
      additionalOptions: {
        'accessToken': widget._mapApiToken,
        'id': AppAttrs.of(context).mapboxStyle,
      },
    );
  }
}

class _ZoomedVenues {
  _ZoomedVenues(this.zoom, this.venues);
  static _ZoomedVenues create(zoom, venues) => _ZoomedVenues(zoom, venues);
  final double zoom;
  final List<Venue> venues;
}
