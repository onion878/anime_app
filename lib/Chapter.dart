import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Chapter extends StatefulWidget {
  final Map data;

  Chapter({Key key, @required this.data}) : super(key: key);

  @override
  ChapterPage createState() => ChapterPage(data);
}

class ChapterPage extends State<Chapter> {
  List<Map<String, Object>> items = [];
  Map data;
  var order = 0;

  List<Chewie> videos = [];

  Chewie videoPlayers;

  ChapterPage(Map d) {
    this.data = d;
    getData();
  }

  final url = "http://118.24.168.209:8060";

  getData() async {
    Dio dio = new Dio();
    var response = await dio.get('$url/getChapter/${data["Id"]}');
    if (response.data != null) {
      print(response.data);
      setState(() {
        items.addAll(response.data.cast<Map<String, Object>>());
      });
    } else {
      Fluttertoast.showToast(
        msg: "未找到数据!",
      );
    }
  }

  @override
  void initState() {
    if (items.length > 0) {
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      videoPlayers = new Chewie(
        new VideoPlayerController.network(items[order]["Path"]),
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
      );
      videos.add(videoPlayers);
    }
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: new AppBar(
          title: Text('${data["Name"]}'),
        ),
        body: new Column(
          children: <Widget>[
            items.length > 0
                ? new Center(
                    child: new Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: videoPlayers,
                    ),
                  )
                : new Center(
                    child: Text(
                      "未获取到资源列表!",
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
            new Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: new Text(
                      "${items[index]["Name"]}",
                      style: TextStyle(
                          color:
                              order == index ? Colors.lightBlue : Colors.black),
                    ),
                    trailing: order == index
                        ? Icon(
                            Icons.play_arrow,
                            color: Colors.lightBlue,
                          )
                        : Icon(
                            Icons.edit_attributes,
                            color: Colors.transparent,
                          ),
                    onTap: () {
                      setState(() {
                        order = index;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    for (int i = 0; i < videos.length; i++) {
      videos[i].controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() {
//    if (full) {
//      SystemChrome.setPreferredOrientations([
//        DeviceOrientation.portraitUp,
//        DeviceOrientation.portraitDown,
//      ]);
//      setState(() {
//        full = false;
//      });
//      return Future<bool>.value(false);
//    }
    return Future<bool>.value(true);
  }
}
