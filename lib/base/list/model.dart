import '../page/model.dart';

/// 分页数据
class PagingData<T> {
  /// 当前页数
  int? page;

  /// 每页数量
  int? size;

  /// 总流水数
  int? total;

  /// 总页数
  int? pages;

  /// 数据
  List<T>? data;

  PagingData({
    this.page,
    this.size,
    this.total,
    this.pages,
    this.data,
  });

  PagingData.fromJson(dynamic json, ResultParser<T> parser) {
    page = json['page'];
    size = json['size'];
    total = json['total'];
    pages = json['pages'];
    if (json['data'] != null) {
      data = <T>[];
      json['data'].forEach((v) {
        data?.add(parser(v));
      });
    }
  }
}
