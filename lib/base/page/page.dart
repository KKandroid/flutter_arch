import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/arch/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../page_state_view.dart';
import 'view_model.dart';

/// 页面构建
typedef PageBuilder = BasePage Function(BuildContext context);

abstract class BasePage extends StatefulWidget {
  final Map<String, String> params;

  const BasePage({this.params = const {}, super.key});

  @override
  State<BasePage> createState();
}

/// 可刷新的页面
abstract class BasePageState<T extends StatefulWidget, M extends BasePageModel> extends State<T>
    with BaseViewState<T, M>, AutomaticKeepAliveClientMixin, RouteAware, WidgetsBindingObserver {
  /// 页面状态
  PageState? pageState;

  /// 页面进入back stack中，仍然存活但不可见
  late bool isPagePause;

  /// 下拉刷新控制器
  late RefreshController refreshController;

  /// ListView 滚动控制器
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    refreshController = model.refreshController;
    pageState = model.pageState.getValue();
    model.pageState.listen((state) => setState(() => pageState = state), lifecycleOwner: this);
    WidgetsBinding.instance.addObserver(this);
    isPagePause = false;
  }

  @override
  @mustCallSuper
  void didPushNext() {
    isPagePause = true;
  }

  @override
  @mustCallSuper
  void didPopNext() {
    isPagePause = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageStateViewManager().routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  bool _keyboardShow = false;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // 确保在回调执行时组件仍然挂载
      if (isPagePause) return;
      var queryData = MediaQuery.maybeOf(context);
      if (queryData == null) return;
      if (queryData.viewInsets.bottom == 0 && _keyboardShow) {
        //关闭键盘
        _keyboardShow = false;
        onKeyboardHide();
      } else if (queryData.viewInsets.bottom > 0 && !_keyboardShow) {
        //显示键盘
        _keyboardShow = true;
        onKeyboardShow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: pageBgColor(),
      body: buildBody(context),
      extendBodyBehindAppBar: extendBodyBehindAppBar(),
    );
  }

  Widget buildBody(BuildContext context) {
    switch (pageState) {
      case PageState.loading:
        return buildLoadingView(context, model);
      case PageState.error:
        return buildErrorView(context, model);
      default:
        return buildSuccessView(context, model);
    }
  }

  Widget buildSuccessView(BuildContext context, M model) {
    Widget refreshBody = SmartRefresher(
      header: refreshHeader(),
      controller: refreshController,
      enablePullDown: enableRefresh(),
      onRefresh: () => onRefresh(model),
      onLoading: () => onLoadMore(model),
      scrollController: scrollController,
      enablePullUp: model.enableLoadMore,
      footer: PageStateViewManager().builder.refreshFooter(context),
      child: pageState == PageState.empty ? buildEmptyView(context, model) : buildContentView(context, model),
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildFixedTop(context, model),
          Expanded(child: refreshBody),
          buildFixedBottom(context, model),
        ],
      ),
    );
  }

  void onLoadMore(M model) {
    model.loadMoreData().then((hasMore) {
      if (hasMore) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    }).catchError((e) {
      refreshController.loadFailed();
    });
  }

  /// 固定底部的视图 不受刷新影响
  Widget buildFixedBottom(BuildContext context, M model) => Container();

  /// 固定顶部的视图 不受刷新影响
  Widget buildFixedTop(BuildContext context, M model) => Container();

  Widget refreshHeader() => PageStateViewManager().builder.refreshHeader(context);

  void onRefresh(M model) {
    model.refreshData();
  }

  /// 是否支持刷新
  bool enableRefresh() => false;

  /// 数据为空的界面，自定义请覆写
  Widget buildEmptyView(BuildContext context, M model) => PageStateViewManager().builder.emptyView(context);

  /// 加载视图，自定义请覆写
  Widget buildLoadingView(BuildContext context, M model) => PageStateViewManager().builder.loadingView(context);

  /// 请求数据错误，自定义请覆写
  Widget buildErrorView(BuildContext context, M model) {
    var message = model.errorMessage ?? '';
    void retry() => model.refreshData(true);
    return PageStateViewManager().builder.errorView(context, message, retry);
  }

  /// 页面的背景颜色
  Color pageBgColor() => Colors.white;

  /// AppBar
  PreferredSizeWidget buildAppBar();

  /// body 延伸到 AppBar下面
  bool extendBodyBehindAppBar() => false;

  /// 绘制页面内容
  Widget buildContentView(BuildContext context, M model);

  /// 切换到后台需要保持状态否？（page View 切换的时候是否会销毁重建）
  @override
  bool get wantKeepAlive => false;

  @override
  void dispose() {
    PageStateViewManager().routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onKeyboardHide() {}

  void onKeyboardShow() {}
}
