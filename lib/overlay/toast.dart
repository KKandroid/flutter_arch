import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_arch/arch/index.dart';
import 'package:flutter_arch/even_bus/index.dart';
import 'package:flutter_arch/overlay/auto_disappear.dart';

class Toast extends StatefulWidget {
  static const eventKey = "Toast";

  static void show({String? message, Widget? messageView}) {
    assert(message != null || messageView != null, 'message or messageView must not be null');
    if (messageView != null) {
      EventBus.sendEvent(Event<Widget>(key: eventKey, data: messageView));
    } else {
      log("Toast:: show: $message");
      EventBus.sendEvent(Event<Widget>(key: eventKey, data: DefaultMessageView(message!)));
    }
  }

  const Toast({super.key});

  @override
  ToastState createState() => ToastState();
}

class ToastState extends State<Toast> with BaseViewState<Toast, ToastViewModel> {
  @override
  void initState() {
    super.initState();
    EventBus.listen<Widget>(
      events: [const Event.empty(key: Toast.eventKey)],
      baseView: this,
      listener: model.onEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: model.messages,
          )),
    );
  }

  @override
  ToastViewModel createModel() => ToastViewModel(context);
}

class ToastViewModel extends ViewModel {
  ToastViewModel(super.context);

  List<AutoDisappearWidget> messages = [];

  @override
  void initData() {}

  void onEvent(Widget message) {
    log("ToastViewModel:: onEvent: $message");
    AutoDisappearWidget widget = AutoDisappearWidget(
      key: UniqueKey(),
      child: message,
      onDisappear: () {
        messages.removeWhere((element) => element.child == message);
        setState();
      },
    );
    messages.insert(0, widget);
    setState();
  }

  @override
  void dispose() {}
}

class DefaultMessageView extends StatelessWidget {
  final String message;

  const DefaultMessageView(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(message, style: const TextStyle(fontSize: 12, color: Colors.white, overflow: TextOverflow.visible)),
    );
  }
}
