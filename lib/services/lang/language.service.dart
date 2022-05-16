import 'package:awesome_poll_app/utils/commons.dart';

class LocalizationCubit extends Cubit<Locale> with HydratedMixin {
  LocalizationCubit([Locale? initialState]) : super(initialState ?? const Locale('en'));
  changeLocale(Locale locale) => emit(locale);
  List<Locale> listLocales() => const [Locale('en'), Locale('de')];

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    var locale = json['locale'];
    if(locale != null && locale is String) {
      return listLocales().firstWhere((e) => e.languageCode == locale);
    }
  }

  @override
  Map<String, dynamic>? toJson(Locale state) => {
    'locale': state.languageCode,
  };
}