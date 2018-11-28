final String tableTodo = "favorite";
final String columnId = "id";
final String columnIndex = "index";
final String columnChapter = "chapter";
final String columnCreated = "created";

class FavoriteData {
  int id;
  String index;
  String chapter;
  String created;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnIndex: index,
      columnChapter: chapter,
      columnCreated: created,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  FavoriteData();

  FavoriteData.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    index = map[columnIndex];
    chapter = map[columnChapter];
    created = map[columnCreated];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'index': index,
    'chapter': chapter,
    'created': created,
  };
}
