import 'life_cycle.dart';

/// 可以观测的数据，同时可以感知生命周期
class LiveData<T> {
  Map<Observer<T>, _ObserverWrapper<T>> observers = {};
  static const startVersion = 0;
  int _version = startVersion;

  T _data;

  int activeCount = 0;

  bool changingActiveState = false;

  bool valueDispatching = false;

  bool dispatchInvalidated = false;

  LiveData(T data) : _data = data {
    _version++;
  }

  void setValue(T data) {
    _data = data;
    _version++;
    dispatchingValue(null);
  }

  void considerNotify(_ObserverWrapper<T> observer) {
    if (!observer.active) {
      return;
    }
    if (!observer.shouldBeActive()) {
      observer.activeStateChanged(false);
      return;
    }
    if (observer.lastVersion >= _version) {
      return;
    }
    observer.lastVersion = _version;
    observer.observer.call(_data);
  }

  void listen(Observer<T> observer, {BaseViewState? lifecycleOwner}) {
    if (!observers.containsKey(observer)) {
      if (lifecycleOwner != null) {
        var lifecycle = lifecycleOwner.getLifecycle();
        if (lifecycle.getCurrentState() == LifecycleState.defunct) {
          return;
        }
        var wrapper =
            _LifecycleBoundObserver<T>(this, observer, lifecycleOwner);
        var existing = observers[observer];
        if (existing != null) {
          if (existing.isBoundTo(lifecycleOwner)) {
            throw Exception(
                "Cannot add the same observer with different lifecycles");
          }
          return;
        }
        observers[observer] = wrapper;
        lifecycle.addObserver(wrapper);
      } else {
        var existing = observers[observer];
        if (existing != null) {
          if (existing is _LifecycleBoundObserver) {
            throw Exception(
                "Cannot add the same observer with different lifecycles");
          }
          return;
        }
        var wrapper = _AlwaysActiveObserver<T>(this, observer);
        observers[observer] = wrapper;
        wrapper.activeStateChanged(true);
      }
    }
  }

  T getValue() {
    return _data;
  }

  int getVersion() {
    return _version;
  }

  ///  Called when the number of active observers change from 0 to 1.
  ///
  ///  This callback can be used to know that this LiveData is being used thus should be kept up to date.
  void onActive() {}

  /// Called when the number of active observers change from 1 to 0.
  /// This does not mean that there are no observers left, there may still be observers but their
  /// lifecycle states aren't {@link Lifecycle.State#STARTED} or {@link Lifecycle.State#RESUMED}
  /// (like an Activity in the back stack).
  ///
  /// You can check if there are observers via [hasObservers()].
  void onInactive() {}

  void removeObserver(Observer<T> observer) {
    _ObserverWrapper<T>? removed = observers.remove(observer);
    if (removed == null) {
      return;
    }
    removed.detachObserver();
    removed.activeStateChanged(false);
  }

  void clearObserver() {
    observers.clear();
  }

  void removeObservers(BaseViewState owner) {
    observers.forEach((key, value) {
      if (value.isBoundTo(owner)) {
        removeObserver(key);
      }
    });
  }

  bool hasObservers() {
    return observers.isNotEmpty;
  }

  bool hasActiveObservers() {
    return activeCount > 0;
  }

  void dispatchingValue(_ObserverWrapper<T>? observerWrapper) {
    if (valueDispatching) {
      dispatchInvalidated = true;
      return;
    }
    valueDispatching = true;
    do {
      dispatchInvalidated = false;
      if (observerWrapper != null) {
        considerNotify(observerWrapper);
        observerWrapper = null;
      } else {
        for (var observer in observers.values) {
          considerNotify(observer);
          if (dispatchInvalidated) {
            break;
          }
        }
      }
    } while (dispatchInvalidated);
    valueDispatching = false;
  }

  void changeActiveCounter(int change) {
    int previousActiveCount = activeCount;
    activeCount += change;
    if (changingActiveState) {
      return;
    }
    changingActiveState = true;
    try {
      while (previousActiveCount != activeCount) {
        bool needToCallActive = previousActiveCount == 0 && activeCount > 0;
        bool needToCallInactive = previousActiveCount > 0 && activeCount == 0;
        previousActiveCount = activeCount;
        if (needToCallActive) {
          onActive();
        } else if (needToCallInactive) {
          onInactive();
        }
      }
    } finally {
      changingActiveState = false;
    }
  }
}

/// 定义观察者
typedef Observer<T> = void Function(T t);

/// 观察者包装类,具体实现 [_AlwaysActiveObserver] 和 [_LifecycleBoundObserver]
abstract class _ObserverWrapper<T> {
  final LiveData<T> liveData;
  final Observer<T> observer;
  bool active = true;
  int lastVersion = LiveData.startVersion;

  _ObserverWrapper(this.liveData, this.observer);

  bool shouldBeActive();

  bool isBoundTo(BaseViewState owner) {
    return false;
  }

  void detachObserver() {}

  void activeStateChanged(bool newActive) {
    if (newActive == active) {
      return;
    }
    active = newActive;
    liveData.changeActiveCounter(active ? 1 : -1);
    if (active) {
      liveData.dispatchingValue(this);
    }
  }
}

class _AlwaysActiveObserver<T> extends _ObserverWrapper<T> {
  _AlwaysActiveObserver(LiveData<T> liveData, Observer<T> observer)
      : super(liveData, observer);

  @override
  bool shouldBeActive() => true;
}

class _LifecycleBoundObserver<T> extends _ObserverWrapper<T>
    implements LifecycleObserver {
  final BaseViewState owner;

  _LifecycleBoundObserver(
      LiveData<T> liveData, Observer<T> observer, this.owner)
      : super(liveData, observer);

  @override
  bool isBoundTo(BaseViewState owner) {
    return this.owner == owner;
  }

  @override
  void detachObserver() {
    owner.getLifecycle().removeObserver(this);
  }

  @override
  bool shouldBeActive() {
    return owner.getLifecycle().getCurrentState() == LifecycleState.ready;
  }

  @override
  void onStateChanged(BaseViewState owner, LifecycleEvent event) {
    var lifecycle = owner.getLifecycle();
    LifecycleState currentState = lifecycle.getCurrentState();
    if (currentState == LifecycleState.defunct) {
      liveData.removeObserver(observer);
      return;
    }
    LifecycleState? prevState;
    while (prevState != currentState) {
      prevState = currentState;
      activeStateChanged(shouldBeActive());
      currentState = lifecycle.getCurrentState();
    }
  }
}
