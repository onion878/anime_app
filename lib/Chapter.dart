import 'package:AnimeApp/model/SettingData.dart';
import 'package:flutter/material.dart';
import 'package:AnimeApp/Choice.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';
import 'package:screen/screen.dart';
import './model/HistoryData.dart';
import './model/FavoriteData.dart';
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
  FavoriteData favoriteData;
  Timer timer;
  Timer play;
  bool isCheck = false;
  VideoPlayerController videoPlayerController;

  ChewieController chewieController;

  Chewie chewie;

  List<VideoPlayerController> videos = List();

  bool isSeek = true;

  int beforeLen = 0;

  String url = "";

  ChapterPage(Map d) {
    this.data = d;
    db = DataClient();
    db.create().then((err) {
      db.fetchHistory(data["Name"]).then((h) {
        if (h != null) {
          historyData = h;
        }
      });
      db.fetchFavorite(data["Name"]).then((f) {
        if (f != null) {
          favoriteData = f;
        }
      });
      db.getSetting("url").then((d) {
        if (d != null) {
          setState(() {
            url = d.value;
          });
          getData();
        }
      });
      db.getSetting("backplay").then((SettingData v) {
        if (v != null) {
          setState(() {
            isCheck = v.value == 'true';
          });
        }
      });
      runTask();
    });
  }

  getData() async {
    Dio dio = new Dio();
    var response = await dio.get('$url/getChapter/${data["Id"]}');
    if (response.data != null) {
      setState(() {
        items.addAll(response.data.cast<Map<String, Object>>());
        setOrder();
        initPlayer();
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

  void initPlayer() {
    if (videos.length > 0) {
      videos.forEach((v) {
        v.dispose();
      });
      videos.clear();
    }
    if (items.length > 0) {
      if (order + 1 > items.length) {
        order = 0;
      }
      if (videos.length > 0) {
        videos.forEach((v) {
          v.dispose();
        });
        videos.clear();
      }
      if (videoPlayerController != null) {
        videoPlayerController.pause();
        videos.add(videoPlayerController);
      }
      videoPlayerController =
          VideoPlayerController.network(items[order]["Path"]);
      videoPlayerController.addListener(initialize);
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
      );

      chewie = Chewie(
        controller: chewieController,
      );
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
    if (videoPlayerController.value.isPlaying && isSeek) {
      setSeek(videoPlayerController);
    }
  }

  @override
  Widget build(BuildContext context) {
    Screen.keepOn(true);
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: new AppBar(
          title: Text('${data["Name"]}'),
          actions: <Widget>[
            IconButton(
              icon: favoriteData != null
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.favorite_border,
                    ),
              onPressed: () {
                if (favoriteData == null) {
                  var favorite = FavoriteData();
                  favorite.created = DateTime.now().toString();
                  favorite.index = data["Name"];
                  favorite.chapter = data["Chapter"];
                  db.addFavorite(favorite);
                  setState(() {
                    favoriteData = favorite;
                  });
                } else {
                  db.deleteFavorite(favoriteData);
                  setState(() {
                    favoriteData = null;
                  });
                }
              },
              tooltip: "收藏",
            ),
            new PopupMenuButton<Choice>(
              tooltip: "更多操作",
              // overflow menu
              itemBuilder: (BuildContext context) {
                return chapters.map((Choice choice) {
                  Widget child;
                  if (choice.id == 1) {
                    child = ListTile(
                      title: Text(choice.title),
                      trailing: Icon(
                        isCheck
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Colors.teal,
                      ),
                    );
                  } else {
                    child = ListTile(
                      title: new Text(choice.title),
                      trailing: Icon(
                        choice.icon,
                        color: Colors.redAccent,
                      ),
                    );
                  }
                  return new PopupMenuItem<Choice>(
                    value: choice,
                    child: child,
                  );
                }).toList();
              },
              onSelected: (Choice choice) {
                if (choice.id == 0) {
                  Alert.confirm(context, title: "提示", content: "确认重新获取资源吗?")
                      .then(reGetSource);
                } else if (choice.id == 1) {
                  setState(() {
                    isCheck = !isCheck;
                  });
                  var settingData = SettingData();
                  settingData.id = "backplay";
                  settingData.value = isCheck.toString();
                  db.changeSetting(settingData);
                }
              },
            ),
          ],
        ),
        body: new Column(
          children: <Widget>[
            items.length > 0
                ? new Center(
                    child: new Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: chewie,
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
                              order == index ? Colors.lightBlue : Colors.teal),
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
                      order = index;
                      setState(() {
                        initPlayer();
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
    try {
      videoPlayerController.dispose();
      chewieController.dispose();
      duration = await videoPlayerController.position;
    } catch (e) {}
    saveHistory();
    Screen.keepOn(false);
    if (videos.length > 0) {
      videos.forEach((v) {
        v.dispose();
      });
      videos.clear();
    }
    super.dispose();
  }

  void runTask() async {
    timer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.position.then((d) {
          duration = d;
          saveHistory();
        });
      }
    });
    play = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (isCheck && videoPlayerController.value.isPlaying == false) {
        chewieController.play();
      }
    });
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
    timer.cancel();
    play.cancel();
    return Future<bool>.value(true);
  }

  void reGetSource(int ret) async {
    if (ret == Alert.OK) {
      Dio dio = new Dio();
      var response = await dio.get('$url/getOneSource/${data["Name"]}');
      if (response.data["success"]) {
        sleep(const Duration(seconds: 2));
        items.clear();
        await getData();
        Fluttertoast.showToast(
          msg: response.data["msg"],
        );
      }
    }
  }
}
