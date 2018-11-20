import 'dart:async';

import 'package:rxdart/rxdart.dart';

class VoidSubject extends VoidObservable {
  const VoidSubject._(this._subject) : super._(_subject);

  factory VoidSubject.publish() => VoidSubject._(PublishSubject());
  factory VoidSubject.behavior() => VoidSubject._(BehaviorSubject());
  factory VoidSubject.replay() => VoidSubject._(ReplaySubject());

  final Subject<void> _subject;

  void add() => _subject.add(null);
  Future<dynamic> close() => _subject.close();
}

class VoidObservable {
  const VoidObservable._(this._observable);

  final Observable<void> _observable;

  StreamSubscription<void> listen(
    VoidFunc onNext, {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) =>
      _observable.listen(
        (_) => onNext(),
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  static VoidObservable merge(Iterable<VoidSubject> subjects) {
    final merged = Observable.merge(subjects.map((it) => it._observable));
    return VoidObservable._(merged);
  }

  Observable<R> withLatestFrom<S, R>(Stream<S> stream, R fn(void v, S s)) =>
      _observable.withLatestFrom(stream, fn);
  Observable<S> map<S>(S convert()) => _observable.map((_) => convert());
  Observable<S> asyncMap<S>(FutureOr<S> convert()) =>
      _observable.asyncMap((_) => convert());
  Observable<S> flatMap<S>(Stream<S> mapper()) =>
      _observable.flatMap((_) => mapper());
}
