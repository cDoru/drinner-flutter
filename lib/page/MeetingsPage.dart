import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/bloc/MeetingsBloc.dart';
import 'package:drinner_flutter/common/rx/SafeStreamBuilder.dart';
import 'package:drinner_flutter/common/view_state/ViewStateWidget.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:flutter/material.dart';

class MeetingsPage extends StatefulWidget {
  @override
  MeetingsPageState createState() => MeetingsPageState();
}

class MeetingsPageState extends State<MeetingsPage> {
  MeetingsBloc _meetingsBloc;

  @override
  void initState() {
    super.initState();
    _meetingsBloc = BlocFactory.meetingsBloc;
  }

  @override
  void dispose() {
    _meetingsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _meetingsBloc,
      child: SafeStreamBuilder(
        stream: _meetingsBloc.userMeetings,
        builder: (_, snapshot) => Center(
              child: ViewStateWidget(
                state: snapshot.data,
                builder: _buildMeetingsList,
              ),
            ),
      ),
    );
  }

  Widget _buildMeetingsList(BuildContext context, List<Meeting> meetings) {
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (_, index) => _buildMeetingItem(meetings[index]),
    );
  }

  Widget _buildMeetingItem(Meeting meeting) {
    return InkWell(
      onTap: () => Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(meeting.venue.name),
            duration: Duration(milliseconds: 100),
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('When: ${meeting.dateTime.toIso8601String()}'),
          Text('Where: ${meeting.venue.name}'),
          Text('Who: ${meeting.members.length}'),
        ]),
      ),
    );
  }
}
