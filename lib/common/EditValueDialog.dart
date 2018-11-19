import 'package:drinner_flutter/common/typedefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditValueDialog extends StatefulWidget {
  EditValueDialog._(this._currentValue, this._onComplete);

  static void show(BuildContext context,
      {String currentValue, Callback<String> onComplete}) {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog._(currentValue, onComplete),
    );
  }

  final String _currentValue;
  final Callback<String> _onComplete;

  @override
  _EditValueDialogState createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  TextEditingController _controller;

  VoidCallback get _onEditingDone => _validateName(_controller.text) == null
      ? () => widget._onComplete(_controller.text)
      : null;

  @override
  void initState() {
    super.initState();
    _controller = _createTextController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextEditingController _createTextController() {
    return TextEditingController.fromValue(
      TextEditingValue(
        text: widget._currentValue,
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: widget._currentValue.length,
        ),
      ),
    )..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Put new name'),
            Row(children: [
              Expanded(
                  child: _buildNameFormField(
                controller: _controller,
                onEditingComplete: _onEditingDone,
              )),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: _onEditingDone,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildNameFormField(
      {TextEditingController controller, void onEditingComplete()}) {
    return Material(
      // TODO set color depending on day/night mode
      color: Colors.white,
      child: TextFormField(
        onEditingComplete: onEditingComplete,
        maxLines: 1,
        autofocus: true,
        autovalidate: true,
        validator: _validateName,
        controller: controller,
      ),
    );
  }

  String _validateName(String name) {
    if (name.length < 3) return 'At least 3 chars long.';
    if (name.length > 10) return 'At most 10 chars long.';
    return null;
  }
}
