import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/MapCamera.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:drinner_flutter/model/User.dart';
import 'package:rxdart/rxdart.dart';

class MeetingDetailsBloc extends BaseBloc {
  MeetingDetailsBloc(this._drinnerApi) {
    autoPositionInput = BehaviorSubject(seedValue: autoPosInitValue);
    members = meetingInput.map((it) => it.members).map(_mapMemberAvatars);
    cameraUpdate = Observable.merge([
      autoPositionInput,
      _autoPositionEvent,
    ]).where((it) => it).flatMap((_) => _venueCameraObservable);
  }

  final double startZoom = 15.0;
  final bool autoPosInitValue = true;
  final DrinnerApi _drinnerApi;

  Subject<Meeting> meetingInput = BehaviorSubject();
  Subject<MapCamera> cameraChangeInput = BehaviorSubject();
  Subject<bool> autoPositionInput;
  Subject<bool> tappedInput = PublishSubject();

  Observable<List<MeetingDetailsMember>> members;
  Observable<MapCamera> cameraUpdate;

  Observable<bool> get autoPosition => autoPositionInput;

  @override
  void dispose() {
    meetingInput.close();
    autoPositionInput.close();
    cameraChangeInput.close();
    tappedInput.close();
  }

  Observable<bool> get _autoPositionEvent => tappedInput
      .scan((int sum, bool tapped, _) => sum + (tapped ? 1 : -1), 0)
      .debounce(Duration(milliseconds: 500))
      .withLatestFrom(
        autoPositionInput,
        (int counter, bool autoPosition) => counter == 0 && autoPosition,
      );

  Observable<MapCamera> get _venueCameraObservable {
    return Observable.combineLatest2(
      meetingInput,
      cameraChangeInput,
      (Meeting meeting, MapCamera camera) {
        final center = meeting.venue.location;
        return MapCamera(
          lat: center.lat,
          lon: center.lon,
          zoom: camera.zoom,
        );
      },
    ).take(1);
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
