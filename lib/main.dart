import 'dart:ui';

import 'package:flutter/material.dart';

import 'my_global_data.dart';
import 'my_month_task_page.dart';
import 'my_navigation_bar.dart';
import 'my_weather_view.dart';

void main() {
  print("xxx main");

  MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  double _width = mediaQuery.size.width;
  double _height = mediaQuery.size.height;
  double _topbarH = mediaQuery.padding.top;
  double _botbarH = mediaQuery.padding.bottom;
  double _pixelRatio = mediaQuery.devicePixelRatio;
  print("$_width $_height $_topbarH $_botbarH $_pixelRatio");

  MyGlobalData.data.updateMonthViewShowDate(DateTime.now());

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
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  _MyHomePage({Key key}) : super(key: key);

  @override
  createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<_MyHomePage> {
  double _screenWidth;
  double _screenHeight;

  _MyHomePageState() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
  }
  int _bottomBarSelectIndex = 0; // 默认第一个

  Widget _getBody() {
    switch (_bottomBarSelectIndex) {
      case 0:
        {
          return MyMonthViewPage(_screenWidth, _screenHeight);
          break;
        }
      case 1:
        {
          return MyWeatherPage(_screenWidth);
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

    var myTabBar = TabBar(isScrollable: false, tabs: [
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
    var myAppBar = AppBar(
      //leading: Text('Tabbed AppBar'),
      //title: const Text('Tabbed AppBar'),
      title: myTabBar,
//      bottom: myTabBar,
    );

    var myTabBarView = TabBarView(
      children: [
        MyMonthViewPage(_screenWidth, _screenHeight),
        MyWeatherPage(_screenWidth),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        /*appBar: (0 == _bottomBarSelectIndex)
          ? MyTaskActionBar.makeAppBar(_screenWidth, context)
          : null,*/
        appBar: myAppBar,
//      body: _getBody(),
        body: myTabBarView,
//      bottomNavigationBar: bottomNavigateBar,
      ),
    );
  }
}
