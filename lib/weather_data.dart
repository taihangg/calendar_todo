import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:http/http.dart' as http;

import 'common_data_type.dart';

class WeatherDataItem {
  int year = 0;
  int month = 0;
  int day = 0;

  String weekDay = "";
  int highTemp = 0;
  int lowTemp = 0;
}

class WeatherData {
  WeatherData();

  List<WeatherDataItem> _dataList = List.generate(15, (int index) {
    return WeatherDataItem();
  });
  List<WeatherDataItem> get dataList => _dataList;

  var _axisDataReady = false;
  var _axisData = [List<DataPair>(), List<DataPair>()];
  bool get ready => _axisDataReady;
//  set ready(bool r) => _axisDataReady = r;

  get axisData => _axisData;
  _weatherData2AxisData() {
    if (false == _axisDataReady) {
      _axisData[0].clear();
      _axisData[1].clear();

      dataList.forEach((WeatherDataItem w) {
        _axisData[0]
            .add(DataPair(DateTime(w.year, w.month, w.day), w.highTemp));
        _axisData[1].add(DataPair(DateTime(w.year, w.month, w.day), w.lowTemp));
      });
      _axisDataReady = true;
    }
  }

  var _networkDataReady = false;

  getDataFromNetwork() async {
    print("从网络获取天气数据");
    String url;
//    url= "http://qq.ip138.com/weather/sichuan/chengdu_15tian.htm";
    url = "http://qq.ip138.com/weather/chongqing/dazu_15tian.htm";

    print(url);

    // OK
    try {
      final response = await http.get(url);
      String data = gbk.decode(response.bodyBytes);
      _parseDateData(data);
      _parseTemperatureData(data);
      _networkDataReady = true;

      _weatherData2AxisData();
    } catch (e) {
      print("从网络获取数据失败: $e");
    }
  }

  _parseDateData(String data) {
    // <td width="20%">2019-5-19 星期日</td>
    var dateRE =
        RegExp(r'<td[^>]*>([\d]{4})-([\d]{1,2})-([\d]{1,2}) ([^<]*)</td>');
    var dateMatches = dateRE.allMatches(data);

    var i = 0;
    for (var match in dateMatches) {
      assert(4 == match.groupCount);

      _dataList[i].year = int.parse(match.group(1));
      _dataList[i].month = int.parse(match.group(2));
      _dataList[i].day = int.parse(match.group(3));
      _dataList[i].weekDay = match.group(4);

      i++;
    }
  }

  _parseTemperatureData(String data) {
    //<td>24℃～18℃</td>
    var tempRE = RegExp(r'<td>(-?[\d]{1,2})℃～*(-?[\d]{1,2})℃</td>');
    var tempMatches = tempRE.allMatches(data);

    var i = 0;
    for (var match in tempMatches) {
      assert(2 == match.groupCount);

      _dataList[i].highTemp = int.parse(match.group(1));
      _dataList[i].lowTemp = int.parse(match.group(2));

      i++;
    }
  }
}
