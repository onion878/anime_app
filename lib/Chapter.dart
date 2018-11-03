import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';
import './model/HistoryData.dart';
import 'DataClient.dart';
import 'package:easy_alert/easy_alert.dart';

class Chapter extends StatefulWidget {
  final Map data;

  Chapter({Key key, @required this.data}) : super(key: key);

  @override
  ChapterPage createState() => ChapterPage(data);
}

class ChapterPage extends State<Chapter> {
  List<Map<String, Object>> items = [];
  Map data;
  int order = 0;
  Duration duration;
  DataClient db;
  HistoryData historyData;

  List<Chewie> videos = [];

  Chewie videoPlayers;

  bool isSeek = true;

  int beforeLen = 0;

  ChapterPage(Map d) {
    this.data = d;
    db = DataClient();
    db.create().then((err) {
      db.fetchHistory(data["Name"]).then((h) {
        if (h != null) {
          print(h.toJson());
          historyData = h;
        }
        getData();
      });
    });
  }

  final url = "http://118.24.168.209:8060";

  getData() async {
    Dio dio = new Dio();
    var response = await dio.get('$url/getChapter/${data["Id"]}');
    if (response.data != null) {
      setState(() {
        items.addAll(response.data.cast<Map<String, Object>>());
        setOrder();
      });
    } else {
      Fluttertoast.showToast(
        msg: "未找到数据!",
      );
    }
  }

  void setOrder() {
    if (items.length > 0 && historyData != null) {
      order = items.length - historyData.chapter - 1;
    }
  }

  void setSeek(c) {
    if (items.length > 0 &&
        c != null &&
        historyData != null &&
        historyData.duration != null) {
      isSeek = false;
      c.seekTo(Duration(milliseconds: historyData.duration)).then((_) {
        c.play();
      });
    }
  }

  @override
  void initState() {
    if (items.length > 0) {
      super.initState();
    }
  }

  void initialize() {
    if (videoPlayers.controller.value.isPlaying && isSeek) {
      setSeek(videoPlayers.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      if (order + 1 > items.length) {
        order = 0;
      }
      var c = new VideoPlayerController.network(items[order]["Path"]);
      c.addListener(initialize);
      videoPlayers = new Chewie(
        c,
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Alert.confirm(context, title: "提示", content: "确认重新获取资源吗?")
                    .then(reGetSource);
              },
              tooltip: "重新获取资源",
            ),
          ],
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
  void dispose() async {
    for (int i = 0; i < videos.length; i++) {
      if (videos[i].controller.value.isPlaying) {
        duration = await videos[i].controller.position;
      }
      if (!videos[i].controller.isDisposed) {
        videos[i].controller.removeListener(initialize);
        videos[i].controller.dispose();
      }
    }
    saveHistory();
    videos.clear();
    super.dispose();
  }

  void saveHistory() {
    if (duration != null) {
      var history = HistoryData();
      history.created = DateTime.now().toString();
      history.index = data["Name"];
      history.chapter = items.length - order - 1;
      history.duration = duration.inMilliseconds;
      db.addHistory(history);
    }
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

  void reGetSource(int ret) async {
    if (ret == Alert.OK) {
      Dio dio = new Dio();
      var response = await dio.get('$url/getOneSource/${data["Name"]}');
      if(response.data["success"]) {
        sleep(const Duration(seconds:2));
        items.clear();
        await getData();
        Fluttertoast.showToast(
          msg: response.data["msg"],
        );
      }
    }
  }
}
