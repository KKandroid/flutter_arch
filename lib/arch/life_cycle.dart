import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'view_model.dart';

enum LifecycleState {
  /// Lifecycle created
  created,

  /// Lifecycle ready to update UI
  ready,

  /// UI dispose
  defunct
}

enum LifecycleEvent { onInitState, onDispose }

LifecycleEvent? _downFrom(LifecycleState state) {
  switch (state) {
    case LifecycleState.created:
    case LifecycleState.ready:
      return LifecycleEvent.onDispose;
    default:
      return null;
  }
}

LifecycleEvent? _upFrom(LifecycleState state) {
  switch (state) {
    case LifecycleState.created:
      return LifecycleEvent.onInitState;
    default:
      return null;
  }
}

/// Base class
abstract class Lifecycle {
  void addObserver(LifecycleObserver observer);

  void removeObserver(LifecycleObserver observer);

  LifecycleState getCurrentState();
}

class LifecycleRegistry extends Lifecycle {
  LifecycleState _state = LifecycleState.created;

  final BaseViewState lifecycleOwner;

  LifecycleRegistry(this.lifecycleOwner);

  LinkedHashMap<LifecycleObserver, ObserverWithState> observerMap =
      LinkedHashMap();

  final List _parentState = [];

  int _addingObserverCounter = 0;

  /// 是否正在处理生命事件
  bool _handlingEvent = false;

  /// 有新的生命周期事件到来
  bool _newEventOccurred = false;

  @override
  void addObserver(LifecycleObserver observer) {
    LifecycleState initialState = _state == LifecycleState.defunct
        ? LifecycleState.defunct
        : LifecycleState.ready;
    var statefulObserver = ObserverWithState(initialState, observer);
    ObserverWithState? previous = observerMap[observer];
    if (previous != null) {
      return;
    } else {
      observerMap[observer] = statefulObserver;
    }
    bool isReentrancy = _addingObserverCounter != 0 || _handlingEvent;
    LifecycleState targetState = calculateTargetState(observer);
    _addingObserverCounter++;
    while (statefulObserver.state.index < targetState.index &&
        observerMap.containsKey(observer)) {
      _pushParentState(statefulObserver.state);
      final LifecycleEvent? event = _upFrom(statefulObserver.state);
      if (event == null) {
        throw Exception("no event up from ${statefulObserver.state}");
      }
      statefulObserver.dispatchEvent(lifecycleOwner, event);
      _popParentState();
      targetState = calculateTargetState(observer);
    }
    if (isReentrancy) {
      sync();
    }
    _addingObserverCounter--;
  }

  @override
  LifecycleState getCurrentState() {
    return _state;
  }

  void setCurrentState(LifecycleState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    if (_handlingEvent) {
      _newEventOccurred = true;
      return;
    }
    _handlingEvent = true;
    sync();
    _newEventOccurred = false;
  }

  @override
  void removeObserver(LifecycleObserver observer) {
    observerMap.remove(observer);
  }

  /// 同步状态
  void sync() {
    while (!isSynced()) {
      _newEventOccurred = false;
      // no need to check eldest for nullability, because isSynced does it for us.
      LifecycleState? eldestObserverState = getEldestStateObserver()?.state;
      if (_state.index < (eldestObserverState?.index ?? -1)) {
        _backwardPass(lifecycleOwner);
      }
      ObserverWithState? newestStateObserver = getNewestStateObserver();
      if (!_newEventOccurred &&
          newestStateObserver != null &&
          _state.index > newestStateObserver.state.index) {
        _forwardPass(lifecycleOwner);
      }
    }
    _newEventOccurred = false;
  }

  ObserverWithState? getEldestStateObserver() {
    if (observerMap.keys.isEmpty) {
      return null;
    }
    return observerMap[observerMap.keys.first];
  }

  ObserverWithState? getNewestStateObserver() {
    if (observerMap.keys.isEmpty) {
      return null;
    }
    return observerMap[observerMap.keys.last];
  }

