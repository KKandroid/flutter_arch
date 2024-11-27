/// 刷新页面通知
class Event<T> {
  /// 事件类型
  final String key;

  /// 数据
  final T? data;

  const Event({required this.key, this.data});

  /// 事件由来决定 可以相同则代表同一类事件
  @override
  bool operator ==(Object other) {
    if (other is Event) {
      return key == other.key && data == other.data;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return "Event(key:$key,data:$data)";
  }

  const Event.empty({required this.key}) : data = null;

  Event<T> clone(T data) {
    return Event(key: key, data: data);
  }
}