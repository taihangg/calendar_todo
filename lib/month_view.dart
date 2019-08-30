import 'dart:async';
import 'dart:ui';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar/sxwnl_Lunar.dart';
import 'day.dart';

Future<void> showLunarDatePickerDialog({
  @required BuildContext context,
  @required Function(DateTime dt) fn,
  DateTime initialDate,
  double width,
}) async {
  final _width = width ?? MediaQueryData.fromWindow(window).size.width;
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
                width: _width,
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
                width: _width,
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
  double width;
  DateTime _showDate;
  _MonthViewDateInfo _monthViewDate;
  DateTime _selectedDate;
  final Function(DateTime selectedDate) onDateSelectedFn;
  final Function(DateTime showMonth) onMonthChangeFn;
  final NoteIconType Function(DateTime date) noteIconTypeFn;

  MonthView({
    this.width,
    this.onDateSelectedFn,
    this.onMonthChangeFn,
    this.noteIconTypeFn,
    initDate,
  }) {
    _setShowDate(initDate ?? DateTime.now());

    this._selectedDate = initDate;
  }

  _setShowDate(DateTime date) {
    this._showDate = date;
    _monthViewDate = _MonthViewDateInfo(_showDate, 1);
  }

  setShowMonth(DateTime month) {
    _setShowDate(month);
    refresh();
  }

  refresh() {
    if ((null != _monthViewState) && (_monthViewState.mounted)) {
      _monthViewState.setState(() {});
    }
  }

  final _monthFmt = DateFormat('yyyy-MM');
  Map<String, LunarMonth> _lunars = {};

  MonthViewState _monthViewState;

  @override
  State<MonthView> createState() {
    _monthViewState = MonthViewState(this.width);

    return _monthViewState;
  }
}

class MonthViewState extends State<MonthView> {
  final double screenWidth;

  Function(DateTime, bool) _onDaySelectedFn;

