import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_arch/arch/index.dart';
import 'package:flutter_arch/even_bus/index.dart';

class GlobalLoadingView extends StatefulWidget {
  static const eventKey = "GlobalLoading";

  static void show([String? message]) {
    log("GlobalLoading:: show: $message");
    EventBus.sendEvent(Event(key: eventKey, data: LoadingMsg.show(message ?? '加载中...')));
  }

  static void dismiss() {
    log("GlobalLoading:: dismiss");
    EventBus.sendEvent(const Event(key: eventKey, data: LoadingMsg.dismiss()));
  }

  const GlobalLoadingView({super.key});

  @override
  GlobalLoadingViewState createState() => GlobalLoadingViewState();
}

class GlobalLoadingViewState extends State<GlobalLoadingView> with BaseViewState<GlobalLoadingView, LoadingViewModel> {
  @override
  void initState() {
    super.initState();
    EventBus.listen<LoadingMsg>(
      events: [const Event.empty(key: GlobalLoadingView.eventKey)],
      baseView: this,
      listener: model.onEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: model.visible,
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(model.message, style: const TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoadingViewModel createModel() => LoadingViewModel(context);
}

class LoadingViewModel extends ViewModel {
  LoadingViewModel(super.context);

  late bool visible;

  late String message;

  @override
  void initData() {
    visible = false;
    message = '';
  }

  void onEvent(LoadingMsg event) {
    if (event.type == LoadingMsg.typeShow) {
      show(event.message);
    } else {
      dismiss();
    }
  }

  Timer? _dismissTimer;

  void show(String message) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    this.message = message;
    visible = true;
    setState();
  }

  void dismiss() {
    _dismissTimer = Timer(const Duration(milliseconds: 50), () {
      visible = false;
      setState();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
  }
}

class LoadingMsg {
  static const typeShow = 1;
  static const typeDismiss = 0;
  final String message;
  final int type;

  const LoadingMsg(this.type, {this.message = '加载中...'});

  const LoadingMsg.show(this.message) : type = typeShow;

  const LoadingMsg.dismiss()
      : type = typeDismiss,
        message = '';
}

/// 执行异步任务 伴随loading
/// [message] loading的提示文案。 默认为 ['加载中'.intl()]
extension FutureExt<T> on Future<T> {
  Future<T> withLoading([String? message, Duration timeout = const Duration(minutes: 5)]) async {
    GlobalLoadingView.show(message);
    try {
      T result = await this.timeout(timeout);
      GlobalLoadingView.dismiss();
      return result;
    } catch (e) {
      GlobalLoadingView.dismiss();
      rethrow;
    }
  }
}
