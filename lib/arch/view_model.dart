import 'package:flutter/widgets.dart';

/// created by kangkai
abstract class ViewModel {
  final BuildContext context;

  const ViewModel(this.context);

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
