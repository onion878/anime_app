final String tableTodo = "setting";
final String columnId = "id";
final String columnValue = "value";
final String columnCreated = "created";

class SettingData {
  String id;
  String value;
  String created;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnValue: value,
      columnCreated: created,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  SettingData();

  SettingData.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    value = map[columnValue];
    created = map[columnCreated];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'created': created,
  };
}
