import 'dart:async';

import 'package:flutter/material.dart';

class SafeStreamBuilder<T> extends StreamBuilder<T> {
  const SafeStreamBuilder({
    Key key,
    T initialData,
    Stream<T> stream,
    @required AsyncWidgetBuilder<T> builder,
    this.onNull,
  }) : super(
          key: key,
          initialData: initialData,
          stream: stream,
          builder: builder,
        );

  final Widget onNull;
  Widget get _nullWidget => onNull ?? Container();

  @override
  Widget build(BuildContext context, AsyncSnapshot<T> snapshot) =>
      snapshot.data == null ? _nullWidget : super.build(context, snapshot);
}
