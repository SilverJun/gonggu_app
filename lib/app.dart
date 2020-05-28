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
import 'package:introduction_screen/introduction_screen.dart';

import 'home.dart';
import 'login.dart';

class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Final Test',
      //home: LoginPage(),
      theme: ThemeData(primaryColor: Color.fromARGB(255,237,98,96), accentColor:Color.fromARGB(255,240,142,125) ,fontFamily: 'Hippy'),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding' : (context) {
          return IntroductionScreen(
            pages: [
              PageViewModel(
                title: "공동구매",
                body: "좀 더 저렴하게 다양한 물건들을 공동구매 해보세요! 당신의 삶이 더 경제적이게 됩니다.",
                image: Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset("images/purchase.png", height: 175.0)
                  ),
                ),
              ),
              PageViewModel(
                title: "다양한 제품",
                body: "당신의 취향을 몰라 이것저것 다양하게 준비해두었으니 살펴보세요! 마음에 드는 물건을 저렴하게 구하실 수 있을 겁니다.",
                image: Center(
                  child: Image.asset("images/things.png", height: 175.0),
                ),
              ),
              PageViewModel(
                title: "준비 되셨나요?",
                body: "이제 끝났습니다. 당신을 슬기로운 공구생활로 초대합니다. 준비 되셨나요? 그럼 이제 시작하시죠!",
                image: Center(
                child: Image.asset("images/consumer.png", height: 175.0),
                ),
              ),
            ],
            onDone: () {
              // When done button is press
              Navigator.of(context).popAndPushNamed('/login');
            },
//            onSkip: () {
//              // You can also override onSkip callback
//            },
            //showSkipButton: true,
            //skip: const Icon(Icons.skip_next),
            next: const Icon(Icons.navigate_next),
            done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
            dotsDecorator: DotsDecorator(
                size: const Size.square(10.0),
                activeSize: const Size(20.0, 10.0),
                activeColor: Theme.of(context).accentColor,
                color: Colors.black26,
                spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)
                )
            ),
          );
        },
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
