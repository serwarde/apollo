import 'package:awesome_poll_app/utils/commons.dart';

/// Class holding the current App theme, 
/// including the themeData wrapped in a [CustomTheme],
/// the current [AppThemeMode] and a static instance variable 
/// so that the current theme can be globally retrieved
class AppTheme {
  CustomTheme theme = Themes.lightTheme;
  AppThemeMode mode = AppThemeMode.light;
  static final AppTheme _instance = AppTheme();
  static get instance => _instance;
  AppThemeMode getMode() => mode;
}

class AppThemeCubit extends Cubit<CustomTheme> with HydratedMixin {
  AppThemeCubit() : super(Themes.lightTheme);

  /// Sets/changes the current app theme.
  set theme(CustomTheme theme) {
    AppTheme.instance.mode = theme.mode;
    emit(theme);
  }

  /// Returns the current app theme mode
  AppThemeMode get mode => AppTheme.instance.mode;

  /// Return the current [CustomTheme]
  CustomTheme get theme => state;

  /// Restore a CustomTheme from json specifying the [AppThemeMode]
  @override
  CustomTheme? fromJson(Map<String, dynamic> json) {
    var theme = json['theme'];
    var selected;
    if(theme != null && theme is String) {
      selected = Themes.listThemes().firstWhere((e) => e.name == theme);
    }
    if (selected != null) AppTheme.instance.theme = selected;
    return selected;
  }

  /// Write a json object specifying the [AppThemeMode]
  @override
  Map<String, dynamic>? toJson(CustomTheme state) => {
    'theme': state.name,
  };

}