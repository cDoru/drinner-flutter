import 'dart:async';
import 'dart:typed_data';

import 'package:drinner_flutter/bloc/BlocFactory.dart';
import 'package:drinner_flutter/bloc/BlocProvider.dart';
import 'package:drinner_flutter/bloc/SettingsBloc.dart';
import 'package:drinner_flutter/common/EditValueDialog.dart';
import 'package:drinner_flutter/common/SafeStreamBuilder.dart';
import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:drinner_flutter/common/view_state/ViewStateWidget.dart';
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

  @override
  void initState() {
    super.initState();
    _settingsBloc = BlocFactory.settingsBloc;
    _saveResultSub = _settingsBloc.userSaveResult.listen(_onSaveResult);
  }

  @override
  void dispose() {
    _saveResultSub.cancel();
    _settingsBloc.dispose();
    super.dispose();
  }

  void _onSaveResult(bool success) {
    final message = success ? 'User successfuly saved' : 'User save error';
    Scaffold.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                    editAction: _showNameDialog,
                  ),
            ),
            SafeStreamBuilder(
              stream: _settingsBloc.userCity,
              builder: (_, snapshot) => _SettingField(
                    name: 'City',
                    state: snapshot.data,
                    editAction: _showCityDialog,
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
    final avatar = ViewStateWidget(state,
        builder: (_, avatar) => _buildAvatarImage(isDone, avatar.image));
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

  void _showNameDialog() => _settingsBloc.latestUser
      .then((it) => _showEditDialog(it.name, _settingsBloc.updateNameInput));

  void _showCityDialog() => _settingsBloc.latestUser
      .then((it) => _showEditDialog(it.city, _settingsBloc.updateCityInput));

  void _showEditDialog(String currentValue, Subject<String> updateBlocInput) {
    EditValueDialog.show(
      context,
      currentValue: currentValue,
      onComplete: (newValue) {
        updateBlocInput.add(newValue);
        Navigator.pop(context);
      },
    );
  }
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
          child: ViewStateWidget(state,
              builder: (_, data) => Text(
                    data ?? '???',
                    textAlign: TextAlign.center,
                  )),
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
