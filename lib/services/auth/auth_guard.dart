
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:awesome_poll_app/injectable.dart';
import 'package:awesome_poll_app/router.gr.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';

//guards routes which require authentication
class AuthGuard extends AutoRedirectGuard {
  late final StreamSubscription _subscription;
  AuthGuard() {
    _subscription = getIt.get<AuthService>().uidChanges.listen((event) {
      reevaluate(
        //@dt if route errors still behave weired, just try that, but is kinda expensive
        //strategy: const ReevaluationStrategy.rePushAllRoutes(),
      );
    });
  }

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    var auth = getIt.get<AuthService>();
    if (auth.isLoggedIn()) {
      resolver.next();
    } else {
      redirect(const LoginRoute(), resolver: resolver);
    }
  }

  @override
  void dispose() async {
    await _subscription.cancel();
    super.dispose();
  }

}