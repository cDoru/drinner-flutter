import 'package:drinner_flutter/DrinnerApp.dart';
import 'package:flutter/material.dart';

abstract class AppAttrs {
  static AppAttrs _lightAttrs = _LightAttrs();
  static AppAttrs _darkAttrs = _DarkAttrs();

  static AppAttrs ofMode(AppMode appMode) {
    switch (appMode) {
      case AppMode.DAY:
        return _lightAttrs;
      case AppMode.NIGHT:
        return _darkAttrs;
      default:
        throw Exception('AppAttrs requested for unknown AppMode: $appMode.');
    }
  }

  Brightness get brightness;
  IconData get appModeIconData;
}

class _LightAttrs extends AppAttrs {
  @override
  Brightness get brightness => Brightness.light;

  @override
  IconData get appModeIconData => Icons.brightness_7;
}

class _DarkAttrs extends AppAttrs {
  @override
  Brightness get brightness => Brightness.dark;

  @override
  IconData get appModeIconData => Icons.brightness_3;
}
