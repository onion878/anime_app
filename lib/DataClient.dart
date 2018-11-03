import 'dart:async';
import 'dart:io';
import './model/HistoryData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataClient {
  Database _db;

  Future create() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, "data.db");
    _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
  }

  //Erstellt die Tabellen
  Future _create(Database db, int version) async {
    await db.execute("""
        CREATE TABLE history (
           `id` INTEGER PRIMARY KEY AUTOINCREMENT,
           `index` TEXT NULL,
           `chapter` INTEGER NULL,
           `duration` INTEGER NULL,
           `created` TEXT NULL
           )                
    """);
  }

  //Neue Einträge hinzufügen

  Future<HistoryData> fetchHistory(String index) async {
    List result = await _db.query(
      "history",
      columns: ["*"],
      where: "`index`=?",
      whereArgs: [index],
      orderBy: "id desc",
      limit: 1,
    );
    print(result);
    if (result.length == 0) {
      return Future<HistoryData>.value(null);
    } else {
      HistoryData history = HistoryData.fromMap(result[0]);
      return Future<HistoryData>.value(history);
    }
  }

  Future addHistory(HistoryData history) async {
    var batch = _db.batch();
    batch.delete("history", where: "`index`=?", whereArgs: [history.index]);
    batch.insert("history", history.toMap());
    return batch.commit();
  }

  Future deleteHistory() async {
    var batch = _db.batch();
    batch.delete("history");
    return batch.commit();
  }

  Future upsertHistory(HistoryData kategorie) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery(
        "SELECT COUNT (*) FROM kategorie WHERE title = ?", [kategorie.id]));
    if (count == 0) {
      kategorie.id = await _db.insert("kategorie", kategorie.toMap());
    } else {
      await _db.update("kategorie", kategorie.toMap(),
          where: "id = ?", whereArgs: [kategorie.id]);
    }
    return kategorie;
  }

  Future<List<HistoryData>> allHistory(int page) async {
    List histories =
        await _db.query("history", columns: ["*"], orderBy: "id desc", limit: 20, offset: page * 20);
    if (histories.length == 0) {
      return Future<List<HistoryData>>.value(null);
    } else {
      List<HistoryData> data = [];
      for (int i = 0; i < histories.length; i++) {
        data.add(HistoryData.fromMap(histories[i]));
      }
      return Future<List<HistoryData>>.value(data);
    }
  }
}
