import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:awesome_poll_app/theme/themes.dart';

/// Wrapper class for holding the ThemeData and some other information, that cannot be added to [ThemeData]
class CustomTheme implements Equatable {
  final String name;
  final Map<String, Color> colors;
  /// a list of specific themes for particular widgets or parts of the app. 
  /// They can then be used with help of the [Theme] Widget
  final Map<String, ThemeData> _widgetThemes;
  final ThemeData themeData;
  final AppThemeMode mode;

  CustomTheme({
    required this.name,
    required this.colors,
    required this.themeData,
    required this.mode,
    Map<String, ThemeData>? widgetThemes,
  }) :  assert(true),
        _widgetThemes = widgetThemes ?? {};


  /// Return specific themeData if existent, else return general themeData. 
  ThemeData getWidgetTheme(String name) {
    return _widgetThemes[name] ?? themeData;
  }

  @override
  List<Object?> get props => [name];

  @override
  bool? get stringify => true;

}