import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:rxdart/rxdart.dart';

class MainBloc extends BaseBloc {
  static const _NAV_BAR_DEFAULT_INDEX = 0;

  final Subject<int> selectTabEvent =
      BehaviorSubject(seedValue: _NAV_BAR_DEFAULT_INDEX);

  Observable<int> get selectedTab => selectTabEvent;

  @override
  void dispose() {
    selectTabEvent.close();
  }
}
