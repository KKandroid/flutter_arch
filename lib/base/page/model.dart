typedef ResultParser<T> = T Function(dynamic json);

class ResponseData<T> {
  String message;
  int code;
  T? result;

  ResponseData({
    required this.message,
    required this.code,
    this.result,
  });

  bool get success => code == 200;
}
