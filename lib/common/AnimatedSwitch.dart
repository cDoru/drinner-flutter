import 'package:drinner_flutter/common/typedefs.dart';
import 'package:flutter/material.dart';

class AnimatedSwitch extends StatefulWidget {
  AnimatedSwitch({@required this.text, this.onChanged, this.initValue = true});

  final String text;
  final Callback<bool> onChanged;
  final bool initValue;

  @override
  _AnimatedSwitchState createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  bool _enabled;
  AnimationController _animator;
  Animation<Color> _switchColor;
  Animation<Color> _textColor;
  Animation<double> _circleEnabledSize;
  Animation<double> _circleDisabledSize;

  final Color _startColor = Colors.white;
  final Color _endColor = Colors.blue;
  final Curve _startCurve = Curves.easeOut;
  final Curve _endCurve = Curves.easeIn;

  @override
  void initState() {
    super.initState();
    _enabled = true;
    _animator = _createAnimator();
    _switchColor = _createSwitchColorAnim();
    _textColor = _createTextColorAnim();
    _circleEnabledSize = _createEnabledSizeAnim();
    _circleDisabledSize = _createDisabledSizeAnim();
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  AnimationController _createAnimator() {
    return AnimationController(
      vsync: this,
      value: 1.0,
      duration: Duration(milliseconds: 300),
    )..addListener(() => setState(() {}));
  }

  Animation<Color> _createSwitchColorAnim() {
    return ColorTween(
      begin: _startColor,
      end: _endColor,
    ).animate(CurvedAnimation(
      curve: _startCurve,
      reverseCurve: _endCurve,
      parent: _animator,
    ));
  }

  Animation<Color> _createTextColorAnim() {
    return ColorTween(
      begin: _endColor,
      end: _startColor,
    ).animate(CurvedAnimation(
      curve: _endCurve,
      reverseCurve: _startCurve,
      parent: _animator,
    ));
  }

  Animation<double> _createEnabledSizeAnim() =>
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animator,
        curve: Curves.elasticOut,
      ));

  Animation<double> _createDisabledSizeAnim() =>
      Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animator,
        curve: Curves.elasticIn,
      ));

  void _onSwitchTap() {
    setState(() {
      _enabled = !_enabled;
      _enabled ? _animator.forward() : _animator.reverse();
      _circleEnabledSize = _createEnabledSizeAnim();
    });
    widget.onChanged?.call(_enabled);
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: _onSwitchTap,
      color: _switchColor.value,
      textColor: _textColor.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEnabledIcon(),
          _buildSwitchText(),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  Widget _buildEnabledIcon() {
    return Container(
      width: 24.0,
      height: 24.0,
      child: ScaleTransition(
        scale: _enabled ? _circleEnabledSize : _circleDisabledSize,
        child: Container(
          decoration: BoxDecoration(
            color: _enabled ? _startColor : _endColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _enabled ? Icons.done : Icons.clear,
            color: _switchColor.value,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchText() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(widget.text),
      ),
    );
  }
}
