import 'dart:convert';

import 'calendar/sxwnl_Lunar.dart';
import 'my_common_data_type.dart';
import 'my_file.dart';
import 'my_month_view.dart';
import 'my_task_view.dart';
import 'my_weather_data.dart';

MyGlobalData _inst = MyGlobalData();

/*
GlobalDataInit() {
  _myGlobalDataInst = MyGlobalData();
}

GlobalData() {
  return _myGlobalDataInst;
}
*/

class MyGlobalData {
  static MyGlobalData get data {
    assert(null != _inst);
    return _inst;
  }

  MyGlobalData() {
    loadTaskData();
  }

  ////////////// 天气视图 //////////////
  WeatherData weatherData = WeatherData();

  ////////////// 月历视图 //////////////
  DateTime monthViewShowDate;
  List<LunarMonth> monthViewLunarArr = List(3); // 前一月、当前月、后一月的农历、干支信息
  DateTime selectedDate;
  MyMonthViewState monthViewState;

  testShowLunar(String note) {
    return;

    print("xxx " + note);
    for (var i = 0; i < monthViewLunarArr.length; i++) {
      var month = monthViewLunarArr[i];
      if (null == month) {
        print("$i null");
      } else {
        print(
            "$i ${month.gregorianYear}-${month.gregorianMonth}:${month.monthDaysCount}");
      }
    }
  }

  updateMonthViewShowDate(DateTime newDt) async {
    var oldShowDate = monthViewShowDate;
    monthViewShowDate = newDt;
    monthViewState?.setState(() {});
    if (isSameMonth(newDt, oldShowDate)) {
      // 还是当月，不用更新农历信息
      testShowLunar("当月");
      return;
    }

    var newLastMonth = DateTime(newDt.year, newDt.month - 1, 1);
    var newNextMonth = DateTime(newDt.year, newDt.month + 1, 1);

    if (null != oldShowDate) {
      var oldLastMonth = DateTime(oldShowDate.year, oldShowDate.month - 1, 1);
      if (isSameMonth(newDt, oldLastMonth)) {
        // 显示上个月
        monthViewLunarArr[2] = monthViewLunarArr[1];
        monthViewLunarArr[1] = monthViewLunarArr[0];
        monthViewLunarArr[0] = null;

        testShowLunar("上月");

        monthViewLunarArr[0] = await LunarMonth(newLastMonth);
        monthViewState?.setState(() {});

        return;
      }

      var oldNextMonth = DateTime(oldShowDate.year, oldShowDate.month - 1, 1);
      if (isSameMonth(newDt, oldNextMonth)) {
        // 显示下个月
        monthViewLunarArr[0] = monthViewLunarArr[1];
        monthViewLunarArr[1] = monthViewLunarArr[2];
        monthViewLunarArr[2] = null;

        testShowLunar("下月");

        monthViewLunarArr[2] = await LunarMonth(newNextMonth);
        monthViewState?.setState(() {});

        return;
      }

      var lastLastMonth = DateTime(oldShowDate.year, oldShowDate.month - 2, 1);
      if (isSameMonth(newDt, lastLastMonth)) {
        // 显示上上个月
        monthViewLunarArr[2] = monthViewLunarArr[0];
        monthViewLunarArr[0] = null;
        monthViewLunarArr[1] = null;

        testShowLunar("上上月");

        monthViewLunarArr[0] = await LunarMonth(newLastMonth);
        monthViewLunarArr[1] = await LunarMonth(newDt);
        monthViewState?.setState(() {});

        return;
      }

      var nextNextMonth = DateTime(oldShowDate.year, oldShowDate.month + 2, 1);
      if (isSameMonth(newDt, nextNextMonth)) {
        // 显示下下个月
        monthViewLunarArr[0] = monthViewLunarArr[2];
        monthViewLunarArr[1] = null;
        monthViewLunarArr[2] = null;

        testShowLunar("下下月");

        monthViewLunarArr[1] = await LunarMonth(newDt);
        monthViewLunarArr[2] = await LunarMonth(newNextMonth);
        monthViewState?.setState(() {});

        return;
      }
    }

    // 都不是，全都重新更新
    monthViewLunarArr[0] = null;
    monthViewLunarArr[1] = null;
    monthViewLunarArr[2] = null;

    testShowLunar("全新");

    monthViewLunarArr[1] = await LunarMonth(newDt);
    monthViewState?.setState(() {});

    await Future(() {
      monthViewLunarArr[0] = LunarMonth(newLastMonth);
      monthViewState?.setState(() {});
    });

    await Future(() {
      monthViewLunarArr[2] = LunarMonth(newNextMonth);
      monthViewState?.setState(() {});
    });

    return;
  }

  ////////////// 任务视图 //////////////
  MyTaskViewState taskViewState;
  MyTaskEntry selectedTaskEntry;
  Map<String, MyTaskEntry> dateTaskDataMap = {};

  // for delete
  MyExpansionTileItemState selectedExpansionItemState;

  ////////////// 文件存储 //////////////
  MyFile myFile = MyFile();

  loadTaskData() async {
    // SaveTaskData(); // for test

    var jsonStr = await myFile.loadString();

    if (null == jsonStr) {
      return null;
    }

    Map m = json.decode(jsonStr);

    m.forEach((k, v) {
      var te = MyTaskEntry.fromJson(v);
      dateTaskDataMap[k] = te;
    });

    dateTaskDataMap.forEach((k, dateRoot) {
      dateRoot.initStatus();
    });

    setStateMonthAndTaskView();
  }

  saveTaskDataAndRefreshView() async {
    var jsonStr = json.encode(dateTaskDataMap);
    await myFile.saveString(jsonStr); // 文件会先被清空，再写入数据

    setStateMonthAndTaskView();
  }

  updateSelectDate(DateTime date, bool selected) {
    if (selected) {
      // 选中
      MyGlobalData.data.selectedDate = date;
    } else {
      // 取消选中
      MyGlobalData.data.selectedDate = null;
    }
    setStateMonthAndTaskView();
  }

  setStateMonthAndTaskView() {
    //assert(null != monthViewState);
    monthViewState?.setState(() {});

    //assert(null != taskViewState);
    taskViewState?.setState(() {});
  }

  /*
  // 第二阶段初始化？
  init() {
    weatherData.getDataFromNetwork();
  }
  */
}
