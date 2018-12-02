import 'package:drinner_flutter/common/view_state/ViewState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Widget DataStateBuilder<T>(BuildContext context, T data);

class ViewStateWidget<T> extends StatelessWidget {
  ViewStateWidget({@required this.state, @required this.builder});

  final ViewState<T> state;
  final DataStateBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    if (state is LoadingState) return _buildLoadingIndicator();
    if (state is DataState<T>)
      return builder(context, (state as DataState<T>).data);
    if (state is ErrorState) return Text('error');
    return null;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(),
    );
  }
}
