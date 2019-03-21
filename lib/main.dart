import 'package:flutter/material.dart';
import 'Home.dart';
import 'package:easy_alert/easy_alert.dart';

void main() => runApp(new AlertProvider(
  child: new MyApp(),
  config: new AlertConfig(ok: "确认", cancel: "取消"),
));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'AnimeApp',
      theme: ThemeData(
        // Define the default Brightness and Colors
        brightness: Brightness.dark,

        // Define the default Font Family
        fontFamily: 'Montserrat',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 30.0, fontStyle: FontStyle.normal),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: new Home(),
    );
  }
}