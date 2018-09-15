import 'package:drinner_flutter/AppAttrs.dart';
import 'package:drinner_flutter/bloc/AppBloc.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/page/MainPage.dart';
import 'package:flutter/material.dart';

enum AppMode { DAY, NIGHT }

class DrinnerApp extends StatelessWidget {
  final _appBloc = AppBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      bloc: _appBloc,
      child: StreamBuilder<AppMode>(
        stream: _appBloc.appMode,
        builder: _buildAppWidget,
      ),
    );
  }

  Widget _buildAppWidget(
      BuildContext context, AsyncSnapshot<AppMode> snapshot) {
    if (snapshot.data == null) return Container();
    return MaterialApp(
      title: 'Drinner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: AppAttrs.ofMode(snapshot.data).brightness,
        primarySwatch: Colors.green,
      ),
      home: MainPage(),
    );
  }
}
