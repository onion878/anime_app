import 'package:flutter/material.dart';
import './model/HistoryData.dart';
import 'package:dio/dio.dart';
import 'DataClient.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Chapter.dart';
import 'package:easy_alert/easy_alert.dart';

class History extends StatefulWidget {
  History({Key key}) : super(key: key);

  @override
  HistoryPage createState() => HistoryPage();
}

class HistoryPage extends State<History> {
  List<HistoryData> items = [];
  DataClient db;
  ScrollController controller;
  int page = 0;
  final url = "http://118.24.168.209:8060";

  HistoryPage() {
    db = DataClient();
    db.create().then((err) {
      db.allHistory(page).then((d) {
        if (d != null) {
          setState(() {
            items.addAll(d);
          });
        }
      });
    });
  }

  void getMoreData() {
    db.allHistory(page).then((d) {
      if (d != null) {
        setState(() {
          items.addAll(d);
        });
      }
    });
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    if (items.length > 0) {
      super.initState();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('历史记录'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Alert.confirm(context, title: "提示", content: "确认删除所有历史记录吗?").then(deleteHistory);
            },
          ),
        ],
      ),
      body: new Scrollbar(
        child: ListView.builder(
          controller: controller,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: new Text(
                "${items[index].index}",
              ),
              subtitle: new Text(
                "${items[index].created}",
              ),
              onTap: () {
                Dio dio = new Dio();
                dio
                    .get('$url/getByName/${items[index].index}')
                    .then((response) {
                  if (response.data != null && response.data.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chapter(data: response.data[0]),
                      ),
                    );
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }

  void _scrollListener() {
    page++;
    getMoreData();
  }

  void deleteHistory(int ret) {
    if(ret == Alert.OK) {
      db.deleteHistory();
      Fluttertoast.showToast(
        msg: "删除成功!",
      );
      setState(() {
        items.clear();
      });
    }
  }
}
