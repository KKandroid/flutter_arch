import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../page/page.dart';
import '../page/view_model.dart';
import '../page_state_view.dart';
import 'view_model.dart';

/// 分页加载列表页面
/// 可刷新加载 可添加header footer
abstract class BaseListState<T extends StatefulWidget, D, M extends BaseListModel<D>> extends BasePageState<T, M> {
  @override
  Widget buildSuccessView(BuildContext context, M model) {
    Widget refreshBody = SmartRefresher(
      header: refreshHeader(),
      controller: refreshController,
      enablePullDown: enableRefresh(),
      onRefresh: () => onRefresh(model),
      onLoading: () => onLoadMore(model),
      scrollController: scrollController,
      enablePullUp: model.hasMore,
      footer: PageStateViewManager().builder.refreshFooter(context),
      child: pageState == PageState.empty ? buildEmptyView(context, model) : buildContentView(context, model),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildFixedTop(context, model),
        Expanded(child: refreshBody),
        buildFixedBottom(context, model),
      ],
    );
  }

  @override
  void onLoadMore(M model) {
    model.loadData().then((hasMore) {
      if (hasMore) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
      onLoadMoreComplete(hasMore, model);
    }).catchError((e) {
      refreshController.loadFailed();
    });
  }

  void onLoadMoreComplete(bool hasMore, M model) {}

  @override
  Widget buildContentView(BuildContext context, M model) {
    List<Widget> slivers = [];

    PreferredSize preferredSize = buildFixedHeader(model);

    // 固顶 Header
    var fixedHeader = SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: preferredSize.preferredSize.height,
        maxHeight: preferredSize.preferredSize.height,
        child: preferredSize.child,
      ),
    );

    slivers.add(fixedHeader);
    // 中间 header
    List<Widget> headerList = buildHeaders(model);
    for (var header in headerList) {
      slivers.add(SliverToBoxAdapter(child: header));
    }
    // 吸顶 header
    var stickyHeader = buildStickyHeader(context, model);
    if (stickyHeader != null) {
      slivers.add(stickyHeader);
    }
    Widget sliverList;
    if (itemHeight == null) {
      sliverList = SliverList(
        delegate: SliverChildBuilderDelegate(
          _itemContainer,
          childCount: model.dataListSize,
        ),
      );
    } else {
      sliverList = SliverFixedExtentList(
        itemExtent: itemHeight!,
        delegate: SliverChildBuilderDelegate(
          _itemContainer,
          childCount: model.dataListSize,
        ),
      );
    }
    slivers.add(sliverList);
    List<Widget> footerList = buildFooters(model);
    for (var footer in footerList) {
      slivers.add(SliverToBoxAdapter(child: footer));
    }
    if (!model.hasMore) {
      // 没有更多视图
      slivers.add(SliverToBoxAdapter(child: buildNoMoreView(context, model)));
    }
    return CustomScrollView(controller: scrollController, slivers: slivers);
  }

  // 列表项布局, 一个 Column 布局，包含两个子元素:
  // 一个是 [createIndexedWidget] 创建的真正要展示的内容，
  // 一个是 [divider] 创建的分割列表项的分隔视图。
  Widget _itemContainer(BuildContext context, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: buildListItem(context, index, model.getItem(index), model),
        ),
        if (index != model.dataListSize - 1) buildListDivider(context, index, model.getItem(index), model),
      ],
    );
  }

  SliverPersistentHeader? buildStickyHeader(BuildContext context, M model) => null;

  /// 没有更多视图
  Widget buildNoMoreView(BuildContext context, M model) {
    return PageStateViewManager().builder.noMoreView(context);
  }

  /// 列表最上面的固定 Header 布局，不可跟随列表一起滚动
  PreferredSize buildFixedHeader(M model) => PreferredSize(preferredSize: Size.zero, child: Container());

  /// 创建列表项的 Widget
  Widget buildListItem(BuildContext context, int index, D item, M model);

  /// 列表项之间的分割视图
  Widget buildListDivider(BuildContext context, int index, D item, M model);

  /// 列表 Item 的高度，设置完之后，列表 Item 的高度将会固定，每个 Item 的高度都是这个值，
  /// 这样有助于列表滑动性能，否则在 build item 时系统要计算每个 Item 的高度，
  /// 另外，如果使用了 [FastScroller] ，那么这个高度的设置更为关键，当数据比较多的时候，
  /// 如果不设置这个高度，快速拖动滚动条，列表的流畅度很不好，相反如果设置了高度，则会很流畅。
  double? get itemHeight;

  /// 列表最上面的 Header 布局，可跟随列表一起滚动
  List<Widget> buildHeaders(M model) => [];

  /// 列表最下面的 Footer 布局，可跟随列表一起滚动
  List<Widget> buildFooters(M model) => [];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

/// 固定的 Header
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