  LifecycleState calculateTargetState(LifecycleObserver observer) {
    LifecycleState? siblingState = observerMap[observer]?.state;
    LifecycleState? parentState =
        _parentState.isNotEmpty ? _parentState.last : null;
    return _min(_min(_state, siblingState), parentState);
  }

  void _pushParentState(LifecycleState state) {
    _parentState.add(state);
  }

  void _popParentState() {
    _parentState.removeLast();
  }

  bool isSynced() {
    if (observerMap.isEmpty) {
      return true;
    }
    LifecycleState? eldestObserverState = getEldestStateObserver()?.state;
    LifecycleState? newestObserverState = getNewestStateObserver()?.state;
    return eldestObserverState == newestObserverState &&
        _state == newestObserverState;
  }

  void _forwardPass(BaseViewState lifecycleOwner) {
    if (observerMap.isEmpty) {
      return;
    }
    var keys = observerMap.keys;
    for (LifecycleObserver key in keys) {
      ObserverWithState? observer = observerMap[key];
      if (observer != null) {
        while ((observer.state.index < _state.index && !_newEventOccurred)) {
          _pushParentState(observer.state);
          LifecycleEvent? event = _upFrom(observer.state);
          if (event == null) {
            throw Exception("no event up from ${observer.state}");
          }
          observer.dispatchEvent(lifecycleOwner, event);
          _popParentState();
        }
      }
      if (_newEventOccurred) {
        break;
      }
    }
  }

  void _backwardPass(BaseViewState lifecycleOwner) {
    if (observerMap.isEmpty) {
      return;
    }
    Iterable<LifecycleObserver> keys = observerMap.keys;
    for (int i = keys.length - 1; i >= 0 && !_newEventOccurred; i--) {
      ObserverWithState? observer = observerMap[keys.elementAt(i)];
      if (observer != null) {
        while ((observer.state.index > _state.index && !_newEventOccurred)) {
          LifecycleEvent? event = _downFrom(observer.state);
          if (event == null) {
            throw Exception("no event down from ${observer.state}");
          }
          _pushParentState(_getTargetState(event));
          observer.dispatchEvent(lifecycleOwner, event);
          _popParentState();
        }
      }
    }
  }
}

/// 根据事件类型 获取下一个状态
LifecycleState _getTargetState(LifecycleEvent event) {
  switch (event) {
    case LifecycleEvent.onInitState:
      return LifecycleState.ready;
    case LifecycleEvent.onDispose:
      return LifecycleState.defunct;
    default:
      return LifecycleState.created;
  }
}

/// 用来包装 LifecycleObserver 使其具有自己的状态，通过自己的状态和宿主的状态比对来决定是否响应生命周期事件
class ObserverWithState {
  LifecycleState state;
  LifecycleObserver lifecycleObserver;

  ObserverWithState(this.state, this.lifecycleObserver);

  void dispatchEvent(BaseViewState owner, LifecycleEvent event) {
    LifecycleState newState = _getTargetState(event);
    state = _min(state, newState);
    lifecycleObserver.onStateChanged(owner, event);
    state = newState;
  }
}

LifecycleState _min(LifecycleState state1, LifecycleState? state2) {
  return (state2 != null && state2.index < state1.index) ? state2 : state1;
}

abstract class LifecycleObserver {
  void onStateChanged(BaseViewState owner, LifecycleEvent event);
}

/// 为 State 对象的生命周期委托给 LifecycleOwner。
mixin BaseViewState<T extends StatefulWidget, D extends ViewModel> on State<T> {
  late LifecycleRegistry _lifecycle;

  late D model;

  D createModel();

  LifecycleRegistry getLifecycle() {
    return _lifecycle;
  }

  @mustCallSuper
  @override
  void initState() {
    _lifecycle = LifecycleRegistry(this);
    model = createModel();
    model.init();
    _lifecycle.setCurrentState(LifecycleState.ready);
    super.initState();
  }

  @mustCallSuper
  @override
  void dispose() {
    _lifecycle.setCurrentState(LifecycleState.defunct);
    model.dispose();
    super.dispose();
  }
}
