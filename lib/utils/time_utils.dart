import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as time_ago;

extension DateUtilsExtension on DateTime {

  DateTime clampTime() => DateTime(year, month, day);

  String get format => DateFormat('dd.MM.yyyy hh:mm').format(this);

  String fuzzyTime({Locale? locale, DateTime? clock}) => time_ago.format(this, locale: locale?.toLanguageTag() ?? 'en', clock: clock);

}

extension TimeUtilsExtension on TimeOfDay {

  int get millisecondsSinceEpoch => Duration(hours: hour, minutes: minute).inMilliseconds;

}
