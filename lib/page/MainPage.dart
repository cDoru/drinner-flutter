import 'package:drinner_flutter/bloc/AppBloc.dart';
import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/bloc/MainBloc.dart';
import 'package:drinner_flutter/common/rx/SafeStreamBuilder.dart';
import 'package:drinner_flutter/page/PageFactory.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final List<Widget> _bodyItems = [
    PageFactory.homePage,
    PageFactory.meetingsPage,
    PageFactory.venuesPage,
    PageFactory.settingsPage,
  ];

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainBloc _mainBloc = BlocFactory.mainBloc;
  AppBloc _appBloc;

  @override
  void didChangeDependencies() {
    _appBloc ??= BlocProvider.of<AppBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainBloc>(
      bloc: _mainBloc,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(_appBloc.appAttrs.appModeIconData),
              onPressed: _appBloc.switchModeEvent.add,
            ),
          ],
        ),
        body: SafeStreamBuilder(
          stream: _mainBloc.selectedTab,
          builder: _buildBody,
        ),
        bottomNavigationBar: SafeStreamBuilder(
          stream: _mainBloc.selectedTab,
          builder: _buildNavBar,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<int> snapshot) =>
      widget._bodyItems[snapshot.data];

  Widget _buildNavBar(BuildContext context, AsyncSnapshot<int> snapshot) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: snapshot.data,
      items: _navBarItems,
      onTap: _mainBloc.selectTabEvent.add,
    );
  }

  List<BottomNavigationBarItem> get _navBarItems => [
        _buildNavBarItem(Icons.home, 'Home'),
        _buildNavBarItem(Icons.fastfood, 'Meetings'),
        _buildNavBarItem(Icons.map, 'Venues'),
        _buildNavBarItem(Icons.person, 'Settings'),
      ];

  BottomNavigationBarItem _buildNavBarItem(IconData iconData, String title) {
    return BottomNavigationBarItem(
      icon: Icon(iconData),
      title: Text(title),
    );
  }
}
