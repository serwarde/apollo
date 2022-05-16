import 'package:awesome_poll_app/components/widgets/poll_view/poll_result.widget.dart';
import 'package:awesome_poll_app/services/push_notifications/notifications.service.dart';
import 'package:flutter/foundation.dart';
import 'package:json_intl/json_intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/router.gr.dart' as r_gr;
import 'package:awesome_poll_app/services/auth/auth_guard.dart';
import 'package:awesome_poll_app/components/navigation.component.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:awesome_poll_app/services/lang/language.service.dart';
import 'package:awesome_poll_app/components/widgets/animations/fancy_loading.widget.dart';
import 'package:awesome_poll_app/notification_handler.dart';

main() async {
  // there are two options: firebase, local
  // local will mock behavior of firebase, changes won't be saved
  await configureDependencies(firebase.name);
  NotificationsService.initialize();
  HydratedBlocOverrides.runZoned(() => runApp(RoutingWrapper()),
    storage: await HydratedStorage.build(
      storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
    ),
  );
}

//see router.dart
class RoutingWrapper extends StatelessWidget {
  RoutingWrapper({Key? key}) : super(key: key);

  final AppRouter _router = r_gr.AppRouter(authGuard: AuthGuard());

  NotificationHandler notification = NotificationHandler();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => AuthCubit(
        auth: getIt.get<AuthService>(),
      )),
      BlocProvider(create: (context) => AppThemeCubit()),
      BlocProvider(create: (context) => LocalizationCubit()),
      BlocProvider(create: (context) => ChartTypeCubit()),
    ],
    child: Builder(
      builder: (context) => MaterialApp.router(
        title: "APOLLO",
        localizationsDelegates: const [
          JsonIntlDelegate(
            base: 'assets/lang',
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: context.read<LocalizationCubit>().listLocales(),
        locale: context.watch<LocalizationCubit>().state,
        theme: context.watch<AppThemeCubit>().theme.themeData,
        routeInformationParser: _router.defaultRouteParser(),
        routerDelegate: _router.delegate(
          navigatorObservers: () => [
            AuthObserver(
              rootRouter: _router,
            ),
          ],
        ),
        builder: (context, child) => BlocBuilder<AuthCubit, String?>(
          builder: (context, state) => FutureBuilder( // this is to prevent the login screen from showing for a small time when logged in
            future: getIt.get<AuthService>().initialized,
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done ? SafeArea(
              child: child ?? Container(),
            ) : const Scaffold(
              body: Center(
                child: DefaultFancyLoadingWidget(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

//wrapper for showing navigation bar and main content at the same time
class MainComponent extends StatelessWidget {
  const MainComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<AppThemeCubit, CustomTheme>(
    builder: (context, state) => Theme(
      data: state.themeData,
      child: Scaffold(
        // AutoRouter will always resolve component based on routing context
        body: const AutoRouter(),
        bottomNavigationBar: Theme(
          data: state.getWidgetTheme("bottomNavigationBar"),
          child: const NavigationComponent(),
        ),
      ),
    ),
  );

}
