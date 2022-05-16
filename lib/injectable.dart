import 'package:awesome_poll_app/injectable.config.dart';
import 'package:awesome_poll_app/utils/commons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';

/*
 * allows dependency injection, registered classes are globally usable
 * with: var instance = getIt.get<Classname>();
 */
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies(String? env) async {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(
    logPrinter: StreamPrinter(const PrettyDeveloperPrinter()),
  );
  if (env == firebase.name) {
    await Firebase.initializeApp(
        name: '[DEFAULT]',
        options: const FirebaseOptions(
            apiKey: 'AIzaSyClK5pyVyEVJmFTIz8iR-zI2PBFBztTwNg',
            appId: '1:22485641319:web:f054f40f7b04e7ad394cc2',
            messagingSenderId: '22485641319',
            projectId: 'awesome-poll-app'));
  }
  $initGetIt(getIt, environment: env);
}
