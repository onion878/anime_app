final String tableTodo = "history";
final String columnId = "id";
final String columnIndex = "index";
final String columnChapter = "chapter";
final String columnDuration = "duration";
final String columnCreated = "created";

class HistoryData {
  int id;
  String index;
  int chapter;
  int duration;
  String created;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnIndex: index,
      columnChapter: chapter,
      columnDuration: duration,
      columnCreated: created,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  HistoryData();

  HistoryData.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    index = map[columnIndex];
    chapter = map[columnChapter];
    duration = map[columnDuration];
    created = map[columnCreated];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'index': index,
    'chapter': chapter,
    'duration': duration,
    'created': created,
  };
}
