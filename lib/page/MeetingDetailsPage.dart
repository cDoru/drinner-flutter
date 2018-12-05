import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/MeetingDetailsBloc.dart';
import 'package:drinner_flutter/common/AnimatedSwitch.dart';
import 'package:drinner_flutter/common/map/DrinnerMap.dart';
import 'package:drinner_flutter/common/rx/SafeStreamBuilder.dart';
import 'package:drinner_flutter/model/MapCamera.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

class MeetingDetailsPage extends StatefulWidget {
  MeetingDetailsPage(this.meeting);

  final Meeting meeting;

  @override
  MeetingDetailsPageState createState() => MeetingDetailsPageState();
}

class MeetingDetailsPageState extends State<MeetingDetailsPage>
    with SingleTickerProviderStateMixin {
  MeetingDetailsBloc _detailsBloc;
  StreamSubscription _cameraUpdateSub;
  StreamSubscription _autoPositionSub;
  MapController _mapController;
  AnimationController _animator;
  Animation<MapCamera> _animation;

  Meeting get _meeting => widget.meeting;

  @override
  void initState() {
    super.initState();
    _animator = AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..addListener(() => _updateMapPosition(_animation.value));
    _mapController = MapController();
    _detailsBloc = BlocFactory.meetingDetailsBloc;
    _cameraUpdateSub = _detailsBloc.cameraUpdate.listen(_animateToCamera);
    _detailsBloc.meetingInput.add(_meeting);
    _autoPositionSub = _detailsBloc.autoPosition.listen(_onAutoPositionChanged);
  }

  @override
  void dispose() {
    _animator.dispose();
    _detailsBloc.dispose();
    _cameraUpdateSub.cancel();
    _autoPositionSub.cancel();
    super.dispose();
  }

  void _updateMapPosition(MapCamera camera) {
    final center = LatLng(camera.lat, camera.lon);
    final zoom = camera.zoom;
    _mapController.move(center, zoom);
  }

  void _animateToCamera(MapCamera camera) async {
    await _mapController.onReady;
    final current = camera.copy(
      lat: _mapController.center?.latitude,
      lon: _mapController.center?.longitude,
      zoom: _mapController.zoom,
    );
    _animation = Tween(begin: current, end: camera).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _animator,
    ));
    _animator.forward(from: 0.0);
  }

  void _onTapEvent(bool tapped) {
    if (tapped && _animator.isAnimating) {
      _animator.stop();
    }
    _detailsBloc.tappedInput.add(tapped);
  }

  void _onAutoPositionChanged(bool enabled) {
    if (!enabled && _animator.isAnimating) _animator.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_meeting.name)),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildWhenHeader(),
          _buildWhenSection(),
          _buildSectionSpace(),
          _buildMembersHeader(),
          _buildMembersSection(),
          _buildSectionSpace(),
          _buildWhereHeader(),
          _buildWhereSection(),
        ],
      ),
    );
  }

  Widget _buildSectionSpace() => Padding(padding: EdgeInsets.only(top: 16.0));
  Widget _buildWhereHeader() => _buildHeader('Where');
  Widget _buildMembersHeader() => _buildHeader('Members');
  Widget _buildWhenHeader() => _buildHeader('When');
  Widget _buildHeader(String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(text),
      );

  Widget _buildWhenSection() {
    return Row(children: [
      Text('Date'),
      Text(DateFormat.yMMMMd().format(_meeting.dateTime)),
      Text('Time'),
      Text(DateFormat.Hm().format(_meeting.dateTime)),
    ]);
  }

  Widget _buildMembersSection() {
    return SafeStreamBuilder(
        stream: _detailsBloc.members,
        builder: (_, snapshot) {
          final members = snapshot.data as List<MeetingDetailsMember>;
          return Container(
            height: 64.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (_, index) =>
                  _buildMeetingMemberItem(members[index]),
            ),
          );
        });
  }

  Widget _buildMeetingMemberItem(MeetingDetailsMember member) {
    return Container(
      width: 128.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: member.image,
            builder: (_, snapshot) => _buildAvatarImage(snapshot),
          ),
          Text(member.name),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(AsyncSnapshot<Uint8List> snapshot) {
    final size = 48.0;
    return SizedBox(
      width: size,
      height: size,
      child: snapshot.hasData
          ? Image.memory(snapshot.data)
          : Center(
              child: Container(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(),
            )),
    );
  }

  Widget _buildWhereSection() {
    final venue = _meeting.venue;
    final camera = MapCamera(
      lat: venue.location.lat,
      lon: venue.location.lon,
      zoom: _detailsBloc.startZoom,
    );
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_meeting.venue.name),
                  Text(_meeting.venue.address),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: AnimatedSwitch(
                  text: 'Auto position',
                  initValue: _detailsBloc.autoPosInitValue,
                  onChanged: _detailsBloc.autoPositionInput.add,
                ),
              ),
            ),
          ]),
          Expanded(
            child: Listener(
              onPointerDown: (_) => _onTapEvent(true),
              onPointerUp: (_) => _onTapEvent(false),
              child: DrinnerMap(
                context: context,
                camera: camera,
                venues: [venue],
                onCameraChanged: _detailsBloc.cameraChangeInput.add,
                mapController: _mapController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
