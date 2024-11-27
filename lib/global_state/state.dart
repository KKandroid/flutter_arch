import 'package:flutter_arch/arch/index.dart';

import 'storage.dart';

/// 全局的状态
/// 自带本地缓存
/// 通过 [key] 创建的 [GlobalState] 实例是单例的
/// 通过 [setValue] 方法设置的值会自动保存到本地
/// 通过 [listen] 方法监听数据变化，[lifecycleOwner] 参数不为空时，会在 [BaseViewState] 的 [dispose] 方法中自动移除监听，这里需要注意调用时机需要在 BaseViewState
/// 的 [initState] 方法之后 即 其子类的  [super.initState();]  之后调用。
/// 通过 [removeObserver] [lifecycleOwner] 参数为空时需要使用这主动移除监听。
/// 通过 [value] 获取当前值
class GlobalState<T> {
  static final Map<String, GlobalState<dynamic>> _instances = {};
  final String key;

  GlobalState._(this.key, this._serializer);

  /// 数据流
  late final LiveData<T> _data;

  final Serializer<T>? _serializer;

  factory GlobalState(String key, T defaultValue, {Parser<T>? parser, Serializer<T>? serializer}) {
    // 检查是否已经存在该 key 的实例
    if (_instances.containsKey(key)) {
      return _instances[key]! as GlobalState<T>;
    } else {
      // 创建新的实例并将其存储在映射中
      var localValue = StorageUtil.get<T>(key, parser: parser);
      if (localValue == null) {
        StorageUtil.save<T>(key, defaultValue, serializer: serializer);
      }
      final instance = GlobalState<T>._(key, serializer).._data = LiveData(localValue ?? defaultValue);
      _instances[key] = instance;
      return instance;
    }
  }

  void listen(Observer<T> observer, {BaseViewState? lifecycleOwner}) {
    _data.listen(observer, lifecycleOwner: lifecycleOwner);
  }

  void removeObserver(Observer<T> observer) {
    _data.removeObserver(observer);
  }

  @override
  String toString() => 'GlobalState(key: $key)';

  /// 获取当前值
  T get value => _data.getValue();

  /// 设置新的值
  void setValue(T newData) {
    if (value != newData) {
      _data.setValue(newData);
      StorageUtil.save<T>(key, newData, serializer: _serializer);
    }
  }
}
