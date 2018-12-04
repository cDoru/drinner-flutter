import 'package:drinner_flutter/model/User.dart';
import 'package:drinner_flutter/model/Venue.dart';
import 'package:flutter/foundation.dart';

class Meeting {
  Meeting({
    @required this.name,
    @required this.dateTime,
    @required this.venue,
    @required this.members,
  });

  final String name;
  final DateTime dateTime;
  final Venue venue;
  final List<User> members;

  Meeting copy({
    String name,
    DateTime dateTime,
    Venue venue,
    List<User> members,
  }) =>
      Meeting(
        name: name ?? this.name,
        dateTime: dateTime ?? this.dateTime,
        venue: venue ?? this.venue,
        members: members ?? this.members,
      );
}
