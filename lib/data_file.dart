import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RawFile {
  final String fileName;
  RawFile({@required this.fileName}) {
    _init();
  }

  static String _path;
  File _file;
  void _init() async {
    if (null == _path) {
      final dir = await getApplicationDocumentsDirectory();
      _path = dir.path;
    }

    if (null == _file) {
      _file = File("$_path/$fileName");
    }

    //LoadTaskData();
//    SaveTaskData();
  }

  getString() async {
    try {
      await _init();
      var jsonStr = await _file.readAsString();
      print("loadString:$jsonStr");

      return jsonStr;
    } catch (err) {
      print(err);
    }
  }

  setString(String text) async {
    try {
      await _init();
      await _file.writeAsString(text /*+ "\n"*/);
    } catch (e) {
      print(e);
    }
  }
}

class KeyValueFile {
  KeyValueFile() {
    _init();
  }

  static SharedPreferences _prefs;
  _init() async {
    if (null == _prefs) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<String> getString({@required String key}) async {
    await _init();
    return _prefs.getString(key);
  }

  Future<bool> setString({@required String key, @required String value}) async {
    await _init();
    return _prefs.setString(key, value);
  }
}
