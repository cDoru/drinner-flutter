import 'package:drinner_flutter/common/map/animated_marker/layer.dart';
import 'package:drinner_flutter/common/map/animated_marker/plugin.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/plugin_api.dart';

/// Class that builds items and caches them in map, linked with
/// key object passed in [request] method. It also allows to get
/// list of created items by [collect] method.
abstract class CachingBuilder<K, V> {
  CachingBuilder(
    this._identifier,
    this._absentValue,
  );

  final Map<Object, V> _items = {};
  final Identifier<K, Object> _identifier;
  final V _absentValue;

  /// Maps old items into new ones, so that every consecutive
  /// request for an item relating to [keyObject] will link it
  /// with an item created by previous call.
  /// Every [collect] method call re-initializes this field.
  Map<V, V> _itemCache = Map();

  /// Caches set of new items being created by [request] method.
  /// Every [collect] method call re-initializes this field.
  Set<V> _pendingItems = Set();

  bool _shouldBuild(K key, V previous);
  bool _canReusePending(V pending, K key, V previous);
  V _buildItem(K key, V previous);

  /// Creates an item for given [keyObject] or links the key with
  /// existing item, if another object with the same key requested
  /// an item since last [collect] method call.
  ///  * if new object for [keyObject] is requested, but there's
  ///    already an object in [_itemCache] whose old item matches
  ///    [keyObject]'s old, then this object is reused.
  ///  * if [_shouldBuild] is `true`, method tries to reuse any of
  ///    [_pendingItems]. If none of these is appropriate, brand new
  ///    item is created.
  ///  * otherwise previous item for [keyObject] is put into [_itemCache].
  void request(K keyObject) {
    final key = _identifier(keyObject);
    final oldItem = this[keyObject];
    if (_itemCache.containsKey(oldItem)) {
      _items[key] = _itemCache[oldItem];
    } else if (_shouldBuild(keyObject, oldItem)) {
      final newItem = _pendingItems.firstWhere(
          (it) => _canReusePending(it, keyObject, oldItem),
          orElse: () => _buildItem(keyObject, oldItem));
      _itemCache[oldItem] = newItem;
      _items[key] = newItem;
      _pendingItems.add(newItem);
    } else {
      _itemCache[oldItem] = oldItem;
    }
  }

  /// Returns all items created since previous call of this method
  /// and re-initializes fields, so that every time only latest
  /// items are returned.
  List<V> collect() {
    final items = _pendingItems;
    _pendingItems = Set();
    _itemCache = Map();
    return items.toList();
  }

  /// Returns newest item built for the key of given [keyObject].
  V operator [](K keyObject) =>
      _items.putIfAbsent(_identifier(keyObject), () => _absentValue);
}

class AnimatorCachingBuilder
    extends CachingBuilder<AnimDirectedMarker, AnimationController> {
  AnimatorCachingBuilder(
    this._vsync,
    this._animDuration,
    Identifier<AnimDirectedMarker, Object> identifier,
    AnimationController absentValue,
  ) : super(identifier, absentValue);

  final TickerProvider _vsync;
  final Duration _animDuration;

  @override
  bool _shouldBuild(AnimDirectedMarker key, AnimationController previous) {
    final status = previous.status;
    return key.isForward
        ? status == AnimationStatus.dismissed ||
            status == AnimationStatus.reverse
        : status == AnimationStatus.completed ||
            status == AnimationStatus.forward;
  }

  @override
  bool _canReusePending(AnimationController pending, AnimDirectedMarker key,
          AnimationController previous) =>
      pending.value == previous.value &&
      _isPendingForward(pending) == key.isForward;

  bool _isPendingForward(AnimationController pending) =>
      pending.status == AnimationStatus.dismissed ||
      pending.status == AnimationStatus.forward;

  @override
  AnimationController _buildItem(
      AnimDirectedMarker key, AnimationController previous) {
    final animator = AnimationController(
      duration: _animDuration,
      value: previous?.value ?? key.startValue,
      vsync: _vsync,
    );
    animator.addStatusListener((it) {
      if (it == key.endStatus) animator.dispose();
    });
    return animator;
  }
}

class AnimDirectedMarker {
  AnimDirectedMarker(this.marker, [direction = AnimDirection.UNSPEC])
      : this.isForward = direction == AnimDirection.FORWARD;
  final Marker marker;
  final bool isForward;

  AnimationStatus get endStatus =>
      isForward ? AnimationStatus.completed : AnimationStatus.dismissed;

  double get startValue => isForward ? 0.0 : 1.0;
}
