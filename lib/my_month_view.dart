import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar/sxwnl_Lunar.dart';
import 'my_day.dart';
import 'my_global_data.dart';

class MyMonthView extends StatefulWidget {
  final double width;
  MyMonthView(this.width);

  @override
  createState() {
    var tmp = MyMonthViewState(this.width);
    MyGlobalData.data.monthViewState = tmp;

    return tmp;
  }
}

class MyMonthViewState extends State<MyMonthView> {
  final double screenWidth;

  final Function(DateTime, bool) onSelectCallback =
      MyGlobalData.data.updateSelectDate;

  MyMonthViewState(this.screenWidth);

  List<TitleDay> _weekdayList(int firstWeekday) {
    List<TitleDay> _list = List.generate(7, (int index) {
      return TitleDay(((index + firstWeekday - 1) % 7) + 1, this.screenWidth);
    });
    return _list;
  }

  List<DayBox> _dayList(final _MyMonthViewDateInfo _monthViewDate) {
    List<DayBox> _list = [];

    LunarMonth lunar;
    _MyMonthInfo monthInfo;

    // last month
    lunar = MyGlobalData.data.monthViewLunarArr[0];
    monthInfo = _monthViewDate.data[0];
    for (var index = 0, day = monthInfo.firstShowDay;
        index < monthInfo.showCount;
        index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, MyGlobalData.data.selectedDate);

      String lunarStr = "";
      Color lunarColor;
      if (null != lunar) {
        assert((lunar.monthDaysCount == monthInfo.daysCount) &&
            (lunar.gregorianMonth == monthInfo.month) &&
            (lunar.gregorianYear == monthInfo.year));
        var lunarDayInfo = lunar.days[day - 1];
        if ("" != lunarDayInfo.jieqi) {
          lunarStr = lunarDayInfo.jieqi;
          lunarColor = Colors.red;
        } else if (0 != lunarDayInfo.lunarDayIndex) {
          lunarStr = lunarDayInfo.lunarDayName;
        } else {
          lunarStr = lunarDayInfo.lunarMonthName;
          lunarColor = Colors.orange;
        }
      }

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: _hasTask(date),
          noteActive: !_isTaskALlDone(date),
          selected: selected,
          baskgroundGrey: true,
          lunarInfo: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: onSelectCallback));
    }

    // 上个月的第一天显示月份
    var count = _list.length;
    if (0 != count) {
      _list[0].showMonth = true;
    }

    // current month
    lunar = MyGlobalData.data.monthViewLunarArr[1];
    monthInfo = _monthViewDate.data[1];
    var dt = _monthViewDate.dt;
    for (var index = 0, day = monthInfo.firstShowDay;
        index < monthInfo.showCount;
        index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, MyGlobalData.data.selectedDate);
      var isToday = _isSameDay(date, dt);

      String lunarStr = "";
      Color lunarColor;
      if (null != lunar) {
        assert((lunar.monthDaysCount == monthInfo.daysCount) &&
            (lunar.gregorianMonth == monthInfo.month) &&
            (lunar.gregorianYear == monthInfo.year));
        var lunarDayInfo = lunar.days[day - 1];
        if ("" != lunarDayInfo.jieqi) {
          lunarStr = lunarDayInfo.jieqi;
          lunarColor = Colors.red;
        } else if (0 != lunarDayInfo.lunarDayIndex) {
          lunarStr = lunarDayInfo.lunarDayName;
        } else {
          lunarStr = lunarDayInfo.lunarMonthName;
          lunarColor = Colors.orange;
        }
      }

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: _hasTask(date),
          noteActive: !_isTaskALlDone(date),
          selected: selected,
          isToday: isToday,
          lunarInfo: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: onSelectCallback));
    }

    // 本月的第一天显示月份
    _list[count].showMonth = true;
    count = _list.length;

    // next month
    lunar = MyGlobalData.data.monthViewLunarArr[2];
    monthInfo = _monthViewDate.data[2];
    for (var index = 0, day = monthInfo.firstShowDay;
        index < monthInfo.showCount;
        index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, MyGlobalData.data.selectedDate);

      String lunarStr = "";
      Color lunarColor;
      if (null != lunar) {
        assert((lunar.monthDaysCount == monthInfo.daysCount) &&
            (lunar.gregorianMonth == monthInfo.month) &&
            (lunar.gregorianYear == monthInfo.year));
        var lunarDayInfo = lunar.days[day - 1];
        if ("" != lunarDayInfo.jieqi) {
          lunarStr = lunarDayInfo.jieqi;
          lunarColor = Colors.red;
        } else if (0 != lunarDayInfo.lunarDayIndex) {
          lunarStr = lunarDayInfo.lunarDayName;
        } else {
          lunarStr = lunarDayInfo.lunarMonthName;
          lunarColor = Colors.orange;
        }
      }

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: _hasTask(date),
          noteActive: !_isTaskALlDone(date),
          selected: selected,
          baskgroundGrey: true,
          lunarInfo: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: onSelectCallback));
    }
    if (count != _list.length) {
      _list[count].showMonth = true;
    }

    assert(
        (28 == _list.length) || (35 == _list.length) || (42 == _list.length));
    return _list;
  }

  _hasTask(DateTime date) {
    final dateStr = DateFormat("yyyy-MM-dd").format(date);
    final dateTask = MyGlobalData.data.dateTaskDataMap[dateStr];

    var _has = false;
    if (null != dateTask) {
      if (dateTask.children.isNotEmpty) {
        _has = true;
      }
    }
    return _has;
  }

  _isTaskALlDone(DateTime date) {
    final dateStr = DateFormat("yyyy-MM-dd").format(date);
    final dateTask = MyGlobalData.data.dateTaskDataMap[dateStr];

    var _allDone = false;
    if (null != dateTask) {
      if (dateTask.children.isNotEmpty) {
        if (dateTask.children.length == dateTask.finishedChildCount) {
          _allDone = true;
          assert((null == dateTask.state) || (true == dateTask.state));
        }
      }
    }
    return _allDone;
  }

  _styleRow(List<Widget> list) {
    return Container(
        decoration: BoxDecoration(
            //color: Colors.lightBlueAccent,
            //border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: list));
  }

  List<Widget> _martrix(final List _weekdays, final List _dayList) {
    var table = <Widget>[];
    // 星期行增加以下上下的间隔
    table.add(Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5), child: _styleRow(_weekdays)));
    for (var i = 0; i < _dayList.length; i += 7) {
      table.add(_styleRow(_dayList.sublist(i, i + 7)));
    }
    return table;
  }

  @override
  Widget build(BuildContext context) {
    final _MyMonthViewDateInfo _monthViewDate =
        _MyMonthViewDateInfo(MyGlobalData.data.monthViewShowDate, 1);

    final List<TitleDay> _weekdays = _weekdayList(1);
    final List<DayBox> _days = _dayList(_monthViewDate);
    final List<Widget> _table = _martrix(_weekdays, _days);

    return Container(

//            margin: EdgeInsets.all(screenWidth / 50),
//            padding: EdgeInsets.all(screenWidth / 50),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MyMonthViewActionBar(screenWidth),
          Container(
//                      width: screenWidth / 9 * 8,
//                      height: screenWidth / 9 * 8,
              margin: EdgeInsets.all(screenWidth / 50),
              padding: EdgeInsets.all(screenWidth / 50),
              decoration: BoxDecoration(
//                  color: Colors.red,
                  border: Border.all(width: 1.0, color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: FittedBox(child: Column(children: _table))),
        ]));
  }
}

