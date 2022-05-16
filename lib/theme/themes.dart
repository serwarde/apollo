import 'package:awesome_poll_app/utils/commons.dart';

export 'package:awesome_poll_app/theme/app_theme.dart';
export 'package:awesome_poll_app/theme/custom_theme.dart';

/// The names of all modes our app provides. Each one has a corresponding [ThemeData] defined in [Themes]
enum AppThemeMode {
  light,
  dark,
}

/// A class holding all [CustomTheme] objects each containing a [ThemeData] object 
/// of all supported modes and additional colors as static fields.
class Themes {
  static final ThemeData themeDark = ThemeData.dark();
  static final ThemeData themeLight = ThemeData.light();

  static const Color darkBlue = Color(0xff1D3557);
  static const Color yellow = Color(0xffFCBF49);
  static const Color green = Color(0xff2A9D8F);

  static CustomTheme darkTheme = CustomTheme(
    name: "dark",
    mode: AppThemeMode.dark,
    colors: {
      "darkBlue": darkBlue,
      "yellow": yellow,
      "green": green,
      "inputTextColor": Colors.black,
    },
    themeData: themeDark.copyWith(
      // general colors
      colorScheme: themeDark.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: yellow,
        secondary: green,
        background: darkBlue,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onBackground: yellow,
      ),
      // specific widgets
      scaffoldBackgroundColor: darkBlue,
      cardColor: Colors.white.withOpacity(0.15),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        colorScheme: themeLight.colorScheme,
        buttonColor: yellow,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: darkBlue,
        border: OutlineInputBorder(),
        hintStyle: TextStyle(color: Colors.black),
      ),
      toggleButtonsTheme: const ToggleButtonsThemeData(
        selectedColor: darkBlue,
        disabledColor: darkBlue,
        fillColor: yellow,
        disabledBorderColor: darkBlue,
        selectedBorderColor: yellow,
      ),
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white),
        // button: TextStyle(color: Colors.white),
        caption: TextStyle(color: yellow),
        subtitle1: TextStyle(color: Colors.white),
        // Input field
        headline1: TextStyle(color: Colors.white),
        headline2: TextStyle(color: Colors.white),
        headline3: TextStyle(color: Colors.white),
        headline4: TextStyle(color: Colors.white),
        headline5: TextStyle(color: Colors.white),
        headline6: TextStyle(color: Colors.white),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        primaryColor: green,
        secondaryColor: yellow,
        labelStyle: const TextStyle(),
      ),
    ),
  );

  static ThemeData lightThemeData = themeLight.copyWith(
    // general colors
    colorScheme: themeLight.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: yellow,
      secondary: green,
      background: Colors.white,
      onPrimary: darkBlue,
      onSecondary: Colors.white,
      onBackground: darkBlue,
    ),

    // specific widgets

    // scaffoldBackgroundColor: darkBlue,
    appBarTheme: const AppBarTheme(
        color: darkBlue, titleTextStyle: TextStyle(color: Colors.white), iconTheme: IconThemeData(color: Colors.white)),
    inputDecorationTheme: const InputDecorationTheme(
        filled: true, fillColor: Colors.white, border: OutlineInputBorder(), hintStyle: TextStyle(color: Colors.black)),
    toggleButtonsTheme: const ToggleButtonsThemeData(
      selectedColor: darkBlue,
      disabledColor: darkBlue,
      fillColor: yellow,
      disabledBorderColor: Colors.grey,
      selectedBorderColor: yellow,
    ),
    // textTheme: TextTheme(
    //   bodyText1: const TextStyle(color: Colors.white),
    //   bodyText2: const TextStyle(color: Colors.white),
    //   // button: const TextStyle(color: Colors.white),
    //   caption: TextStyle(color: yellow),
    //   subtitle1: const TextStyle(color: Colors.white), // Input field
    //   headline1: const TextStyle(color: Colors.white),
    //   headline2: const TextStyle(color: Colors.white),
    //   headline3: const TextStyle(color: Colors.white),
    //   headline4: const TextStyle(color: Colors.white),
    //   headline5: const TextStyle(color: Colors.white),
    //   headline6: const TextStyle(color: Colors.white),
    // )
    chipTheme: ChipThemeData.fromDefaults(
      primaryColor: yellow,
      secondaryColor: green,
      labelStyle: const TextStyle(),
    ),
  );

  static CustomTheme lightTheme = CustomTheme(
    name: 'light',
    mode: AppThemeMode.light,
    colors: {
      "darkBlue": darkBlue,
      "yellow": yellow,
      "green": green,
      "inputTextColor": Colors.black,
    },
    themeData: lightThemeData,
    widgetThemes: {
      "bottomNavigationBar": lightThemeData.copyWith(
        canvasColor: darkBlue,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.purple),
          bodyText2: TextStyle(color: darkBlue),
          button: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.grey),
          subtitle1: TextStyle(color: Colors.black),
          headline1: TextStyle(color: Colors.white),
          headline2: TextStyle(color: Colors.white),
          headline3: TextStyle(color: Colors.white),
          headline4: TextStyle(color: Colors.white),
          headline5: TextStyle(color: Colors.white),
          headline6: TextStyle(color: Colors.black),
        ),
      ),
    },
  );

  /// Returns a list of available themes.
  static List<CustomTheme> listThemes() => [lightTheme, darkTheme];
}

extension ThemesExtension on BuildContext {
  ThemeData get theme => BlocProvider.of<AppThemeCubit>(this).theme.themeData;

  CustomTheme get customTheme => BlocProvider.of<AppThemeCubit>(this).theme;
}
