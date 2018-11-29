import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Chapter.dart';
import 'Search.dart';
import 'History.dart';
import 'Favorite.dart';
import 'DataClient.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_alert/easy_alert.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<Home> {
  final url = "http://118.24.168.209:8060";
  var page = 0;
  List<Map<String, Object>> items = [];
  RefreshController _refreshController;
  bool isPerformingRequest = false;
  Drawer drawer;

  _getMoreData() async {
    Dio dio = new Dio();
    if (!isPerformingRequest) {
      // 判断是否有请求正在执行
      setState(() => isPerformingRequest = true);
      var response = await dio.get('$url/getIndex/$page');
      if (response.data == null) {
        _refreshController.sendBack(false, RefreshStatus.noMore);
        return;
      }
      page++;
      setState(() {
        items.addAll(response.data.cast<Map<String, Object>>());
        isPerformingRequest = false; // 下一个请求可以开始了
        _refreshController.sendBack(false, RefreshStatus.completed);
      });
    }
  }

  HomePage() {
    getData();
    DataClient().create();
  }

  getData() async {
    Dio dio = new Dio();
    page = 0;
    var response = await dio.get('$url/getIndex/$page');
    items.clear();
    setState(() {
      page++;
      items.addAll(response.data.cast<Map<String, Object>>());
      isPerformingRequest = false; // 下一个请求可以开始了
      _refreshController.sendBack(true, RefreshStatus.canRefresh);
    });
  }

  searchData(String name) async {
    Dio dio = new Dio();
    page = 0;
    var response = await dio.get('$url/searchByName/$name');
    items.clear();
    setState(() {
      items.addAll(response.data.cast<Map<String, Object>>());
      isPerformingRequest = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: new AppBar(
            title: TabBar(
              tabs: [
                Tab(
                  text: "所有番剧",
                ),
                Tab(text: "我的收藏"),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ),
                  );
                },
                tooltip: "搜索",
              ),
            ]),
        body: TabBarView(
          children: [
            new Scaffold(
              floatingActionButton:
                  new Builder(builder: (BuildContext context) {
                return new FloatingActionButton(
                  child: const Icon(Icons.refresh),
                  tooltip: "重新获取资源",
                  heroTag: null,
                  elevation: 7.0,
                  highlightElevation: 14.0,
                  onPressed: () {
                    Alert.confirm(context, title: "提示", content: "确认重新获取资源吗?")
                        .then((ret) {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("重新获取资源中..."),
                      ));
                      reGetSource(ret);
                    });
                  },
                  mini: false,
                  shape: new CircleBorder(),
                  isExtended: false,
                );
              }),
              body: new SmartRefresher(
                enablePullUp: true,
                controller: _refreshController,
                footerConfig: new RefreshConfig(),
                onRefresh: (up) {
                  if (up) {
                    getData();
                  } else {
                    _getMoreData();
                  }
                },
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: new Text("${items[index]["Name"]}"),
                      subtitle: Text("${items[index]["Chapter"]}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chapter(data: items[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            new Favorite(),
          ],
        ),
        drawer: _buildDraw(),
      ),
    );
  }

  Widget _buildDraw() {
    drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Center(
              child: Text('Anime App'),
            ),
          ),
          ListTile(
            title: Text('首页'),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('历史记录'),
            leading: Icon(Icons.history),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => History(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('设置'),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    return drawer;
  }

  void reGetSource(int ret) async {
    if (ret == Alert.OK) {
      Dio dio = new Dio();
      var response = await dio.get('$url/getAllSource');
      Fluttertoast.showToast(
        msg: response.data["msg"],
      );
      setState(() {
        items.clear();
      });
    }
  }
}
