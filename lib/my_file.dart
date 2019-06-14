import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFile {
  static const String configFileName = "defaultConfig";
  String docDir;
  static const String taskDataFileName = "taskData.json";
  static const String USER_TASK_DATA_PATH_TAG = "USER_TASK_DATA_PATH";
  String userTaskDataPath;

  MyFile() {
    loadConfig();
  }

  loadConfig() async {
    if (null == userTaskDataPath) {
      var dir = await getApplicationDocumentsDirectory();
      docDir = dir.path;

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      userTaskDataPath = sharedPreferences.getString(USER_TASK_DATA_PATH_TAG);
      if (null == userTaskDataPath) {
        userTaskDataPath = docDir;
      }
    }

    //LoadTaskData();
//    SaveTaskData();
  }

  loadString() async {
    try {
      await loadConfig();
      final file = File("$userTaskDataPath/$taskDataFileName");
      var jsonStr = await file.readAsString();

      return jsonStr;
    } catch (err) {
      print(err);
    }
  }

  saveString(String data) async {
    try {
      await loadConfig();
      File file = File("$userTaskDataPath/$taskDataFileName");
      //file.create();
      file.writeAsString(data + "\n");
    } catch (e) {
      print(e);
    }
  }

//var p3 = await getExternalStorageDirectory();

}
