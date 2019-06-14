import 'package:flutter/material.dart';

class TitleDay extends StatelessWidget {
  final double screenWidth;

  TitleDay(this.num, this.screenWidth)
      : assert(1 <= num),
        assert(num <= 7);
  final int num;

  final List<String> _weekDayName = ["一", "二", "三", "四", "五", "六", "天"];

  @override
  Widget build(BuildContext context) {
    return Container(
        width: screenWidth / 8,
        height: screenWidth / 8 / 10 * 6,
        decoration: BoxDecoration(
          color: Colors.blue[300],
          border: Border.all(width: 0.5, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Center(
            child: FittedBox(
                child:
                    Text(_weekDayName[num - 1], style: TextStyle(fontSize: screenWidth / 20, color: Colors.black)))));
  }
}

class DayBox extends StatelessWidget {
  final double screenWidth;
  final DateTime date;
  final bool showNoteIcon;
  final bool noteActive;
  final bool selected;
  final bool baskgroundGrey;
  final bool isToday;
  final String gregorianStr;
  final Color gregorianColor;
  final String lunarStr;
  final Color lunarColor;
  final Function(DateTime, bool) onSelectCallback;

  DayBox(this.date, this.screenWidth,
      {this.showNoteIcon = false,
      this.noteActive = true,
      this.selected = false,
      this.baskgroundGrey = false,
      this.isToday = false,
      this.gregorianStr,
      this.gregorianColor,
      this.lunarStr,
      this.lunarColor,
      this.onSelectCallback}) {
    if (1 == date.day) {
      print("$date lunarStr=$lunarStr");
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("xxx _DayBox build ${date.day}");

    Color backgroundColor;
    if (true == isToday) {
      backgroundColor = selected ? Colors.yellowAccent : Colors.yellow;
    } else if (baskgroundGrey) {
      backgroundColor = Colors.grey[300];
    }

    List<Widget> stackChildren = [];

    // 用一个单独的Container来处理选中时候的效果
    // 如果直接在显示层处理选中效果，点击选中的时候显示内容会有细微的大小变化
    stackChildren.add(Container(
        decoration: BoxDecoration(
      color: backgroundColor,
      border: Border.all(width: selected ? 2.0 : 0.1, color: selected ? Colors.red : Colors.black38),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    )));

    // 日期数字
    stackChildren.add(Container(
        alignment: Alignment.center,
        child: Text("${date.day}", style: new TextStyle(fontSize: screenWidth / 20, color: Colors.black))));

    // 添加任务图标
    if (showNoteIcon) {
      stackChildren.add(Container(
          alignment: Alignment.topRight,
          child: Icon(Icons.event_note, size: screenWidth / 25, color: noteActive ? Colors.orange : Colors.grey)));
    }

    // 需要显示月份的情况
    if (null != gregorianStr) {
      stackChildren.add(Container(
          alignment: Alignment.topCenter,
          child:
              Text(gregorianStr, style: TextStyle(color: gregorianColor ?? Colors.grey, fontSize: screenWidth / 38))));
    }
    if (null != lunarStr) {
      stackChildren.add(Container(
          alignment: Alignment.bottomCenter,
          child: Text(lunarStr, style: TextStyle(color: lunarColor ?? Colors.grey, fontSize: screenWidth / 38))));
    }

    return GestureDetector(
        onTap: () {
          if (null != onSelectCallback) {
            onSelectCallback(date, !selected);
          }
        },
        child: Container(width: screenWidth / 8, height: screenWidth / 8, child: Stack(children: stackChildren)));
  }
}
