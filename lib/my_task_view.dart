import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'my_common_data_type.dart';
import 'my_global_data.dart';

class MyTaskView extends StatefulWidget {
  final double width;
  DateTime Function() getSelectedDateFn;

  MyTaskView(this.width, this.getSelectedDateFn) {
    assert(null != getSelectedDateFn);
  }

  @override
  createState() {
    var s = MyTaskViewState(width);
    MyGlobalData.data.taskViewState = s;
    return s;
  }
}

class MyTaskViewState extends State<MyTaskView> {
  final double width;
  MyTaskViewState(this.width);

  update([DateTime date]) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var child;
    final selectedDate = widget.getSelectedDateFn();

    if (null != selectedDate) {
      String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      //var dateTask = testDateMap[dateStr];
      var dateTask = MyGlobalData.data.dateTaskDataMap[dateStr];
      // dateTask.children为该日期的任务list，dateTask本身不是具体的任务
      if ((null != dateTask) && (dateTask.children.isNotEmpty)) {
        assert(dateStr == dateTask.content);
        child = MyExpansionTileRoot(width, dateTask);
      } else {
        child = Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.all(10),
            child: Text("$dateStr 没有计划任务", style: TextStyle(fontSize: width / 15)));
      }
    } else {
      child = Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(10),
          child: Column(children: [
            Text("选中日期", style: TextStyle(fontSize: width / 15)),
            Text("可查看当日任务", style: TextStyle(fontSize: width / 15))
          ]));
    }

    assert(null != child);
    return child;
  }
}

class MyExpansionTileRoot extends StatelessWidget {
  final double width;
  final MyTaskEntry entryRoot;
  MyExpansionTileRoot(this.width, this.entryRoot);

  @override
  Widget build(BuildContext context) {
    assert((null != entryRoot) && (entryRoot.children.isNotEmpty));

    var children = <Widget>[];

    children.add(_MyExpansionTileItem(width, [entryRoot], [0], entryRoot.children[0]));

    var index = 1;
    entryRoot.children.skip(1).forEach((e) {
      children.add(Divider());
      children.add(_MyExpansionTileItem(width, [entryRoot], [index], entryRoot.children[index]));
      index++;
    });

    return Column(children: children);
  }
}

class _MyExpansionTileItem extends StatefulWidget {
  final double width;
  final List<MyTaskEntry> _treeLine;
  final List<int> _treeLinePosition;
  final MyTaskEntry _entry;

  _MyExpansionTileItem(this.width, this._treeLine, this._treeLinePosition, this._entry) {
    assert((null != _treeLinePosition) && (0 != _treeLinePosition.length) && (null != _entry));
  }
  @override
  createState() => MyExpansionTileItemState(width);
}

class MyExpansionTileItemState extends State<_MyExpansionTileItem> {
  final double width;
  bool _selected = false;
  MyExpansionTileItemState(this.width);

