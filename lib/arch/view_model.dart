import 'package:flutter/widgets.dart';

import 'live_data.dart';

/// created by kk
abstract class ViewModel {
  final BuildContext context;

  final LiveData state = LiveData(0);

  ViewModel(this.context);

  void setState() {
    state.setValue(state.getValue() + 1);
  }

  /// 初始化状态
  void init() {
    initState();
    initData();
  }

  /// 状态初始化
  void initState() {}

  /// 加载数据
  void initData();

  /// 释放资源
  void dispose();
}
