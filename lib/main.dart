import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'month_todo_page.dart';
import 'my_navigation_bar.dart';
import 'weather_view.dart';

import 'month_view.dart';
import 'global_data.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';

void main() {
  print("xxx main");

  MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  double _width = mediaQuery.size.width;
  double _height = mediaQuery.size.height;
  double _topbarH = mediaQuery.padding.top;
  double _botbarH = mediaQuery.padding.bottom;
  double _pixelRatio = mediaQuery.devicePixelRatio;
  print("$_width $_height $_topbarH $_botbarH $_pixelRatio");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '任务月历',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  _HomePage({Key key}) : super(key: key);

  @override
  createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<_HomePage> {
  double _screenWidth;
  double _screenHeight;

  _HomePageState() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }
  int _bottomBarSelectIndex = 0; // 默认第一个

  Widget _getBody() {
    switch (_bottomBarSelectIndex) {
      case 0:
        {
          return MonthTaskPage(_screenWidth, _screenHeight);
          break;
        }
      case 1:
        {
          return WeatherPage(_screenWidth);
          break;
        }

      default:
        assert(false);
        return null;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigateBar = Container(
//        width: _screenWidth,
        height: _screenHeight / 28 * 3,
        child: MyBottomNavigationBar((int index) {
          if (_bottomBarSelectIndex != index) {
            _bottomBarSelectIndex = index;
            setState(() {});
          }
        }));

    var tabBar = TabBar(isScrollable: false, tabs: [
      Tab(
//        text: "日历",
        icon: Icon(Icons.border_all, size: _screenWidth / 15),
//        child: Text("日历", style: TextStyle(fontSize: _screenWidth / 15)),
      ),
      Tab(
//          text: "天气",
        icon: Icon(Icons.wb_sunny, size: _screenWidth / 15),
//        child: Text("天气", style: TextStyle(fontSize: _screenWidth / 15)),
      )
    ]);
    var appBar = AppBar(
      //leading: Text('Tabbed AppBar'),
      //title: const Text('Tabbed AppBar'),
      title: tabBar,
//      bottom: myTabBar,
    );

    NoteIconType _noteIconTypeFn(DateTime date) {
      final fmt = DateFormat('yyyy-MM-dd');

      final dateStr = fmt.format(date);
      final dateTask = globalData.dateTaskDataMap[dateStr];
      if ((null == dateTask) || (dateTask.children.isEmpty)) {
        return NoteIconType.none;
      }

      if (dateTask.children.length == dateTask.finishedChildCount) {
        return NoteIconType.grey;
      }

      return NoteIconType.colorful;
    }

    var tabBarView = TabBarView(
      children: [
        MonthTaskPage(_screenWidth, _screenHeight),
        WeatherPage(_screenWidth),
      ],
    );

//    return MonthView(
//      width: _screenWidth,
//      onDateSelectedFn: (DateTime selectedDate) {
//        globalData.selectedDate = selectedDate;
//      },
//      onMonthChangeFn: (DateTime showMonth) {
//        globalData.monthViewShowDate = showMonth;
//      },
//      initDate: null,
//      noteIconTypeFn: _noteIconTypeFn,
//    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        /*appBar: (0 == _bottomBarSelectIndex)
          ? MyTaskActionBar.makeAppBar(_screenWidth, context)
          : null,*/
        appBar: appBar,
//      body: _getBody(),
        body: tabBarView,
//      bottomNavigationBar: bottomNavigateBar,
      ),
    );
  }
}
