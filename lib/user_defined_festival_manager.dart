import 'package:flutter/material.dart';
import 'data_file.dart';

class Festival {
  String dateStr;
  Color color;
  String text;
  Festival(this.dateStr, this.color, this.text);
}

class UserDefinedFestivalManager {
  UserDefinedFestivalManager() {
    _init();
  }

  final String _userDefinedFestivalKey = "USER_DEFINED_FESTIVAL";
  final KeyValueFile _KVFile = KeyValueFile();
  String _text;

  Map<String, List<Festival>> _festivalMap = {};

  _init() async {
    if (null != _text) {
      return;
    }

    final text = await _KVFile.getString(key: _userDefinedFestivalKey);
    if (null == _text) {
      // 没有被设置新值
      _text = text;
      _pasre();
    }
  }

  String get text => _text;
  String setText(String newText) {
    _text = newText;
    final log = _pasre();
    _setString();
    return log;
  }

  void _setString() async {
    await _KVFile.setString(key: _userDefinedFestivalKey, value: _text);
  }

  String _pasre() {
    _festivalMap = {};
    if (null == _text) {
      return "";
    }

    final regExp = RegExp(
        r'^([GL][0-9]{1,2}\.-{0,1}[0-9]{1,2})/#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})/(.+)$');

    final lines = _text.split("\n");

    String allLog = "";
    for (var line in lines) {
      line = line.trim();
      if ("" == line) {
        continue;
      }

      final allMatches = regExp.allMatches(line);

      if (1 != allMatches.length) {
        final log = "自定义节日{$line}格式不正确！\n";
        print(log);
        allLog += log;

        continue;
      }

      final match = allMatches.first;
      assert(5 == match.groupCount);

      final dateStr = match.group(1);
      final colorR = match.group(2);
      final colorG = match.group(3);
      final colorB = match.group(4);
      String festivalText = match.group(5);
      festivalText = festivalText.trim();

      int r;
      int g;
      int b;

      try {
        r = int.tryParse(colorR, radix: 16); // may throw exception
        g = int.tryParse(colorG, radix: 16); // may throw exception
        b = int.tryParse(colorB, radix: 16); // may throw exception
      } catch (e) {
        print("parse user defined festival error : $e");
        continue;
      }

      final festival =
          Festival(dateStr, Color.fromARGB(255, r, g, b), festivalText);
      final l = _festivalMap[dateStr];
      if (null == l) {
        _festivalMap[dateStr] = [festival];
      } else {
        l.add(festival);
      }

      String str = "parse festival :";
      for (var i = 1; i <= match.groupCount; i++) {
        str += " $i=${match.group(i)}";
      }
      print(str);
    }

    return allLog;

//    final allMatches = regExp.allMatches(_text);
//
//    for (var match in allMatches) {
//      assert(5 == match.groupCount);
//
//      final dateStr = match.group(1);
//      final colorR = match.group(2);
//      final colorG = match.group(3);
//      final colorB = match.group(4);
//      String text = match.group(5);
//      text = text.trimLeft();
//      text = text.trimRight();
//
//      int r;
//      int g;
//      int b;
//
//      try {
//        r = int.tryParse(colorR, radix: 16); // may throw exception
//        g = int.tryParse(colorG, radix: 16); // may throw exception
//        b = int.tryParse(colorB, radix: 16); // may throw exception
//      } catch (e) {
//        print("parse user defined festival error : $e");
//        continue;
//      }
//
//      final festival = Festival(dateStr, Color.fromARGB(255, r, g, b), text);
//
//      String str = "parse festival :";
//      for (var i = 1; i <= match.groupCount; i++) {
//        str += " $i=${match.group(i)}";
//      }
//      print(str);
//    }
  }

  List<Festival> _getFestival(
      String type, int month, int day, int monthDaysCount) {
    List<Festival> all = [];
    final dateStr1 = "${type}$month.$day";
    final list1 = _festivalMap[dateStr1];
    if (null != list1) {
      all.addAll(list1);
    }
    final dateStr2 = "${type}$month.-${monthDaysCount - day + 1}";
    final list2 = _festivalMap[dateStr2];
    if (null != list2) {
      all.addAll(list2);
    }

    final dateStr3 = "${type}0.$day";
    final list3 = _festivalMap[dateStr3];
    if (null != list3) {
      all.addAll(list3);
    }

    final dateStr4 = "${type}0.-${monthDaysCount - day + 1}";
    final list4 = _festivalMap[dateStr4];
    if (null != list4) {
      all.addAll(list4);
    }

    return all;
  }

  List<Festival> getGregorianFestival(int month, int day, int monthDaysCount) {
    return _getFestival("G", month, day, monthDaysCount);
  }

  List<Festival> getLunarFestival(int month, int day, int monthDaysCount) {
    return _getFestival("L", month, day, monthDaysCount);
  }
}
