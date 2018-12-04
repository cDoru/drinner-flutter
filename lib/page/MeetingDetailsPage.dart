import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/MeetingDetailsBloc.dart';
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

class MeetingDetailsPageState extends State<MeetingDetailsPage> {
  MeetingDetailsBloc _detailsBloc;

  Meeting get _meeting => widget.meeting;

  @override
  void initState() {
    super.initState();
    _detailsBloc = BlocFactory.meetingDetailsBloc;
    _detailsBloc.membersInput.add(_meeting.members);
  }

  @override
  void dispose() {
    _detailsBloc.dispose();
    super.dispose();
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
      zoom: 15.0,
    );
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_meeting.venue.name),
          Expanded(
            child: DrinnerMap.create(
              context,
              interactive: false,
              camera: camera,
              venues: [venue],
            ),
          )
        ],
      ),
    );
  }
}
