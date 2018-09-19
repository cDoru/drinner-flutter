import 'package:drinner_flutter/app/AppAttrs.dart';
import 'package:drinner_flutter/bloc/AppBloc.dart';
import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/common/SafeStreamBuilder.dart';
import 'package:drinner_flutter/page/PageFactory.dart';
import 'package:flutter/material.dart';

enum AppMode { DAY, NIGHT }

class DrinnerApp extends StatelessWidget {
  DrinnerApp._(this._appBloc);

  factory DrinnerApp.create() => DrinnerApp._(BlocFactory.appBloc);

  final AppBloc _appBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      bloc: _appBloc,
      child: SafeStreamBuilder(
        stream: _appBloc.appMode,
        builder: _buildAppWidget,
      ),
    );
  }

  Widget _buildAppWidget(
      BuildContext context, AsyncSnapshot<AppMode> snapshot) {
    return MaterialApp(
      title: 'Drinner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: AppAttrs.of(context).brightness,
        primarySwatch: Colors.green,
      ),
      home: PageFactory.mainPage,
    );
  }
}
