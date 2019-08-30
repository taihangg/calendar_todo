import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'common_data_type.dart';

class AxisChart extends StatelessWidget {
  final double screenWidth;
  final List<List<DataPair>> _axisData;
  final List<charts.Series<DataPair, DateTime>> _seriesList = [];

  AxisChart(this.screenWidth, this._axisData) {
    _seriesList.add(
      new charts.Series<DataPair, DateTime>(
        id: '最高气温（白天）',
        data: _axisData[0],
        domainFn: (DataPair row, _) => row.timeStamp,
        measureFn: (DataPair row, _) => row.temp,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
    );
    _seriesList.add(
      new charts.Series<DataPair, DateTime>(
        id: '最低气温（夜晚）',
        data: _axisData[1],
        domainFn: (DataPair row, _) => row.timeStamp,
        measureFn: (DataPair row, _) => row.temp,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      _seriesList,
      animate: false,

      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          zeroBound: false, // 竖坐标是否从0开始
          //dataIsInWholeNumbers: true, // 辅助线不要小数刻度
          //desiredTickCount: 5, //指定辅助线的数量
        ),
        //tickFormatterSpec: simpleCurrencyFormatter,
        //renderSpec: charts.GridlineRendererSpec(lineStyle: charts.LineStyleSpec(dashPattern: [4, 4])), // 虚线
      ),
      defaultRenderer:
          new charts.LineRendererConfig(includePoints: true), // 在数据点上显示一个圆点
      domainAxis: new charts.DateTimeAxisSpec(
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
          day: new charts.TimeFormatterSpec(
              format: 'd', transitionFormat: 'M月d日'),
        ),
      ),
      behaviors: [
        (linearData) {
          return charts.RangeAnnotation(
              List.generate(linearData.length, (int index) {
            return charts.LineAnnotationSegment(
              linearData[index].timeStamp,
              charts.RangeAnnotationAxisType.domain,
              startLabel:
                  '${_axisData[1][index].temp}℃ - ${_axisData[0][index].temp}℃',
              labelStyleSpec: charts.TextStyleSpec(
                  fontSize: screenWidth ~/ 50,
                  color: charts.Color(r: 0, g: 0, b: 255)),
              labelAnchor: charts.AnnotationLabelAnchor.middle,
              labelDirection: charts.AnnotationLabelDirection.vertical,
              labelPosition: charts.AnnotationLabelPosition.inside,
            );
          }));
        }(_axisData[0]),

        /*
        (linearData) {
          return charts.RangeAnnotation(
              List.generate(linearData.length, (int index) {
            return charts.LineAnnotationSegment(
              linearData[index].timeStamp,
              charts.RangeAnnotationAxisType.domain,
              startLabel: "${linearData[index].temp}℃",
              //labelAnchor: charts.AnnotationLabelAnchor.end,
              labelDirection: charts.AnnotationLabelDirection.horizontal,
              //labelPosition: charts.AnnotationLabelPosition.outside,
            );
          }));
        }(axisData[1]),
      */
      ],
    );
  }
}
