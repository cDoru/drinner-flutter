import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:drinner_flutter/data/api/DrinnerApi.dart';
import 'package:drinner_flutter/model/Meeting.dart';
import 'package:rxdart/rxdart.dart';

class MeetingsBloc extends BaseBloc {
  MeetingsBloc(this._drinnerApi);

  final DrinnerApi _drinnerApi;

  Observable<ViewState<List<Meeting>>> get userMeetings =>
      Observable.fromFuture(_drinnerApi.getMeetings())
          .doOnData(
              (it) => it.sort((m1, m2) => m2.dateTime.compareTo(m1.dateTime)))
          .map(DataState.create)
          .cast<ViewState<List<Meeting>>>()
          .startWith(LoadingState());

  @override
  void dispose() {}
}
