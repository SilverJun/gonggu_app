// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';

class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Final Test',
      //home: LoginPage(),
      theme: ThemeData(primaryColor: Color.fromARGB(255,32,36,47),
          primaryColorLight: Color.fromARGB(255,240,142,125),
          hintColor: Color.fromARGB(255,222,220,209) ,
          accentColor:Color.fromARGB(255,148,203,194) ,fontFamily: 'Hippy'),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding' : (context) => OnboardingPage(),
        '/login' : (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}
