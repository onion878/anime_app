import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon, this.id});

  final String title;
  final IconData icon;
  final int id;
}

const List<Choice> themes = const <Choice>[
  const Choice(title: 'Light', icon: Icons.brightness_1),
  const Choice(title: 'Dark', icon: Icons.brightness_3),
];

const List<Choice> chapters = const <Choice>[
  const Choice(id: 0, title: '重新获取资源', icon: Icons.refresh),
  const Choice(id: 1, title: '后台播放', icon: Icons.brightness_3),
];
