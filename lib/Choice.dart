import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Light', icon: Icons.brightness_1),
  const Choice(title: 'Dark', icon: Icons.brightness_3),
];
