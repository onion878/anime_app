import 'package:flutter/material.dart';
import 'Home.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_alert/easy_alert.dart';

void main() => runApp(new AlertProvider(
      child: new MyApp(),
      config: new AlertConfig(ok: "确认", cancel: "取消"),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.indigo,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'AnimeApp',
            theme: theme,
            home: new Home(),
          );
        });
  }
}
