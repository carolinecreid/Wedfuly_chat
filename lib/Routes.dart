import 'package:flutter/material.dart';
import 'package:Wedfuly_Chat/screens/Login/index.dart';
import 'package:Wedfuly_Chat/screens/SignUp/index.dart';
import 'package:Wedfuly_Chat/screens/Home/index.dart';
import 'package:Wedfuly_Chat/theme/style.dart';

class Routes {

  var routes = <String, WidgetBuilder>{
    "/MenuPage": (BuildContext context) => new MenuScreen(),
    "/HomePage": (BuildContext context) => new HomeScreen()
  };

  Routes() {
    runApp(new MaterialApp(
      title: "Flutter Flat App",
      home: new LoginScreen(),
      theme: appTheme,
      routes: routes,
    ));
  }
}
