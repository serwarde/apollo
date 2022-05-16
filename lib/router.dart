import 'package:auto_route/auto_route.dart';
import 'package:awesome_poll_app/components/login.component.dart';
import 'package:awesome_poll_app/components/change_password.component.dart';
import 'package:awesome_poll_app/components/my_poll.component.dart';
import 'package:awesome_poll_app/components/participate_poll.component.dart';
import 'package:awesome_poll_app/components/poll_view.component.dart';
import 'package:awesome_poll_app/components/settings.component.dart';
import 'package:awesome_poll_app/services/auth/auth_guard.dart';
import 'package:flutter/material.dart';
import 'components/navigation.component.dart';
import 'components/registration.component.dart';
import 'main.dart';

import 'router.gr.dart' as r_gr;
//for changes to apply, a build runner is required, see readme or
//https://autoroute.vercel.app/introduction

//this defines all possible navigation routes, including transitions between components, access restrictions and parameter validation
@MaterialAutoRouter(
  replaceInRouteName: 'Component,Route', //part of class name will be replaced
  routes: <AutoRoute>[
    AutoRoute(page: EmptyRouterPage, path: '/', guards: [AuthGuard], children: [
      //everything inside here requires login
      AutoRoute(page: MainComponent, path: '', children: [
        AutoRoute(page: MyPollComponent, path: 'my-polls/'),
        AutoRoute(page: ParticipatePollComponent, path: 'participate/', initial: true),
        AutoRoute(page: SettingsComponent, path: 'settings/'),
      ]),
      AutoRoute(page: ChangePasswordComponent, path: 'change-password/'),
      //poll views
      AutoRoute(page: PollCreateComponent, path: 'create/'),
      AutoRoute(page: PollEditComponent, path: 'edit/:pollId/'),
      AutoRoute(page: PollParticipateComponent, path: 'vote/:pollId/'),
      AutoRoute(page: PollResultComponent, path: 'result/:pollId/'),
    ]),
    // everything after here can be accessed without authentication
    AutoRoute(page: LoginComponent, path: '/login'),
    AutoRoute(page: RegistrationComponent, path: '/register') //just trying
  ],
)
class $AppRouter {}
