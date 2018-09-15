import 'dart:async';

import 'package:rxdart/rxdart.dart';

class VoidSubject {
  VoidSubject._(this._subjectDelegate);

  factory VoidSubject.publish() => VoidSubject._(PublishSubject());
  factory VoidSubject.behavior() => VoidSubject._(BehaviorSubject());
  factory VoidSubject.replay() => VoidSubject._(ReplaySubject());

  Subject<void> _subjectDelegate;

  void add() => _subjectDelegate.add(null);

  StreamSubscription<void> listen(Function onNext,
          {Function onError, void onDone(), bool cancelOnError}) =>
      _subjectDelegate.listen(
        (_) => onNext(),
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  Future<dynamic> close() => _subjectDelegate.close();
}
