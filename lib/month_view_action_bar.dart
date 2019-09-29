import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'festirval_editor.dart';

class MonthViewActionBar extends StatelessWidget {
  final double screenWidth;
  final DateTime showMonth;
  final Function(DateTime month) onDateChangeFn;
  final String Function() getFestivalText;
  final String Function(String) onSaveFn;
  MonthViewActionBar({
    this.screenWidth,
    this.showMonth,
    this.onDateChangeFn,
    this.getFestivalText,
    this.onSaveFn,
  });

  @override
  Widget build(BuildContext context) {
    var lineTitle = <Widget>[];

    lineTitle.add(Container(
      width: screenWidth * 7 / 10,
      //alignment: Alignment.center,
      //padding: EdgeInsets.fromLTRB(screenWidth / 100, 0, screenWidth / 100, 0),
//      color: Colors.lightBlueAccent,
      child: RaisedButton(
//        color: Colors.lightBlueAccent,
        child: Text(
          "${showMonth.year}年" +
              ((showMonth.month < 10) ? "  " : "") +
              "${showMonth.month}月 " +
              ((showMonth.day < 10) ? " " : "") +
              "${showMonth.day}日",
          style: TextStyle(fontSize: screenWidth / 15, color: Colors.black),
        ),
        onPressed: () async {
//          var pickDate = await showDatePicker(
//            context: context,
//            initialDate: showMonth,
//            firstDate: DateTime(1900),
//            lastDate: DateTime(2100),
//            locale: Localizations.localeOf(context),
//          );
//
//          if (null != pickDate) {
//            onMonthChangeFn(pickDate);
//          }

//          showCupertinoDialog
          await showCupertinoModalPopup(
            //通过showDialog方法展示alert弹框
            context: context,
            builder: (context) {
              return Container(
//                width: screenWidth,
                height: 300,
//                color: Colors.red,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime pickDate) {
                    if (null != pickDate) {
                      onDateChangeFn(pickDate);
                    }
                  },
                  initialDateTime: showMonth,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime(2100),
                ),
              );
            },
          );
        },
      ),
    ));

//    lineTitle.add(
//      SizedBox(width: screenWidth / 50),
//    );

    lineTitle.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Scaffold(
                  appBar: AppBar(title: Text('添加节日')),
                  body: FestirvalEditor(getFestivalText(), onSaveFn),
                );
              }));
            },
            child: Container(
              width: screenWidth / 8,
              height: screenWidth / 8,
              decoration: BoxDecoration(
//                color: Colors.yellowAccent,
                border: Border.all(width: 2.0, color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: FittedBox(
                child: Text("节日\n管理",
                    style: TextStyle(
                        color: Colors.indigoAccent,
                        fontSize: screenWidth / 15)),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 4 / 5),
          GestureDetector(
            onTap: () {
              onDateChangeFn(DateTime.now());
            },
            child: Container(
              width: screenWidth / 8,
              height: screenWidth / 8,
              decoration: BoxDecoration(
                color: Colors.yellowAccent,
                border: Border.all(width: 2.0, color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: FittedBox(
                child: Text("返回\n今日",
                    style: TextStyle(
                        color: Colors.red, fontSize: screenWidth / 15)),
              ),
            ),
          ),
        ],
      ),
    );

    var lineAction = <Widget>[];
    lineAction.add(
      Container(
        child: RaisedButton(
          color: Colors.orange,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(child: Icon(Icons.arrow_back_ios)),
              Text("上一年", style: TextStyle(fontSize: screenWidth / 25)),
            ],
          ),
          onPressed: () {
            final lastMonth = DateTime(showMonth.year - 1, showMonth.month, 1);
            onDateChangeFn(lastMonth);
          },
        ),
      ),
    );
    lineAction.add(SizedBox(width: screenWidth / 500));
    lineAction.add(
      Container(
        child: RaisedButton(
          color: Colors.orange,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("下一年", style: TextStyle(fontSize: screenWidth / 25)),
            Icon(Icons.arrow_forward_ios),
          ]),
          onPressed: () {
            final nextMonth = DateTime(showMonth.year + 1, showMonth.month, 1);
            onDateChangeFn(nextMonth);
          },
        ),
      ),
    );

    lineAction.add(SizedBox(width: screenWidth / 50));
    lineAction.add(
      Container(
        //color: Colors.orange,
        child: RaisedButton(
          color: Colors.cyan,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(child: Icon(Icons.arrow_back_ios)),
              Text("上一月", style: TextStyle(fontSize: screenWidth / 25)),
            ],
          ),
          onPressed: () {
            var lastMonth =
                DateTime(showMonth.year, showMonth.month - 1, showMonth.day);
            if (lastMonth.day != showMonth.day) {
              lastMonth = DateTime(showMonth.year, showMonth.month, 0);
            }

            onDateChangeFn(lastMonth);
          },
        ),
      ),
    );
    lineAction.add(SizedBox(width: screenWidth / 500));
    lineAction.add(
      Container(
//        color: Colors.orange,
        child: RaisedButton(
          color: Colors.cyan,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("下一月", style: TextStyle(fontSize: screenWidth / 25)),
            Icon(Icons.arrow_forward_ios),
          ]),
          onPressed: () {
            var nextMonth =
                DateTime(showMonth.year, showMonth.month + 1, showMonth.day);
            if (nextMonth.day != showMonth.day) {
              nextMonth = DateTime(showMonth.year, showMonth.month + 2, 0);
            }
            onDateChangeFn(nextMonth);
          },
        ),
      ),
    );

    return FittedBox(
      child: Container(
        width: screenWidth * 8 / 9,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          //color: Colors.redAccent,
          border: Border.all(width: 0.5, color: Colors.black38),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: FittedBox(
            child: Column(
          children: [
            Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: lineAction),
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: lineTitle,
            ),
          ],
        )),
      ),
    );
  }
}