  @override
  Widget build(BuildContext context) {
    var treeLine = widget._treeLine;
    var treeLinePosition = widget._treeLinePosition;
    var entry = widget._entry;

    assert((null != treeLine) &&
        (0 != treeLine.length) &&
        (null != treeLinePosition) &&
        (0 != treeLinePosition.length) &&
        (null != entry));

    String degreeString = entry.getDegreeString();

    var checkBox = Checkbox(
      value: entry.state,
      tristate: true,
      onChanged: (newState) {
        // 如果tristate为true，state的状态变化顺序是: false->ture->null->false
        //MyTaskEntry.updateTreeLineState(treeLine.sublist(0)..add(entry), newState);
        entry.updateTreeLineState_new(newState);
        MyGlobalData.data.saveTaskDataAndRefreshView();
      },
    );

    var fontColor = Colors.black;
    if (null == entry.state) {
      fontColor = Colors.grey;
    } else if ((entry.children.isNotEmpty) && (!entry.expanded)) {
      fontColor = Colors.lightBlue;
    }

    Widget leadingIcon;

    assert(null != entry.children);
    var midStr = "";
    var tailStr = "";
    if (entry.children.isEmpty) {
      leadingIcon = Container(child: Text(""), padding: EdgeInsets.fromLTRB(width / 20, 0, 0, 0));

      tailStr = (null == entry.state) ? "DISABLED" : ((true == entry.state) ? "DONE" : "");
    } else {
      midStr = "${entry.finishedChildCount}/${entry.children.length}";
      tailStr = "${(entry.finishedChildCount * 100) ~/ entry.children.length}%";

      leadingIcon = GestureDetector(
          child: entry.expanded
              ? Icon(Icons.keyboard_arrow_down, size: width / 12)
              : Icon(Icons.keyboard_arrow_right, size: width / 12),
          onTap: () {
            entry.expanded = !entry.expanded;
            setState(() {});
          });
    }
    var children = <Widget>[
      Container(
          padding: EdgeInsets.fromLTRB(10.0 * (widget._treeLinePosition.length - 1), 0, 0, 0),
          child: ListTile(
              leading: leadingIcon,
              title: GestureDetector(
                  child: Container(
                      color: _selected ? Colors.black12 : null,
                      child: ListTile(
                        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(degreeString, style: TextStyle(fontSize: width / 25, color: Colors.orange)),
                          Text(midStr, style: TextStyle(fontSize: width / 25, color: Colors.orange)),
                          Text(tailStr, style: TextStyle(fontSize: width / 25, color: Colors.orange)),
                        ]),
                        subtitle: Text(entry.content, style: TextStyle(fontSize: width / 20, color: fontColor)),
                      )),
                  onTap: () {
                    _selected = !_selected;
                    if (_selected) {
                      if (null != MyGlobalData.data.selectedExpansionItemState) {
                        MyGlobalData.data.selectedExpansionItemState._selected = false;
                        assert(true == MyGlobalData.data.selectedExpansionItemState.mounted);
                        MyGlobalData.data.selectedExpansionItemState.setState(() {});
                      }
                      MyGlobalData.data.selectedTaskEntry = entry;
                      MyGlobalData.data.selectedExpansionItemState = this;
                      if (!isSameMonth(MyGlobalData.data.monthViewShowDate, MyGlobalData.data.selectedDate)) {
                        // 返回选择的任务的日期的月
                        MyGlobalData.data.updateMonthViewShowDate(MyGlobalData.data.selectedDate);
                      }
                    } else {
                      MyGlobalData.data.selectedTaskEntry = null;
                      MyGlobalData.data.selectedExpansionItemState = null;
                    }
                    setState(() {});
                  }),
              trailing: checkBox))
    ];

    if ((entry.children.isNotEmpty) && (entry.expanded)) {
      var index = 0;
      entry.children.forEach((e) {
        children.add(Divider());
        children.add(_MyExpansionTileItem(width, widget._treeLine + [e], widget._treeLinePosition + [index], e));
        index++;
      });
    }

    return Column(children: children);
  }
}

enum ProcType {
  ADD,
  EDIT,
}

class MyAddNewOrEditTaskPage extends StatefulWidget {
  final double width;
  final ProcType pt;
  final DateTime dt;
  final MyTaskEntry selectedTaskEntry;

  MyAddNewOrEditTaskPage(this.width, this.pt, this.dt, this.selectedTaskEntry) {
    assert(null != dt);
  }

  @override
  createState() => MyAddNewOrEditTaskPageState(width);
}

class MyAddNewOrEditTaskPageState extends State<MyAddNewOrEditTaskPage> {
  final double width;
  var _taskContent = "";
  DateTime _dt;

  MyAddNewOrEditTaskPageState(this.width);

