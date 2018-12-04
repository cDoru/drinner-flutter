import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

class MeetingDetailsBloc extends BaseBloc {
  MeetingDetailsBloc(this._drinnerApi) {
    members = membersInput.map(_mapMemberAvatars);
  }

  final DrinnerApi _drinnerApi;

  Subject<List<User>> membersInput = BehaviorSubject();
  Observable<List<MeetingDetailsMember>> members;

  @override
  void dispose() {
    membersInput.close();
  }

  List<MeetingDetailsMember> _mapMemberAvatars(List<User> members) =>
      members.map((it) {
        final avatar = _drinnerApi.getAvatar(it.avatarId);
        return MeetingDetailsMember(it.name, avatar);
      }).toList();
}

class MeetingDetailsMember {
  MeetingDetailsMember(this.name, this.image);

  final String name;
  final Future<Uint8List> image;
}
