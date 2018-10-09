import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Chapter extends StatefulWidget  {

  final Map data;

  Chapter({Key key,@required this.data}) : super(key: key);

  @override
  ChapterPage createState() => ChapterPage(data);
}

class ChapterPage extends State<Chapter> {

  Map data;

  ChapterPage(Map d){
    this.data = d;
  }

  final url = "http://118.24.168.209:8060";

  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text('目录'),
      ),
      body: new Column(
        children: <Widget>[
          new Center(
            child: new Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Text(
                'Sub Title',
                style:
                    new TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          new Expanded(
            child: new ListView(
              children: <Widget>[
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
                Text("Onion"),
              ],
              padding: const EdgeInsets.all(8.0),
            ),
          ),
        ],
      ),
    );
  }
}
