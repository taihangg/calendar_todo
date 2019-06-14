//import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'my_axis_chart.dart';
import 'my_global_data.dart';
//import 'my_weather_data.dart';

class MyWeatherPage extends StatefulWidget {
  final double screenWidth;
  MyWeatherPage(this.screenWidth);

  @override
  State<StatefulWidget> createState() => _MyWeatherPageState();
}

class _MyWeatherPageState extends State<MyWeatherPage> {
  @override
  initState() {
    super.initState();
    _initWeatherData();
  }

  String _statusText = "正在获取天气数据……";
  String _delayText = "";

  _timedTask(int sec, Future<void> Function() fn) async {
    if (sec <= 0) {
      _statusText = "正在获取天气数据……";
      _delayText = "";
      setState(() {});
      await fn();
    } else {
      _delayText = "$sec秒后重新更新";
      setState(() {});
      Future.delayed(Duration(seconds: 1), () async {
        _timedTask(sec - 1, fn);
      });
    }
  }

  Future<void> _initWeatherData() async {
    if (false == MyGlobalData.data.weatherData.ready) {
//      _statusText = "正在获取数据……";
//      _delayText = "";
//      setState(() {});

      await Future.delayed(Duration(seconds: 1), () async {});

      await MyGlobalData.data.weatherData.getDataFromNetwork();

//      MyGlobalData.data.weatherData.ready = false; // for test
      if (true == MyGlobalData.data.weatherData.ready) {
        setState(() {});
      } else {
        // 定期继续更新
        _statusText = "从网络获取天气数据失败";
        _timedTask(3, _initWeatherData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MyGlobalData.data.weatherData.ready
          ? RotatedBox(
              quarterTurns: 1,
              child: MyAxisChart(widget.screenWidth, MyGlobalData.data.weatherData.axisData),
            )
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_statusText, style: TextStyle(fontSize: 30)),
              Text("", style: TextStyle(fontSize: 30)),
              Text(_delayText, style: TextStyle(fontSize: 30)),
            ]),
    );
  }
}
