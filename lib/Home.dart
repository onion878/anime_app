import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'Chapter.dart';
import 'History.dart';
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
  SearchBar searchBar;
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
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onChanged: (v) {
          searchData(v);
        },
        onClosed: getData,
        hintText: '搜索',
        buildDefaultAppBar: buildAppBar);
    super.initState();
    _refreshController = new RefreshController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('目录'), actions: [searchBar.getSearchAction(context)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
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
      drawer: _buildDraw(),
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
            decoration: BoxDecoration(
              color: Colors.blue,
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
          ListTile(
            title: Text('获取资源'),
            leading: Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
              Alert.confirm(context, title: "提示", content: "确认重新获取资源吗?").then(reGetSource);
            },
          ),
        ],
      ),
    );
    return drawer;
  }

  void reGetSource(int ret) async {
    if(ret == Alert.OK) {
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
