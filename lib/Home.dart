import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Chapter.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('目录'),
      ),
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
    );
  }
}
