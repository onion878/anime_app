import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'Chapter.dart';
import 'DataClient.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  SearchPage createState() => SearchPage();
}

class SearchPage extends State<Search> {
  List<Map<String, Object>> items = [];
  DataClient db;
  ScrollController controller;
  int page = 0;
  String name = '';
  String url = "";

  SearchPage() {
    db = DataClient();
    db.create().then((err) {
      db.getSetting("url").then((d) {
        if (d != null) {
          setState(() {
            url = d.value;
          });
          getData();
        }
      });
    });
  }

  void getData() async {
    Dio dio = new Dio();
    page = 0;
    var response = await dio.get('$url/getIndex/$page');
    items.clear();
    setState(() {
      page++;
      items.addAll(response.data.cast<Map<String, Object>>());
    });
  }

  searchData() async {
    Dio dio = new Dio();
    page = 0;
    if (name.trim().length == 0) {
      getData();
    } else {
      var response = await dio.get('$url/searchByName/$name');
      items.clear();
      setState(() {
        if (response.data != null) {
          items.addAll(response.data.cast<Map<String, Object>>());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (text) {
            name = text;
            searchData();
          },
        ),
      ),
      body: ListView.builder(
        controller: controller,
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
    );
  }
}
