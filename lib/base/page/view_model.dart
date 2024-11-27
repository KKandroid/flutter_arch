import 'dart:convert';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_arch/arch/index.dart';
import 'dart:developer';
import 'model.dart';

/// 页面数据状态
enum PageState {
  // 初始状态
  created,
  // 数据加载中
  loading,
  // 加载成功
  success,
  // 获取数据出错
  error,
  // 没有数据
  empty
}

abstract class BasePageModel extends ViewModel {
  final RefreshController refreshController = RefreshController();

  LiveData<PageState> pageState = LiveData(PageState.loading);

  BasePageModel(super.context);

  /// 数初始化页面数据  刷新页面调用[refreshData]
  @override
  Future initData();

  /// 请求数据成功 更新UI
  void onSuccess() {
    pageState.setValue(PageState.success);
    setState();
  }

  /// 刷新数据  会重置加载状态
  Future refreshData([bool needLoading = false]) async {
    if (needLoading) loading();
    await initData().then((_) {
      refreshController.refreshCompleted();
      // 重置加载状态
      refreshController.loadComplete();
    }).catchError((e, trace) {
      refreshController.refreshFailed();
      // 重置加载状态
      refreshController.loadComplete();
      log("RefreshData Error", error: e, stackTrace: trace);
    });
  }

  String? get errorMessage => errorResponse?.message;

  int? get errorCode => errorResponse?.code;

  String get errorMessageWithCode => '$errorMessage:$errorCode';

  /// 没有数据 更新UI
  void onEmpty() {
    pageState.setValue(PageState.empty);
  }

  /// 显示loading
  void loading() {
    pageState.setValue(PageState.loading);
  }

  ResponseData? errorResponse;

  /// 出错 更新UI
  void onError({required ResponseData responseData}) {
    errorResponse = responseData;
    pageState.setValue(PageState.error);
  }

  bool get enableLoadMore => false;

  Future<bool> loadMoreData() async {
    return false;
  }

  @override
  void dispose() {
    refreshController.dispose();
  }
}

/// 页面无需数据处理的逻辑时 使用[SimplePageModel] 即可
class SimplePageModel extends BasePageModel {
  SimplePageModel(super.context);

  @override
  Future initData() async {
    onSuccess();
  }
}

/// 参数解析
extension ParamsParser on Map<String, String> {
  String getStr(String key, {String defaultValue = ''}) {
    // 返回指定 key 的值，若为空或转换失败则返回默认值
    return this[key] ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    // 尝试将值转换为 int 类型
    return int.tryParse(this[key] ?? '') ?? defaultValue;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    // 尝试将值转换为 double 类型
    return double.tryParse(this[key] ?? '') ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    // 将字符串 "true" 转换为 true，其他情况为 false
    final value = this[key]?.toLowerCase();
    if (value == 'true') return true;
    if (value == 'false') return false;
    return defaultValue;
  }

  List<T> getList<T>(String key, {List<T> defaultValue = const []}) {
    // 尝试将 JSON 字符串解析为 List
    final value = this[key];
    if (value != null) {
      try {
        final list = List<T>.from(jsonDecode(value));
        return list;
      } catch (e) {
        // 解析失败，返回默认值
        log('Error parsing List:', error: e);
      }
    }
    return defaultValue;
  }

  Map<String, T> getMap<T>(String key, {Map<String, T> defaultValue = const {}}) {
    // 尝试将 JSON 字符串解析为 Map
    final value = this[key];
    if (value != null) {
      try {
        final map = Map<String, T>.from(jsonDecode(value));
        return map;
      } catch (e) {
        // 解析失败，返回默认值
        log('Error parsing Map:', error: e);
      }
    }
    return defaultValue;
  }
}
