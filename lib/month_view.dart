import 'dart:async';
import 'dart:ui';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'sxwnl/sxwnl_Lunar.dart';
import 'day.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'festirval_editor.dart';
import 'month_view_action_bar.dart';
import 'user_defined_festival_manager.dart';

Future<void> showLunarDatePickerDialog({
  @required BuildContext context,
  @required Function(DateTime dt) fn,
  DateTime initialDate,
}) async {
  final _width = MediaQueryData.fromWindow(window).size.width;
  DateTime _selectedDt = initialDate ?? DateTime.now();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Material(
        //创建透明层
        type: MaterialType.transparency, //透明类型
        child: Container(
          decoration: ShapeDecoration(
//                color: Color(0xffffffff),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
          ),
          child: SimpleDialog(
            children: <Widget>[
              MonthView(
                onDateSelectedFn: (DateTime selectedDate) {
                  _selectedDt = selectedDate;
                },
                onMonthChangeFn: (DateTime showMonth) {},
                noteIconTypeFn: (DateTime date) {
                  return NoteIconType.none;
                },
              ),
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: Container(
                            child: Text("返回",
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: _width / 15,
                                ))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    Container(
                        height: _width * 2 / 15,
                        child: VerticalDivider(color: Colors.grey)),
                    FlatButton(
                      child: Container(
                          child: Text("确定",
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: _width / 15,
                              ))),
                      onPressed: () {
                        fn(_selectedDt);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

enum NoteIconType {
  none,
  grey,
  colorful,
}

class MonthView extends StatefulWidget {
  final Function(DateTime selectedDate) onDateSelectedFn;
  final Function(DateTime showMonth) onMonthChangeFn;
  final NoteIconType Function(DateTime date) noteIconTypeFn;
  MonthView({
    this.onDateSelectedFn,
    this.onMonthChangeFn,
    this.noteIconTypeFn,
    initDate,
  }) {
    _setShowDate(initDate ?? DateTime.now());
    _selectedDate = initDate;
  }

  UserDefinedFestivalManager _userDefinedFestivalMgr =
      UserDefinedFestivalManager();

  DateTime _showDate;
  _MonthViewDateInfo _monthViewDate;
  DateTime _selectedDate;

  _setShowDate(DateTime date) {
    this._showDate = date;
    _monthViewDate = _MonthViewDateInfo(_showDate, 1);
  }

  setShowMonth(DateTime month) {
    _setShowDate(month);
    Refresh();
  }

  Refresh() {
    if ((null != _monthViewState) && (_monthViewState.mounted)) {
      _monthViewState.setState(() {});
    }
  }

  final _monthFmt = DateFormat('yyyy-MM');
  Map<String, LunarMonth> _lunars = {};

  MonthViewState _monthViewState;

  @override
  State<MonthView> createState() {
    _monthViewState = MonthViewState();

    return _monthViewState;
  }
}

class MonthViewState extends State<MonthView> {
  final double _width = MediaQueryData.fromWindow(window).size.width;

  Function(DateTime, bool) _onDaySelectedFn;

  MonthViewState() {
    _onDaySelectedFn = (DateTime date, bool selected) {
      widget._selectedDate = selected ? date : null;
      widget.onDateSelectedFn(widget._selectedDate);
      setState(() {});
    };
  }

  EventBus _eventBus = EventBus();
  StreamSubscription subscription;

  @override
  initState() {
    super.initState();

    subscription = _eventBus.on<DateTime>().listen((DateTime newDt) {
      widget._setShowDate(newDt);
      setState(() {});
    });
  }

  @override
  dispose() {
    _eventBus.destroy();

    super.dispose();
  }

  LunarMonth _getMonthLunar(DateTime month) {
    final monthStr = widget._monthFmt.format(month);

    LunarMonth lunar = widget._lunars[monthStr];
    if (null == lunar) {
      lunar = LunarMonth(month);
//      print(
//          "${lunar.days[0].lunarMonthName}:${lunar.days[0].lunarMonth}:${lunar.days[0].lunarMonthDayCount}");
      widget._lunars[monthStr] = lunar;
      return lunar;
      Future(() {
        widget._lunars[monthStr] = LunarMonth(month);
        setState(() {});
      });
    }
    return lunar;
  }

  List<TitleDay> _weekdayList(int firstWeekday) {
    List<TitleDay> _list = List.generate(7, (int index) {
      return TitleDay(((index + firstWeekday - 1) % 7) + 1, this._width);
    });
    return _list;
  }

  List<TextSpan> _getUserDefinedGregorianFestival(
      int month, int day, int monthDaysCount) {
    List<TextSpan> all = [];

    final festivalList = widget._userDefinedFestivalMgr
        .getGregorianFestival(month, day, monthDaysCount);

    festivalList.forEach((Festival festival) {
      all.addAll([
        TextSpan(text: festival.text, style: TextStyle(color: festival.color)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    });

    return all;
  }

  List<TextSpan> _getUserDefinedLunarFestival(
      int month, int day, int monthDaysCount) {
    List<TextSpan> all = [];

    final festivalList = widget._userDefinedFestivalMgr
        .getLunarFestival(month, day, monthDaysCount);

    festivalList.forEach((Festival festival) {
      all.addAll([
        TextSpan(text: festival.text, style: TextStyle(color: festival.color)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    });

    return all;
  }

  void _prepareNoteStr(LunarMonth lunarMonth, _MonthInfo monthInfo, int day,
      List<TextSpan> lunarStrs, List<TextSpan> gregorianStrs) {
    if (null == lunarMonth) {
      return;
    }

    assert((lunarMonth.monthDaysCount == monthInfo.daysCount) &&
        (lunarMonth.gregorianMonth == monthInfo.month) &&
        (lunarMonth.gregorianYear == monthInfo.year));
    var lunarDayInfo = lunarMonth.days[day - 1];

    //农历信息+
    lunarStrs.clear();
    if (1 == lunarDayInfo.lunarDay) {
      //农历月份
      lunarStrs.addAll([
        TextSpan(
            text: lunarDayInfo.lunarMonthName,
            style: TextStyle(color: Colors.orange)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
//      lunarStrs.addAll([
//        TextSpan(text: ".", style: TextStyle(color: Colors.grey)),
//        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
//      ]);
    }

    //农历日期
    lunarStrs.addAll([
      TextSpan(
          text: lunarDayInfo.lunarDayName,
          style: TextStyle(color: Colors.grey)),
      TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
    ]);

    if ("" != lunarDayInfo.lunarFestival) {
//      lunarStrs.addAll([
//        TextSpan(text: ".", style: TextStyle(color: Colors.grey)),
//        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
//      ]);
      //农历节日
      lunarStrs.addAll([
        TextSpan(
            text: lunarDayInfo.lunarFestival,
            style: TextStyle(color: Colors.blue)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    }
    lunarStrs.addAll(_getUserDefinedLunarFestival(lunarDayInfo.month,
        lunarDayInfo.lunarDay, lunarDayInfo.lunarMonthDayCount));

    if (lunarStrs.isNotEmpty) {
      lunarStrs.removeLast();
    }

    //公历信息
    gregorianStrs.clear();
    if (1 == lunarDayInfo.day) {
      gregorianStrs.addAll([
        TextSpan(
            text: "${monthInfo.month}月",
            style: TextStyle(color: Colors.orange)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    }

    if ("" != lunarDayInfo.jieqi) {
      if (gregorianStrs.isNotEmpty) {
//        gregorianStrs.addAll([
//          TextSpan(text: ".", style: TextStyle(color: Colors.grey)),
//          TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
//        ]);
      }
      //节气
      gregorianStrs.addAll([
        TextSpan(text: lunarDayInfo.jieqi, style: TextStyle(color: Colors.red)),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    }
    if ("" != lunarDayInfo.gregorianFestival) {
      if (gregorianStrs.isNotEmpty) {
//        gregorianStrs.addAll([
//          TextSpan(text: ".", style: TextStyle(color: Colors.grey)),
//          TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
//        ]);
      }
      //公历节日
      gregorianStrs.addAll([
        TextSpan(
          text: lunarDayInfo.gregorianFestival,
          style: TextStyle(color: Colors.orange),
        ),
        TextSpan(text: ",", style: TextStyle(color: Colors.grey)),
      ]);
    }
    gregorianStrs.addAll(_getUserDefinedGregorianFestival(
        monthInfo.month, day, monthInfo.daysCount));

    if (gregorianStrs.isNotEmpty) {
      gregorianStrs.removeLast();
    }
  }

  List<DayBox> _generateDays(_MonthInfo monthInfo, LunarMonth lunarMonth,
      bool baskgroundGrey, DateTime today) {
    List<DayBox> days = [];

    for (int index = 0, day = monthInfo.firstShowDay;
        index < monthInfo.showCount;
        index++, day++) {
      final date = DateTime(monthInfo.year, monthInfo.month, day);
      final selected = _isSameDay(date, widget._selectedDate);
      final isToday = _isSameDay(date, today);
      List<TextSpan> lunarStrs = [], gregorianStrs = [];
      _prepareNoteStr(lunarMonth, monthInfo, day, lunarStrs, gregorianStrs);

      final noteIconType = widget.noteIconTypeFn(date);
      assert(null != noteIconType);

      days.add(DayBox(date, _width,
          showNoteIcon: (noteIconType != NoteIconType.none),
          noteActive: (noteIconType == NoteIconType.colorful),
          selected: selected,
          isToday: isToday,
          baskgroundGrey: baskgroundGrey,
          gregorianStrs: gregorianStrs,
          lunarStrs: lunarStrs,
          onSelectCallback: _onDaySelectedFn));
    }

    return days;
  }

  List<DayBox> _dayList(final _MonthViewDateInfo _monthViewDate) {
    List<DayBox> _list = [];

    final today = DateTime.now();
    _MonthInfo monthInfo;
    LunarMonth lunarMonth;
    List<DayBox> days;

    // previous month
    monthInfo = _monthViewDate.data[0];
    lunarMonth = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    days = _generateDays(monthInfo, lunarMonth, true, today);
    _list.addAll(days);

    // current month
    monthInfo = _monthViewDate.data[1];
    lunarMonth = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    days = _generateDays(monthInfo, lunarMonth, false, today);
    _list.addAll(days);

    // next month
    monthInfo = _monthViewDate.data[2];
    lunarMonth = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    days = _generateDays(monthInfo, lunarMonth, true, today);
    _list.addAll(days);

    assert(
        (28 == _list.length) || (35 == _list.length) || (42 == _list.length));
    return _list;
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
    table.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: _styleRow(_weekdays),
      ),
    );

    for (var i = 0; i < _dayList.length; i += 7) {
      table.add(_styleRow(_dayList.sublist(i, i + 7)));
    }
    return table;
  }

  @override
  Widget build(BuildContext context) {
    final List<TitleDay> _weekdays = _weekdayList(1);
    final List<DayBox> _days = _dayList(widget._monthViewDate);
    final List<Widget> _table = _martrix(_weekdays, _days);

    return Container(
//            margin: EdgeInsets.all(screenWidth / 50),
//            padding: EdgeInsets.all(screenWidth / 50),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(width: 1.0, color: Colors.black38),
//        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MonthViewActionBar(
            screenWidth: _width,
            showMonth: widget._selectedDate ?? widget._showDate,
            onDateChangeFn: (DateTime day) {
              widget._setShowDate(day);
              widget.onMonthChangeFn(day);

              if (null != widget._selectedDate) {
                widget.onDateSelectedFn(day);
                widget._selectedDate = day;
              }
              setState(() {});
            },
            getFestivalText: () {
              return widget._userDefinedFestivalMgr.text;
            },
            onSaveFn: (String newText) {
              return widget._userDefinedFestivalMgr.setText(newText);
//              setState(() {});
            },
          ),
          Container(
            width: _width * 8 / 9,
//            height: screenWidth  * 8/ 9,
            margin: EdgeInsets.all(_width / 50),
            padding: EdgeInsets.all(_width / 50),
            decoration: BoxDecoration(
//              color: Colors.red,
              border: Border.all(width: 1.0, color: Colors.black38),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: FittedBox(
              alignment: Alignment.topCenter,
              child: Column(children: _table),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isSameDay(final DateTime dt1, final DateTime dt2) {
  return ((null != dt1) &&
      (null != dt2) &&
      (dt1.day == dt2.day) &&
      (dt1.month == dt2.month) &&
      (dt1.year == dt2.year));
}

class _MonthInfo {
  int year = 0;
  int month = 0;
  int daysCount = 0;
  int firstShowDay = 0;
  int lastShowDay = 0;
  int showCount = 0;
}

class _MonthViewDateInfo {
  // 分别是上个月，当前月，下个月的数据
  final List<_MonthInfo> data = [_MonthInfo(), _MonthInfo(), _MonthInfo()];
  final DateTime dt;
  final int showFirstWeekday; // 从周几开始显示
  int calendarShowDaysCount; // 月历中需要显示的天数

  _MonthViewDateInfo(this.dt, this.showFirstWeekday) {
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