  @override
  Widget build(BuildContext contexxt) {
    if ((ProcType.EDIT == widget.pt) && (null == widget.selectedTaskEntry)) {
      return Column(children: [
        Center(child: Text("请选择要修改的任务！", style: TextStyle(fontSize: width / 12))),
        RaisedButton(
            child: Text("返回", style: TextStyle(fontSize: width / 18)),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ]);
    }

    if (null == _dt) {
      _dt = widget.dt;
    }

    var children = <Widget>[
      TextField(
        autofocus: true,
        maxLines: 10,
        minLines: 10,
        decoration: InputDecoration(
          icon: new Icon(Icons.event_note, color: Colors.black),
          hintText: (ProcType.ADD == widget.pt) ? "任务内容" : widget.selectedTaskEntry.content,
          hintStyle: TextStyle(fontSize: width / 22),
        ),
        style: TextStyle(fontSize: width / 25),
        onChanged: (str) {
          print("onChanged $str");
          _taskContent = str;
        },
        onTap: () {
          print("onTap");
        },
      ),
      Row(children: [
        Icon(Icons.today),
        Container(
            alignment: Alignment.center,
            child: SimpleDialogOption(
              child: Text(
                (null != _dt) ? DateFormat('yyyy年MM月dd日').format(_dt) : "",
                style: TextStyle(fontSize: width / 20),
              ),
              onPressed: () async {
                var pickDate = await showDatePicker(
                  context: context,
                  initialDate: _dt,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  locale: Localizations.localeOf(context),
                );
                if (null != pickDate) {
                  _dt = pickDate;
                  setState(() {});
                }
              },
            )),
      ]),
      Divider(),
    ];

    if ((ProcType.ADD == widget.pt) && (null != widget.selectedTaskEntry)) {
      children.add(TextField(
        enabled: false,
        decoration: InputDecoration(
          icon: Text("上级\n任务"),
          hintText: widget.selectedTaskEntry.content,
          hintStyle: TextStyle(fontSize: width / 25),
        ),
        style: TextStyle(fontSize: width / 25),
      ));
    }

    children.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      FlatButton(
          child: Text("放弃", style: TextStyle(color: Colors.lightBlue, fontSize: width / 25)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          onHighlightChanged: (b) {
            print("onHighlightChanged $b");
          }),
      RaisedButton(
          child: Text("完成", style: TextStyle(fontSize: width / 25)),
          onPressed: () {
            if (ProcType.ADD == widget.pt) {
              MyTaskEntry newTE = MyTaskEntry(_taskContent);
              if (null == widget.selectedTaskEntry) {
                // 添加到该日期下
                final dateStr = DateFormat("yyyy-MM-dd").format(_dt);
                var dateTaskRoot = widget.selectedTaskEntry ?? MyGlobalData.data.dateTaskDataMap[dateStr];
                if (null == dateTaskRoot) {
                  dateTaskRoot = MyTaskEntry(dateStr);
                  MyGlobalData.data.dateTaskDataMap[dateStr] = dateTaskRoot;
                }
                dateTaskRoot.addChildAndRefreshFatherState(newTE);
              } else {
                // 添加到指定任务下
                widget.selectedTaskEntry.addChildAndRefreshFatherState(newTE);
              }
            } else if (ProcType.EDIT == widget.pt) {
              //修改任务内容
              assert(null != widget.selectedTaskEntry);
              widget.selectedTaskEntry.content = _taskContent;
            } else {
              assert(false);
            }

            MyGlobalData.data.saveTaskDataAndRefreshView();
            Navigator.of(context).pop();
          },
          onHighlightChanged: (b) {
            print("onHighlightChanged $b");
          }),
    ]));

    //return SimpleDialog(children: children);
    return SingleChildScrollView(child: Column(children: children));
  }
}

class MyDeleteTaskPage extends StatelessWidget {
  final double screenWidth;
  final MyTaskEntry te;
  final DateTime dt;
  MyDeleteTaskPage(this.screenWidth, this.te, this.dt);

