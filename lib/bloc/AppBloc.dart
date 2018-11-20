import 'package:drinner_flutter/app/AppAttrs.dart';
import 'package:drinner_flutter/app/DrinnerApp.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/rx/VoidSubject.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc extends BaseBloc {
  AppBloc() {
    switchModeEvent = VoidSubject.publish()..listen(_switchAppMode);
    appMode.listen(_updateAttrs);
  }

  static const _DEFAULT_MODE = AppMode.DAY;

  AppMode _currentMode = _DEFAULT_MODE;

  final Subject<AppMode> _modeSubject =
      BehaviorSubject<AppMode>(seedValue: _DEFAULT_MODE);

  Observable<AppMode> get appMode => _modeSubject;

  VoidSubject switchModeEvent;

  AppAttrs appAttrs;

  void _switchAppMode() {
    _currentMode = _currentMode == AppMode.DAY ? AppMode.NIGHT : AppMode.DAY;
    _modeSubject.add(_currentMode);
  }

  void _updateAttrs(AppMode appMode) => appAttrs = AppAttrs(appMode);

  @override
  void dispose() {
    _modeSubject.close();
  }
}
