import 'package:flutter/material.dart';
import './model/FavoriteData.dart';
import 'package:dio/dio.dart';
import 'DataClient.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Chapter.dart';
import 'package:easy_alert/easy_alert.dart';

class Favorite extends StatefulWidget {
  Favorite({Key key}) : super(key: key);

  @override
  FavoritePage createState() => FavoritePage();
}

class FavoritePage extends State<Favorite> {
  List<FavoriteData> items = [];
  DataClient db;
  ScrollController controller;
  int page = 0;
  String url = "";

  FavoritePage() {
    db = DataClient();
    db.create().then((err) {
      db.allFavorite(page).then((d) {
        if (d != null) {
          setState(() {
            items.addAll(d);
          });
        }
      });
      db.getSetting("url").then((d) {
        if (d != null) {
          setState(() {
            url = d.value;
          });
        }
      });
    });
  }

  void getMoreData() {
    db.allFavorite(page).then((d) {
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
      body: new Scrollbar(
        child: ListView.builder(
          controller: controller,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: new Text("${items[index].index}"),
              subtitle: Text("${items[index].chapter}"),
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
}