class MyMonthViewActionBar extends StatelessWidget {
  final double screenWidth;
  MyMonthViewActionBar(this.screenWidth);

  @override
  Widget build(BuildContext context) {
    var rowChildren = <Widget>[];

    rowChildren.add(Container(
        //color: Colors.orange,
        child: RaisedButton(
            color: Colors.grey[300],
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(child: Icon(Icons.arrow_back_ios)),
                  Text("上一月", style: TextStyle(fontSize: screenWidth / 25))
                ]),
            onPressed: () {
              final cur = MyGlobalData.data.monthViewShowDate;
              final last = DateTime(cur.year, cur.month - 1, 1);
              MyGlobalData.data.updateMonthViewShowDate(last);
            })));

    var dt = MyGlobalData.data.monthViewShowDate;
    rowChildren.add(Container(
      //alignment: Alignment.center,
      //padding: EdgeInsets.fromLTRB(screenWidth / 100, 0, screenWidth / 100, 0),
      child: RaisedButton(
          color: Colors.lightBlueAccent,
          child: Text(
            "${dt.year} 年 ${dt.month}月",
            style: TextStyle(fontSize: screenWidth / 20, color: Colors.black),
          ),
          onPressed: () async {
            var pickDate = await showDatePicker(
                context: context,
                initialDate: dt,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                locale: Localizations.localeOf(context));

            if (null != pickDate) {
              MyGlobalData.data.updateMonthViewShowDate(pickDate);
            }
          }),
    ));

    rowChildren.add(Container(
        //margin: EdgeInsets.fromLTRB(0, 0, screenWidth / 100, 0),
        width: screenWidth / 10,
        child: FloatingActionButton(
          backgroundColor: Colors.yellowAccent,
          child: Text("今",
              style: TextStyle(
                  color: Colors.lightBlue, fontSize: screenWidth / 15)),
          onPressed: () {
            MyGlobalData.data.updateMonthViewShowDate(DateTime.now());
          },
        )));

    rowChildren.add(Container(
        //color: Colors.orange,
        child: RaisedButton(
            color: Colors.grey[300],
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text("下一月", style: TextStyle(fontSize: screenWidth / 25)),
              Icon(Icons.arrow_forward_ios),
            ]),
            onPressed: () {
              final cur = MyGlobalData.data.monthViewShowDate;
              final next = DateTime(cur.year, cur.month + 1, 1);
              MyGlobalData.data.updateMonthViewShowDate(next);
            })));

    return FittedBox(
        child: Container(
//        width: screenWidth / 9 * 8,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
                //color: Colors.redAccent,
                border: Border.all(width: 0.5, color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rowChildren)));
  }
}

