import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

typedef Parser<T> = T Function(String str);
typedef Serializer<T> = String Function(T data);

/// 本地化存储工具类
class StorageUtil {
  static final List<Type> _supportType = [bool, int, double, String, List<String>];
  static bool _initialized = false;
  static late SharedPreferences _prefs;
  static const storage = FlutterSecureStorage();

  /// 初始化
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// 获取所有本地数据
  static Map<String, dynamic> getLocalData() {
    Map<String, dynamic> locals = {};
    _checkInit();
    var keys = _prefs.getKeys();
    log(keys.toString());
    for (var key in keys) {
      locals.putIfAbsent(key, () => _prefs.get(key));
    }
    log(locals.toString());
    return locals;
  }

  static void _checkInit() {
    if (!_initialized) {
      init();
      throw Exception("StorageUtil not initialized, call StorageUtil.init() first");
    }
  }

  /// 保存 基本类型数据 bool int double String List<String> 以及自定义序列化数据
  /// [key] 键
  /// [value] 值
  /// [serializer] 自定义序列化器
  static Future save<T>(String key, T value, {Serializer<T>? serializer}) async {
    _checkInit();
    assert(_supportType.contains(T) || serializer != null);
    switch (value) {
      case bool _:
        return _prefs.setBool(key, value);
      case int _:
        return _prefs.setInt(key, value);
      case double _:
        return _prefs.setDouble(key, value);
      case String _:
        return _prefs.setString(key, value);
      case List<String> _:
        return _prefs.setStringList(key, value);
      default:
        return _prefs.setString(key, serializer!(value));
    }
  }

  /// 删除本地数据
  static Future<bool> remove(String key) async {
    _checkInit();
    return _prefs.remove(key);
  }

  /// 获取数据
  /// [key] 键
  /// [defaultValue] 默认值
  /// [parser] 自定义解析器
  static T? get<T>(String key, {T? defaultValue, Parser<T>? parser}) {
    _checkInit();
    assert(_supportType.contains(T) || parser != null);
    var v = _prefs.get(key);
    if (v == null) return defaultValue;
    if (v is String && parser != null) {
      return parser(v);
    }
    var object = v as T;
    return object ?? defaultValue;
  }

  /// 获取[List<String>]类型数据
  static List<String> getStringList(String key) {
    _checkInit();
    var v = _prefs.getStringList(key);
    return v ?? [];
  }

  /// 加密存储
  static Future<void> secureSave(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  /// 读取加密存储
  static Future<String?> secureRead(String key, String value) async {
    return await storage.read(key: key);
  }
}
