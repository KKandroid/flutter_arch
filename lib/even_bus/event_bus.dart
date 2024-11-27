import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_arch/arch/index.dart';

import 'model.dart';

/// 事件总线
class EventBus {
  /// 可观测数据
  static final Map<String, LiveData<Event>> _eventBus = {};

  /// 监听事件
  /// [baseView] 生命周期组件
  /// [events] 要监听的事件
  /// [listener] 回调函数
  static void listen<T>({required List<Event<T>> events, required BaseViewState baseView, ValueChanged<T>? listener}) {
    for (var event in events) {
      if (!_eventBus.containsKey(event.key)) {
        _eventBus.putIfAbsent(event.key, () => LiveData<Event<T>>(Event.empty(key: event.key)));
      }
      _eventBus[event.key]!.listen((t) {
        if (events.map((e) => e.key).contains(t.key)) {
          listener?.call(t.data);
        }
      }, lifecycleOwner: baseView);
    }
  }

  static T? getLatestData<T>(Event<T> event) {
    return _eventBus[event.key]?.getValue().data;
  }

  /// 发送事件
  /// [event]事件
  static void sendEvent<T>(Event<T> event) {
    log("EventBus sendEvent:$event");
    if (!_eventBus.containsKey(event.key)) {
      _eventBus.putIfAbsent(event.key, () => LiveData<Event<T>>(Event.empty(key: event.key)));
    }
    _eventBus[event.key]!.setValue(event);
  }
}