  MonthViewState(this.screenWidth) {
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

    var lunar = widget._lunars[monthStr];
    if (null == lunar) {
      lunar = LunarMonth(month);
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
      return TitleDay(((index + firstWeekday - 1) % 7) + 1, this.screenWidth);
    });
    return _list;
  }

  List<DayBox> _dayList(final _MonthViewDateInfo _monthViewDate) {
    List<DayBox> _list = [];

    LunarMonth lunar;
    String lunarStr, gregorianStr;
    Color lunarColor, gregorianColor;
    _MonthInfo monthInfo;
    bool showGregorianMonth;
    bool showLunarMonth;
    int day;
    getNoteStr() {
      lunarStr = null;
      lunarColor = null;
      gregorianStr = null;
      gregorianColor = null;
      if (null != lunar) {
        assert((lunar.monthDaysCount == monthInfo.daysCount) &&
            (lunar.gregorianMonth == monthInfo.month) &&
            (lunar.gregorianYear == monthInfo.year));
        var lunarDayInfo = lunar.days[day - 1];

        if (0 == lunarDayInfo.lunarDayIndex) {
          showLunarMonth = false;
        }

        //农历信息+
        if ("" != lunarDayInfo.lunarFestival) {
          //农历节日
          lunarStr = lunarDayInfo.lunarFestival;
          lunarColor = Colors.orange;
        } else if (true != showLunarMonth) {
          //农历月首日
          lunarStr = lunarDayInfo.lunarMonthName;
          lunarColor = Colors.orange;
          showLunarMonth = true;
        } else {
          //农历日期
          lunarStr = lunarDayInfo.lunarDayName;
        }

        //公历信息
        if ("" != lunarDayInfo.jieqi) {
          //节气
          gregorianStr = lunarDayInfo.jieqi;
          gregorianColor = Colors.red;
        } else if ("" != lunarDayInfo.gregorianFestival) {
          //公历节日
          gregorianStr = lunarDayInfo.gregorianFestival;
          gregorianColor = Colors.orange;
        } else if (true != showGregorianMonth) {
          gregorianStr = "${monthInfo.month}月";
          gregorianColor = Colors.orange;
          showGregorianMonth = true;
        }
      }
    }

    // last month
    showGregorianMonth = false;

    monthInfo = _monthViewDate.data[0];
    lunar = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    day = monthInfo.firstShowDay;
    for (int index = 0; index < monthInfo.showCount; index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, widget._selectedDate);

      getNoteStr();

      final noteIconType = widget.noteIconTypeFn(date);
      assert(null != noteIconType);

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: (noteIconType != NoteIconType.none),
          noteActive: (noteIconType == NoteIconType.colorful),
          selected: selected,
          baskgroundGrey: true,
          gregorianStr: gregorianStr,
          gregorianColor: gregorianColor,
          lunarStr: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: _onDaySelectedFn));
    }

    // current month
    showGregorianMonth = false;

    monthInfo = _monthViewDate.data[1];
    lunar = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    var dt = _monthViewDate.dt;
    var today = DateTime.now();
    day = monthInfo.firstShowDay;
    for (var index = 0; index < monthInfo.showCount; index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, widget._selectedDate);
      var isToday = _isSameDay(date, today);

      getNoteStr();

      final noteIconType = widget.noteIconTypeFn(date);
      assert(null != noteIconType);

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: (noteIconType != NoteIconType.none),
          noteActive: (noteIconType == NoteIconType.colorful),
          selected: selected,
          isToday: isToday,
          gregorianStr: gregorianStr,
          gregorianColor: gregorianColor,
          lunarStr: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: _onDaySelectedFn));
    }

    // next month
    showGregorianMonth = false;
    monthInfo = _monthViewDate.data[2];
    lunar = _getMonthLunar(DateTime(monthInfo.year, monthInfo.month));
    day = monthInfo.firstShowDay;
    for (var index = 0; index < monthInfo.showCount; index++, day++) {
      var date = DateTime(monthInfo.year, monthInfo.month, day);
      var selected = _isSameDay(date, widget._selectedDate);

      getNoteStr();

      final noteIconType = widget.noteIconTypeFn(date);
      assert(null != noteIconType);

      _list.add(DayBox(date, screenWidth,
          showNoteIcon: (noteIconType != NoteIconType.none),
          noteActive: (noteIconType == NoteIconType.colorful),
          selected: selected,
          baskgroundGrey: true,
          gregorianStr: gregorianStr,
          gregorianColor: gregorianColor,
          lunarStr: lunarStr,
          lunarColor: lunarColor,
          onSelectCallback: _onDaySelectedFn));
    }

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
            screenWidth: screenWidth,
            showMonth: widget._showDate,
            onMonthChangeFn: (DateTime month) {
              widget._setShowDate(month);
              widget.onMonthChangeFn(month);
              setState(() {});
            },
          ),
          Container(
            width: screenWidth / 9 * 8,
//            height: screenWidth / 9 * 8,
            margin: EdgeInsets.all(screenWidth / 50),
            padding: EdgeInsets.all(screenWidth / 50),
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

class MonthViewActionBar extends StatelessWidget {
  final double screenWidth;
  DateTime showMonth;
  final Function(DateTime month) onMonthChangeFn;
  MonthViewActionBar(
      {this.screenWidth, this.showMonth, this.onMonthChangeFn}) {}

  @override
  Widget build(BuildContext context) {
    var rowChildren = <Widget>[];

    rowChildren.add(
      Container(
        //color: Colors.orange,
        child: RaisedButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(child: Icon(Icons.arrow_back_ios)),
              Text("上一月", style: TextStyle(fontSize: screenWidth / 25)),
            ],
          ),
          onPressed: () {
            final lastMonth = DateTime(showMonth.year, showMonth.month - 1, 1);
            onMonthChangeFn(lastMonth);
          },
        ),
      ),
    );
//
    rowChildren.add(Container(
      //alignment: Alignment.center,
      //padding: EdgeInsets.fromLTRB(screenWidth / 100, 0, screenWidth / 100, 0),
//      color: Colors.lightBlueAccent,
      child: RaisedButton(
        color: Colors.lightBlueAccent,
        child: Text(
          "${showMonth.year} 年 ${showMonth.month}月",
          style: TextStyle(fontSize: screenWidth / 20, color: Colors.black),
        ),
        onPressed: () async {
          var pickDate = await showDatePicker(
              context: context,
              initialDate: showMonth,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              locale: Localizations.localeOf(context));

          if (null != pickDate) {
            onMonthChangeFn(pickDate);
          }
        },
      ),
    ));

    rowChildren.add(
      Container(
        //margin: EdgeInsets.fromLTRB(0, 0, screenWidth / 100, 0),
        width: screenWidth / 10,
        child: FloatingActionButton(
          backgroundColor: Colors.yellowAccent,
          child: Text("今",
              style: TextStyle(
                  color: Colors.lightBlue, fontSize: screenWidth / 15)),
          onPressed: () {
            onMonthChangeFn(DateTime.now());
          },
        ),
      ),
    );

    rowChildren.add(
      Container(
//        color: Colors.orange,
        child: RaisedButton(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("下一月", style: TextStyle(fontSize: screenWidth / 25)),
            Icon(Icons.arrow_forward_ios),
          ]),
          onPressed: () {
            final nextMonth = DateTime(showMonth.year, showMonth.month + 1, 1);
            onMonthChangeFn(nextMonth);
          },
        ),
      ),
    );

    return FittedBox(
      child: Container(
        width: screenWidth / 9 * 8,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          //color: Colors.redAccent,
          border: Border.all(width: 0.5, color: Colors.black38),
//          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: FittedBox(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rowChildren),
        ),
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
