import 'package:flutter/material.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._();

  AppConfig._();

  factory AppConfig() {
    return _instance;
  }

  Color seedColor = Colors.blue;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext get context => navigatorKey.currentContext!;

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  ThemeData get themeData => Theme.of(context);

  ColorScheme get colorScheme => themeData.colorScheme;

  Brightness get brightness => themeData.brightness;

}
