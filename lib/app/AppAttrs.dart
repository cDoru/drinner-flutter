import 'package:drinner_flutter/app/DrinnerApp.dart';
import 'package:drinner_flutter/bloc/AppBloc.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:flutter/material.dart';

abstract class AppAttrs {
  AppAttrs._();

  factory AppAttrs(AppMode appMode) =>
      appMode == AppMode.DAY ? _LightAttrs() : _DarkAttrs();

  static AppAttrs of(BuildContext context) =>
      BlocProvider.of<AppBloc>(context).appAttrs;

  Brightness get brightness;
  IconData get appModeIconData;
  String get mapboxStyle;
}

class _LightAttrs extends AppAttrs {
  _LightAttrs() : super._();
  
  @override
  Brightness get brightness => Brightness.light;

  @override
  IconData get appModeIconData => Icons.brightness_7;

  @override
  String get mapboxStyle => 'mapbox.light';
}

class _DarkAttrs extends AppAttrs {
  _DarkAttrs() : super._();

  @override
  Brightness get brightness => Brightness.dark;

  @override
  IconData get appModeIconData => Icons.brightness_3;

  @override
  String get mapboxStyle => 'mapbox.dark';
}
