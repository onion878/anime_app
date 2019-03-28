import 'package:flutter/material.dart';
import 'DataClient.dart';
import './model/SettingData.dart';

class Setting extends StatefulWidget {
  Setting({Key key}) : super(key: key);

  @override
  SettingPage createState() => SettingPage();
}

class SettingPage extends State<Setting> {
  DataClient db;
  var urlController = TextEditingController(text: "");

  SettingPage() {
    db = DataClient();
    db.create().then((err) {
      db.getSetting("url").then((d) {
        if (d != null) {
          setState(() {
            urlController.text = d.value;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              decoration: InputDecoration(labelText: '服务器地址:', hintText: 'http://127.0.0.1:8060'),
              controller: urlController,
              onFieldSubmitted: (String newValue) {
                var d = new SettingData();
                d.id = "url";
                d.value = newValue;
                db.changeSetting(d);
              },
            ),
          ),
        ],
      ),
    );
  }
}
