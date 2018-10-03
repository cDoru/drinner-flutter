typedef V ItemBuilder<K, V>(K key, V previous);
typedef bool BuilderTest<K, V>(K key, V previous);

class CachingBuilder<K, V> {
  CachingBuilder(
    this._itemBuilder,
    this._shouldBuild,
    this._ifAbsent,
  );

  final Map<Object, V> _items = {};
  final ItemBuilder<K, V> _itemBuilder;
  final BuilderTest<K, V> _shouldBuild;
  final V _ifAbsent;

  Map<V, V> _itemCache = {};
  List<V> _pendingItems = [];

  // Creates item for given key or links the key with existing
  // object, if it was created since last `collect` method call.
  void request(K key) {
    final item = this[key];
    if (_itemCache.containsKey(item)) {
      _items[key] = _itemCache[item];
    } else if (_shouldBuild(key, item)) {
      final newItem = _itemBuilder(key, item);
      _itemCache[item] = newItem;
      _items[key] = newItem;
      _pendingItems.add(newItem);
    } else {
      _itemCache[item] = item;
    }
  }

  // Returns all items created since previous call of
  // this method and re-initializes cache collections.
  List<V> collect() {
    final items = _pendingItems;
    _pendingItems = [];
    _itemCache = {};
    return items;
  }

  V operator [](K key) => _items.putIfAbsent(key, () => _ifAbsent);
}
