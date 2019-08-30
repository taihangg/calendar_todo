import 'dart:convert';

import 'month_view.dart';
import 'common_data_type.dart';
import 'config_file.dart';
import 'weather_data.dart';
import 'todo_view.dart';

_GlobalData _inst = _GlobalData();
_GlobalData get globalData => _inst;

class _GlobalData {
  _GlobalData() {
    loadTaskData();
  }

  ////////////// 天气数据 //////////////
  WeatherData weatherData = WeatherData();

  ////////////// 任务视图 //////////////
  Map<String, TaskEntry> dateTaskDataMap = {};

  ////////////// 文件存储 //////////////
  ConfigFile cfgFile = ConfigFile();

  loadTaskData() async {
    var jsonStr = await cfgFile.loadString();

    if (null == jsonStr) {
      return null;
    }

    Map m = json.decode(jsonStr);

    m.forEach((k, v) {
      var te = TaskEntry.fromJson(v);
      dateTaskDataMap[k] = te;
    });

    dateTaskDataMap.forEach((k, dateRoot) {
      dateRoot.initStatus();
    });
  }

  saveTaskData() async {
    var jsonStr = await json.encode(dateTaskDataMap);
    cfgFile.saveString(jsonStr); // 文件会先被清空，再写入数据
  }

  saveTaskDataAndRefreshView() {
    saveTaskData();
  }
}
