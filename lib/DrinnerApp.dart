import 'package:drinner_flutter/bloc/BaseBloc.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/page/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum AppMode { DAY, NIGHT }

class DrinnerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drinner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider<DrinnerBloc>(
        bloc: DrinnerBloc(),
        child: MainPage(),
      ),
    );
  }
}

class DrinnerBloc extends BaseBloc {

  static const DEFAULT_MODE = AppMode.DAY;

  AppMode _currentMode = DEFAULT_MODE;

  final Subject<AppMode> _modeSubject = BehaviorSubject<AppMode>(seedValue: DEFAULT_MODE);

  Observable<AppMode> get appMode => _modeSubject;

  void switchMode() {
    _currentMode = _currentMode == AppMode.DAY ? AppMode.NIGHT : AppMode.DAY;
    _modeSubject.add(_currentMode);
  }

  @override
  void dispose() {
    _modeSubject.close();
  }
}
