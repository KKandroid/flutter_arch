import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PageStateViewManager {
  static final PageStateViewManager _instance = PageStateViewManager._();

  PageStateViewManager._();

  factory PageStateViewManager() {
    return _instance;
  }

  RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  BaseViewBuilder builder = DefaultPageView();
}

abstract interface class BaseViewBuilder {
  /// 加载视图
  Widget loadingView(BuildContext context);

  /// 错误视图
  Widget errorView(BuildContext context, String message, VoidCallback retry);

  /// 无数据视图
  Widget emptyView(BuildContext context);

  /// 下拉刷新加载视图
  Widget refreshHeader(BuildContext context);

  /// 上拉加载更多视图
  Widget refreshFooter(BuildContext context);

  Widget noMoreView(BuildContext context);
}

class DefaultPageView extends BaseViewBuilder {
  @override
  Widget emptyView(BuildContext context) {
    return const Center(
      child: Text("暂无数据"),
    );
  }

  @override
  Widget errorView(BuildContext context, String message, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text(message), TextButton(onPressed: retry, child: const Text("重试"))],
      ),
    );
  }

  @override
  Widget loadingView(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget refreshFooter(BuildContext context) {
    return const ClassicFooter();
  }

  @override
  Widget refreshHeader(BuildContext context) {
    return const ClassicHeader();
  }

  @override
  Widget noMoreView(BuildContext context) {
    return const SizedBox(height: 60, child: Center(child: Text("没有更多数据了")));
  }
}
