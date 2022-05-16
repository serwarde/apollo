import 'package:awesome_poll_app/services/lang/language.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:json_intl/json_intl.dart';

extension LanguageUtilExtension on BuildContext {

  String lang(String key) {
    try {
      return JsonIntl.of(this).get(key);
    } catch (ex) {
      return key;
    }
  }

  Locale get locale => BlocProvider.of<LocalizationCubit>(this).state;

  String stringifyLocale(Locale locale) => lang('language.${locale.languageCode}');
}