  @override
  Widget build(BuildContext context) {
    if ((null == te) && (null == dt)) {
      return AlertDialog(
          title: Center(child: Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
          content: SingleChildScrollView(
              child: ListBody(children: [
            //Center(child: Text('')),
            Divider(),
            Center(child: Text('请选择 [日期] ', style: TextStyle(fontSize: screenWidth / 25))),
            Center(child: Text('或者 [任务] !', style: TextStyle(fontSize: screenWidth / 25))),
            Divider(),
          ])),
          actions: [
            FlatButton(
                child: Container(child: Text("返回", style: TextStyle(fontSize: screenWidth / 25))),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    }

    final dateStr = DateFormat("yyyy-MM-dd").format(dt);
    var dateTask = MyGlobalData.data.dateTaskDataMap[dateStr];

    if ((null == te) && ((null == dateTask) || dateTask.children.isEmpty)) {
      return AlertDialog(
          title: Center(child: Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
          content: SingleChildScrollView(
              child: ListBody(children: [
            //Center(child: Text('')),
            Divider(),
            Center(child: Text("$dateStr 没有任务", style: TextStyle(fontSize: screenWidth / 25))),
            Divider(),
          ])),
          actions: [
            FlatButton(
                child: Container(child: Text("返回", style: TextStyle(fontSize: screenWidth / 25))),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    }

    List<Widget> list = [Divider()];
    if (null != te) {
      list.add(Text("${te.getDegreeString()}  ${te.content}", style: TextStyle(fontSize: screenWidth / 25)));
      list.add(Divider());
    } else {
      dateTask.children.forEach((e) {
        list.add(Text("${e.getDegreeString()}  ${e.content}", style: TextStyle(fontSize: screenWidth / 25)));
        list.add(Divider());
      });
    }

    return AlertDialog(
        title: Center(child: Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
        content: SingleChildScrollView(child: ListBody(children: list)),
        actions: [
          FlatButton(
              child: Container(
                  alignment: Alignment.center, child: Text("取消", style: TextStyle(fontSize: screenWidth / 25))),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          FlatButton(
              child: Container(
                  alignment: Alignment.center, child: Text("删除", style: TextStyle(fontSize: screenWidth / 25))),
              onPressed: () {
                if (null != te) {
                  te.deleteSelfAndRefreshFatherState();
                  MyGlobalData.data.selectedTaskEntry = null;
                  MyGlobalData.data.selectedExpansionItemState = null;
                } else {
                  dateTask.children.clear();
                }
                MyGlobalData.data.saveTaskDataAndRefreshView();
                Navigator.of(context).pop();
              }),
        ]);
  }
}

class MyTaskActionBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  MyTaskActionBar(this.screenWidth, this.screenHeight);

  static _getActions(double width, BuildContext context) {
    var actions = <Widget>[];

    actions.add(IconButton(
        icon: Icon(Icons.add_circle_outline, size: width / 15),
        //padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text('添加任务')),
              body: MyAddNewOrEditTaskPage(
                  width,
                  ProcType.ADD,
                  MyGlobalData.data.selectedDate ?? MyGlobalData.data.monthViewShowDate,
                  MyGlobalData.data.selectedTaskEntry),
            );
          }));
        }));

    actions.add(IconButton(
        icon: Icon(Icons.delete_forever, size: width / 15),
        //padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        onPressed: () {
          showDialog<Widget>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return MyDeleteTaskPage(width, MyGlobalData.data.selectedTaskEntry, MyGlobalData.data.selectedDate);
              });
        }));

    actions.add(IconButton(
        icon: Icon(Icons.border_color, size: width / 17),
        //padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return new Scaffold(
                appBar: new AppBar(title: new Text('修改任务')),
                body: MyAddNewOrEditTaskPage(
                    width,
                    ProcType.EDIT,
                    MyGlobalData.data.selectedDate ?? MyGlobalData.data.monthViewShowDate,
                    MyGlobalData.data.selectedTaskEntry));
          }));
        }));

    return actions;
  }

  static AppBar makeAppBar(double width, BuildContext context) {
    return AppBar(title: Text('任务月历'), actions: _getActions(width, context));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//        height: screenHeight / 14,
        color: Colors.lightBlueAccent,
        alignment: Alignment.bottomCenter,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _getActions(screenWidth, context)
            /*[
          Text('任务月历', style: TextStyle(fontSize: screenWidth / 22)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getActions(screenWidth, context),
          ),
        ]*/
            ));
  }
}
