import 'package:flutter/material.dart';

import 'global_loading.dart';
import 'toast.dart';

class OverlayManager {
  static final OverlayManager _instance = OverlayManager._();

  OverlayManager._();

  factory OverlayManager() => _instance;

  OverlayEntry getGlobalOverlayEntry(Widget child) {
    return OverlayEntry(builder: (context) {
      return Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              const GlobalLoadingView(),
              const Toast(),
            ],
          ));
    });
  }
}
