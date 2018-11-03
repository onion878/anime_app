import 'package:flutter/material.dart';
import 'package:anime_app/Home.dart';
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
      title: '动漫',
      home: new Home(),
    );
  }
}