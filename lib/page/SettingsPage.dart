import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/bloc/SettingsBloc.dart';
import 'package:drinner_flutter/common/EditValueDialog.dart';
import 'package:drinner_flutter/common/rx/SafeStreamBuilder.dart';
import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:drinner_flutter/common/view_state/ViewStateWidget.dart';
import 'package:drinner_flutter/model/City.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SettingsPage extends StatefulWidget {
  final _avatarSize = 48.0;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  SettingsBloc _settingsBloc;
  StreamSubscription _saveResultSub;
  StreamSubscription _editNameSub;
  StreamSubscription _editCitySub;
  StreamSubscription _nearestCitySub;
  TextEditingController _cityInputController;

  @override
  void initState() {
    super.initState();
    _settingsBloc = BlocFactory.settingsBloc;
    _saveResultSub = _settingsBloc.userSaveResult.listen(_onSaveResult);
    _editNameSub = _settingsBloc.editNameValue.listen(_showNameDialog);
    _editCitySub = _settingsBloc.editCityData.listen(_showCitiesDialog);
    _nearestCitySub = _settingsBloc.nearestCity.listen(_updateCityDialogInput);
    _cityInputController = TextEditingController()
      ..addListener(_onCityInputChanged);
  }

  @override
  void dispose() {
    _cityInputController.dispose();
    _saveResultSub.cancel();
    _editNameSub.cancel();
    _editCitySub.cancel();
    _nearestCitySub.cancel();
    _settingsBloc.dispose();
    super.dispose();
  }

  void _onSaveResult(bool success) {
    final message = success ? 'User successfuly saved' : 'User save error';
    Scaffold.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(milliseconds: 100)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _settingsBloc,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text('Settings')),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: SafeStreamBuilder(
                stream: _settingsBloc.userAvatar,
                builder: (_, snapshot) => _buildAvatarWidget(snapshot.data),
              ),
            ),
            SafeStreamBuilder(
              stream: _settingsBloc.userName,
              builder: (_, snapshot) => _SettingField(
                    name: 'Name',
                    state: snapshot.data,
                    editAction: _settingsBloc.editNameInput.add,
                  ),
            ),
            SafeStreamBuilder(
              stream: _settingsBloc.userCity,
              builder: (_, snapshot) => _SettingField(
                    name: 'City',
                    state: snapshot.data,
                    editAction: _settingsBloc.editCityInput.add,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(ViewState<SettingsAvatar> state) {
    final isDone = !(state is LoadingState);
    final isRandom = state is LoadingState ||
        (state is DataState<SettingsAvatar> ? state.data.isRandom : false);
    final avatar = ViewStateWidget(
      state: state,
      builder: (_, avatar) => _buildAvatarImage(isDone, avatar.image),
    );
    final icons = _buildAvatarIcons(isDone, isRandom);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons..insert(0, avatar),
    );
  }

  List<Widget> _buildAvatarIcons(bool isDone, bool hasChanged) {
    return [
      hasChanged
          ? _buildAvatarIcon(
              isDone, Icons.done, _settingsBloc.acceptAvatarInput.add)
          : null,
      hasChanged
          ? _buildAvatarIcon(
              isDone, Icons.close, _settingsBloc.rejectAvatarInput.add)
          : null,
      _buildAvatarIcon(isDone, Icons.sync, _settingsBloc.changeAvatarInput.add),
    ]..removeWhere((it) => it == null);
  }

  Widget _buildAvatarIcon(bool isDone, IconData iconData, void onPressed()) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: isDone ? onPressed : null,
    );
  }

  Widget _buildAvatarImage(bool isDone, Uint8List bytes) {
    final size = widget._avatarSize;
    if (!isDone)
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      );
    if (bytes != null)
      return Image.memory(
        bytes,
        width: size,
        height: size,
      );
    return Icon(Icons.error_outline, size: size);
  }

  void _showNameDialog(String currentName) {
    EditValueDialog.show(
      context,
      currentValue: currentName,
      onComplete: (newValue) {
        _settingsBloc.updateNameInput.add(newValue);
        Navigator.pop(context);
      },
    );
  }

  void _showCitiesDialog(
      Observable<ViewState<ViewEditCityData>> citiesObservable) {
    _cityInputController.clear();
    showDialog(
      context: context,
      builder: (_) => Dialog(
            child: SafeStreamBuilder(
              stream: citiesObservable,
              builder: (_, snapshot) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCitiesDialogTextRow(snapshot.data),
                      _buildCitiesDialogList(snapshot.data),
                    ],
                  ),
            ),
          ),
    );
  }

  Widget _buildCitiesDialogTextRow(ViewState<ViewEditCityData> state) {
    final inputEnabled =
        state is DataState<ViewEditCityData> && !state.data.isLocalizing;
    final theme = Theme.of(context);
    return Row(children: [
      Expanded(
        child: TextField(
          style: TextStyle(
            color: inputEnabled ? theme.primaryColor : theme.disabledColor,
          ),
          controller: _cityInputController,
          enabled: inputEnabled,
        ),
      ),
      IconButton(
        icon: Icon(Icons.gps_fixed),
        onPressed: inputEnabled ? _settingsBloc.locateCityInput.add : null,
      ),
    ]);
  }

  Widget _buildCitiesDialogList(ViewState<ViewEditCityData> state) {
    return Flexible(
      child: ViewStateWidget(
        state: state,
        builder: (_, ViewEditCityData cities) => cities.all.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('😞'),
                  Text(
                    'No cities for given query',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: cities.all.length,
                itemBuilder: (_, index) => _buildCitiesDialogListItem(
                    cities.all[index], cities.current),
              ),
      ),
    );
  }

  Widget _buildCitiesDialogListItem(City itemCity, City userCity) {
    final iconSize = 24.0;
    return InkWell(
      onTap: () => _onCitiesDialogItemTap(itemCity),
      child: Row(children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: itemCity.name == userCity.name
              ? Icon(Icons.check, size: iconSize)
              : null,
        ),
        Text(itemCity.name),
      ]),
    );
  }

  void _onCitiesDialogItemTap(City city) {
    Navigator.of(context).pop();
    _settingsBloc.updateCityInput.add(city.name);
  }

  void _updateCityDialogInput(City city) =>
      _cityInputController.value = TextEditingValue(text: city.name);

  void _onCityInputChanged() =>
      _settingsBloc.editCityQueryInput.add(_cityInputController.text);
}

class _SettingField extends StatelessWidget {
  _SettingField({this.name, this.state, this.editAction});

  final String name;
  final ViewState<String> state;
  final GestureTapCallback editAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Text(name, textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 4,
          child: ViewStateWidget(
            state: state,
            builder: (_, data) => Text(
                  data ?? '???',
                  textAlign: TextAlign.center,
                ),
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: state is DataState ? editAction : null,
          ),
        ),
      ]),
    );
  }
}
