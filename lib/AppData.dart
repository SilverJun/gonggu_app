import 'package:firebase_auth/firebase_auth.dart';

enum LoginType{None, Google, Anonymous}

class AppProfile {
  FirebaseUser user;
  LoginType loginType;

  AppProfile() {
    user = null;
    loginType = LoginType.None;
  }

}

AppProfile appProfile = AppProfile();

final String storagePath = 'gs://gongguapp-adf25.appspot.com/';

enum Category {
  DailySupply, // 생필품
  FrozenFood, // 냉동식품
  Fruit, // 야채,채소
  Drink, // 음료
  Electronics, // 전자제품
  Accessory, // 악세서리
  Clothes, // 의류
  stationery, // 문구류
  Etc,
}

// describeEnum(enumObject); // from flutter/foundation.dart