bool _isSameDay(final DateTime dt1, final DateTime dt2) {
  return ((null != dt1) &&
      (null != dt2) &&
      (dt1.day == dt2.day) &&
      (dt1.month == dt2.month) &&
      (dt1.year == dt2.year));
}

class _MyMonthInfo {
  int year = 0;
  int month = 0;
  int daysCount = 0;
  int firstShowDay = 0;
  int lastShowDay = 0;
  int showCount = 0;
}

class _MyMonthViewDateInfo {
  // 分别是上个月，当前月，下个月的数据
  final List<_MyMonthInfo> data = [
    _MyMonthInfo(),
    _MyMonthInfo(),
    _MyMonthInfo()
  ];
  final DateTime dt;
  final int showFirstWeekday; // 从周几开始显示
  int calendarShowDaysCount; // 月历中需要显示的天数

  _MyMonthViewDateInfo(this.dt, this.showFirstWeekday) {
    assert(1 == showFirstWeekday); //目前只处理了从周一开始显示

    calendarShowDaysCount = 0;

    var thisMonthFirstWeedday = DateTime(dt.year, dt.month, 1).weekday;
    if (showFirstWeekday != thisMonthFirstWeedday) {
      var lastMonthInfo = data[0];
      DateTime lastMonth = DateTime(dt.year, dt.month, 0);
      lastMonthInfo.year = lastMonth.year;
      lastMonthInfo.month = lastMonth.month;
      lastMonthInfo.daysCount = lastMonth.day;

      if (1 == showFirstWeekday) {
        lastMonthInfo.showCount = thisMonthFirstWeedday - 1;
        lastMonthInfo.firstShowDay =
            lastMonthInfo.daysCount - lastMonthInfo.showCount + 1;
        lastMonthInfo.lastShowDay = lastMonth.day;
      }

      calendarShowDaysCount += lastMonthInfo.showCount;
    }

    DateTime thisMonth = DateTime(dt.year, dt.month + 1, 0);
    var thisMonthInfo = data[1];

    thisMonthInfo.year = thisMonth.year;
    thisMonthInfo.month = thisMonth.month;
    thisMonthInfo.daysCount = thisMonth.day;
    thisMonthInfo.firstShowDay = 1;
    thisMonthInfo.lastShowDay = thisMonth.day;
    thisMonthInfo.showCount = thisMonth.day;
    calendarShowDaysCount += thisMonthInfo.showCount;

    var nextMonthFirstWeekday = DateTime(dt.year, dt.month + 1, 1).weekday;
    if (showFirstWeekday != nextMonthFirstWeekday) {
      var lastMonthInfo = data[2];

      var nextMonth = DateTime(dt.year, dt.month + 2, 0);
      lastMonthInfo.year = nextMonth.year;
      lastMonthInfo.month = nextMonth.month;
      lastMonthInfo.daysCount = nextMonth.day;

      if (1 == showFirstWeekday) {
        lastMonthInfo.firstShowDay = 1;
        lastMonthInfo.showCount = 7 - nextMonthFirstWeekday + 1;
        lastMonthInfo.lastShowDay = lastMonthInfo.showCount;
      }
      calendarShowDaysCount += lastMonthInfo.showCount;
    }
  }
}
