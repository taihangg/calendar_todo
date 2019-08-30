import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'common_data_type.dart';
import 'global_data.dart';

class TodoView extends StatefulWidget {
  final double width;
  final Function() onStatusChangeFn;
  TodoView({this.width, this.onStatusChangeFn}) {}

  DateTime _showDate;
  setSelectedDate(DateTime date) {
    _showDate = date;
    if ((null != _taskViewState) && (_taskViewState.mounted)) {
      _taskViewState.setState(() {});
    }
  }

  TodoViewState _taskViewState;

  @override
  createState() {
    _taskViewState = TodoViewState(width);
    return _taskViewState;
  }
}

class TodoViewState extends State<TodoView> {
  final double width;
  TodoViewState(this.width);

  update([DateTime date]) {
    setState(() {});
  }

  TaskEntry _selectedTaskEntry;
  _onTaskEntrySelected(TaskEntry newTaskEntry) {
    _selectedTaskEntry?.selected = false;
    newTaskEntry?.selected = true;
    _selectedTaskEntry = newTaskEntry;
//    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      TodoActionBar(
        width: widget.width,
        showDate: widget._showDate,
        selectedTaskEntry: _selectedTaskEntry,
        onActionDoneFn: () {
//          setState(() {});
        },
        onDeleteTaskFn: () {
          _selectedTaskEntry = null;
//          setState(() {});
        },
      )
    ];

    if (null != widget._showDate) {
      String dateStr = DateFormat('yyyy-MM-dd').format(widget._showDate);
      //var dateTask = testDateMap[dateStr];
      var dateTask = globalData.dateTaskDataMap[dateStr];
      // dateTask.children为该日期的任务list，dateTask本身不是具体的任务
      if ((null != dateTask) && (dateTask.children.isNotEmpty)) {
        assert(dateStr == dateTask.content);
        children.add(Column(
          children: <Widget>[
            Center(
              child: Text("$dateStr", style: TextStyle(fontSize: width / 15)),
            ),
            ExpansionTileRoot(
              width: width,
              entryRoot: dateTask,
              onStatusChangeFn: () {
                setState(() {});
                widget.onStatusChangeFn();
              },
              onTaskEntrySelectedFn: _onTaskEntrySelected,
            ),
          ],
        ));
      } else {
        children.add(Column(
          children: <Widget>[
            Center(
              child: Text("$dateStr", style: TextStyle(fontSize: width / 15)),
            ),
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(10),
              child: Text("当前日期没有任务", style: TextStyle(fontSize: width / 15)),
            ),
          ],
        ));
      }
    } else {
      // 显示所有任务
      var allDateTask = TaskEntry.getAllDateTask(globalData.dateTaskDataMap);
      if (allDateTask.children.isNotEmpty) {
        children.add(ExpansionTileRoot(
          width: width,
          entryRoot: allDateTask,
          onStatusChangeFn: () {
            setState(() {});
            widget.onStatusChangeFn();
          },
          onTaskEntrySelectedFn: _onTaskEntrySelected,
        ));
      } else {
        children.add(Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Text("当前没有任务", style: TextStyle(fontSize: width / 15)),
            ],
          ),
        ));
      }
    }

    assert(null != children);
    return Column(children: children);
  }
}

class ExpansionTileRoot extends StatelessWidget {
  final double width;
  final TaskEntry entryRoot;
  final Function() onStatusChangeFn;
  final Function(TaskEntry newTaskEntry) onTaskEntrySelectedFn;
  ExpansionTileRoot({
    this.width,
    this.entryRoot,
    this.onStatusChangeFn,
    this.onTaskEntrySelectedFn,
  });

  @override
  Widget build(BuildContext context) {
    assert((null != entryRoot) && (entryRoot.children.isNotEmpty));

    var children = <Widget>[];

    children.add(_ExpansionTileItem(
      width,
      [entryRoot],
      [0],
      entryRoot.children[0],
      onStatusChangeFn,
      onTaskEntrySelectedFn,
    ));

    var index = 1;
    entryRoot.children.skip(1).forEach((e) {
      children.add(Divider());
      children.add(
        _ExpansionTileItem(
          width,
          [entryRoot],
          [index],
          entryRoot.children[index],
          onStatusChangeFn,
          onTaskEntrySelectedFn,
        ),
      );
      index++;
    });

    return Column(children: children);
  }
}

class _ExpansionTileItem extends StatelessWidget {
  final double width;
  final List<TaskEntry> _treeLine;
  final List<int> _treeLinePosition;
  final TaskEntry entry;
  final Function() onStatusChangeFn;
  final Function(TaskEntry newTaskEntry) onTaskEntrySelectedFn;
  _ExpansionTileItem(
    this.width,
    this._treeLine,
    this._treeLinePosition,
    this.entry,
    this.onStatusChangeFn,
    this.onTaskEntrySelectedFn,
  ) {
    assert((null != _treeLinePosition) &&
        (0 < _treeLinePosition.length) &&
        (null != entry));
  }

  EventBus _eventBus = EventBus();

  @override
  Widget build(BuildContext context) {
    var treeLine = _treeLine;
    var treeLinePosition = _treeLinePosition;

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
//        globalData.saveTaskDataAndRefreshView();
        onStatusChangeFn();
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
      leadingIcon = Container(
          child: Text(""), padding: EdgeInsets.fromLTRB(width / 20, 0, 0, 0));

      tailStr = (null == entry.state)
          ? "DISABLED"
          : ((true == entry.state) ? "DONE" : "");
    } else {
      midStr = "${entry.finishedChildCount}/${entry.children.length}";
      tailStr = "${(entry.finishedChildCount * 100) ~/ entry.children.length}%";

      leadingIcon = GestureDetector(
          child: entry.expanded
              ? Icon(Icons.keyboard_arrow_down, size: width / 12)
              : Icon(Icons.keyboard_arrow_right, size: width / 12),
          onTap: () {
            entry.expanded = !entry.expanded;
            onStatusChangeFn();
          });
    }
    var children = <Widget>[
      Container(
          padding: EdgeInsets.fromLTRB(
              10.0 * (_treeLinePosition.length - 1), 0, 0, 0),
          color: entry.selected ? Colors.tealAccent : null,
          child: ListTile(
              leading: leadingIcon,
              title: GestureDetector(
                child: Container(
                  child: ListTile(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(degreeString,
                              style: TextStyle(
                                  fontSize: width / 25, color: Colors.orange)),
                          Text(midStr,
                              style: TextStyle(
                                  fontSize: width / 25, color: Colors.orange)),
                          Text(tailStr,
                              style: TextStyle(
                                  fontSize: width / 25, color: Colors.orange)),
                        ]),
                    subtitle: Text(entry.content,
                        style:
                            TextStyle(fontSize: width / 20, color: fontColor)),
                  ),
                ),
                onTap: () {
                  entry.selected = !entry.selected;
                  if (entry.selected) {
                    onTaskEntrySelectedFn(entry);
                  } else {
                    onTaskEntrySelectedFn(null);
                  }
                  onStatusChangeFn();
                },
              ),
              trailing: checkBox))
    ];

    if ((entry.children.isNotEmpty) && (entry.expanded)) {
      var index = 0;
      entry.children.forEach((e) {
        children.add(Divider());
        children.add(_ExpansionTileItem(
          width,
          _treeLine + [e],
          _treeLinePosition + [index],
          e,
          onStatusChangeFn,
          onTaskEntrySelectedFn,
        ));
        index++;
      });
    }

    return Column(children: children);
  }
}

class TodoActionBar extends StatelessWidget {
  final DateTime showDate;
  final TaskEntry selectedTaskEntry;
  final double width;
  final Function() onActionDoneFn;
  final Function() onDeleteTaskFn;

  TodoActionBar({
    this.width,
    this.showDate,
    this.selectedTaskEntry,
    this.onActionDoneFn,
    this.onDeleteTaskFn,
  });

  List<Widget> _getActions(double width, BuildContext context) {
    var actions = <Widget>[];

    actions.add(IconButton(
        icon: Icon(Icons.add_circle_outline, size: width / 15),
        //padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text('添加任务')),
              body: AddNewOrEditTaskPage(
                width: width,
                procType: ProcType.ADD,
                date: showDate,
                selectedTaskEntry: selectedTaskEntry,
                onActionDoneFn: onActionDoneFn,
              ),
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
                return MyDeleteTaskPage(
                    width, selectedTaskEntry, showDate, onDeleteTaskFn);
              });
        }));

    actions.add(IconButton(
        icon: Icon(Icons.border_color, size: width / 17),
        //padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text('修改任务')),
              body: AddNewOrEditTaskPage(
                width: width,
                procType: ProcType.EDIT,
                date: showDate,
                selectedTaskEntry: selectedTaskEntry,
                onActionDoneFn: onActionDoneFn,
              ),
            );
          }));
        }));

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
//        height: screenHeight / 14,
      color: Colors.lightBlueAccent,
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _getActions(width, context),
      ),
    );
  }
}

enum ProcType {
  ADD,
  EDIT,
}

class AddNewOrEditTaskPage extends StatefulWidget {
  final double width;
  final ProcType procType;
  final DateTime date;
  final TaskEntry selectedTaskEntry;
  final Function() onActionDoneFn;

  AddNewOrEditTaskPage({
    this.width,
    this.procType,
    this.date,
    this.selectedTaskEntry,
    this.onActionDoneFn,
  }) {
    assert(null != date);
  }

  @override
  createState() => AddNewOrEditTaskPageState(width);
}

class AddNewOrEditTaskPageState extends State<AddNewOrEditTaskPage> {
  final double width;
  var _taskContent = "";
  DateTime _dt;

  AddNewOrEditTaskPageState(this.width);

  @override
  Widget build(BuildContext contexxt) {
    if ((ProcType.EDIT == widget.procType) &&
        (null == widget.selectedTaskEntry)) {
      return Column(children: [
        Center(
            child: Text("请选择要修改的任务！", style: TextStyle(fontSize: width / 12))),
        RaisedButton(
            child: Text("返回", style: TextStyle(fontSize: width / 18)),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ]);
    }

    if (null == _dt) {
      _dt = widget.date;
    }

    var children = <Widget>[
      TextField(
        autofocus: true,
        maxLines: 10,
        minLines: 10,
        decoration: InputDecoration(
          icon: Icon(Icons.event_note, color: Colors.black),
          hintText: (ProcType.ADD == widget.procType)
              ? "任务内容"
              : widget.selectedTaskEntry.content,
          hintStyle: TextStyle(fontSize: width / 22),
        ),
        style: TextStyle(fontSize: width / 25),
        onChanged: (str) {
          print("onChanged $str");
          _taskContent = str;
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

    if ((ProcType.ADD == widget.procType) &&
        (null != widget.selectedTaskEntry)) {
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

    children
        .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      FlatButton(
          child: Text("放弃",
              style: TextStyle(color: Colors.lightBlue, fontSize: width / 25)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          onHighlightChanged: (b) {
            print("onHighlightChanged $b");
          }),
      RaisedButton(
        child: Text("完成", style: TextStyle(fontSize: width / 25)),
        onPressed: () {
          if (ProcType.ADD == widget.procType) {
            TaskEntry newTE = TaskEntry(_taskContent);
            if (null == widget.selectedTaskEntry) {
              // 添加到该日期下
              final dateStr = DateFormat("yyyy-MM-dd").format(_dt);
              var dateTaskRoot = widget.selectedTaskEntry ??
                  globalData.dateTaskDataMap[dateStr];
              if (null == dateTaskRoot) {
                dateTaskRoot = TaskEntry(dateStr);
                globalData.dateTaskDataMap[dateStr] = dateTaskRoot;
              }
              dateTaskRoot.addChildAndRefreshFatherState(newTE);
            } else {
              // 添加到指定任务下
              widget.selectedTaskEntry.addChildAndRefreshFatherState(newTE);
              widget.selectedTaskEntry.expanded = true;
            }
          } else if (ProcType.EDIT == widget.procType) {
            //修改任务内容
            assert(null != widget.selectedTaskEntry);
            widget.selectedTaskEntry.content = _taskContent;
          } else {
            assert(false);
          }

          globalData.saveTaskDataAndRefreshView();
          Navigator.of(context).pop();
        },
      ),
    ]));

    //return SimpleDialog(children: children);
    return SingleChildScrollView(child: Column(children: children));
  }
}

class MyDeleteTaskPage extends StatelessWidget {
  final double screenWidth;
  final TaskEntry task;
  final DateTime date;
  final Function() onDeleteFn;
  MyDeleteTaskPage(this.screenWidth, this.task, this.date, this.onDeleteFn);

  @override
  Widget build(BuildContext context) {
    if ((null == task) && (null == date)) {
      return AlertDialog(
          title: Center(
              child:
                  Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
          content: SingleChildScrollView(
              child: ListBody(children: [
            //Center(child: Text('')),
            Divider(),
            Center(
                child: Text('请选择 [日期] ',
                    style: TextStyle(fontSize: screenWidth / 25))),
            Center(
                child: Text('或者 [任务] !',
                    style: TextStyle(fontSize: screenWidth / 25))),
            Divider(),
          ])),
          actions: [
            FlatButton(
                child: Container(
                    child: Text("返回",
                        style: TextStyle(fontSize: screenWidth / 25))),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ]);
    }

    assert((null != task) || (null != date));

    TaskEntry dateTask;
    if (null == task) {
      // 没有选中的任务，就要删除当日的所有任务
      final dateStr = DateFormat("yyyy-MM-dd").format(date);
      dateTask = globalData.dateTaskDataMap[dateStr];

      if ((null == dateTask) || dateTask.children.isEmpty) {
        // 如果当日也没有任务，就返回
        return AlertDialog(
            title: Center(
                child:
                    Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
            content: SingleChildScrollView(
                child: ListBody(children: [
              //Center(child: Text('')),
              Divider(),
              Center(
                  child: Text("$dateStr 没有任务",
                      style: TextStyle(fontSize: screenWidth / 25))),
              Divider(),
            ])),
            actions: [
              FlatButton(
                  child: Container(
                      child: Text("返回",
                          style: TextStyle(fontSize: screenWidth / 25))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ]);
      }
    }

    List<Widget> list = [Divider()];
    if (null != task) {
      list.add(Text("${task.getDegreeString()}  ${task.content}",
          style: TextStyle(fontSize: screenWidth / 25)));
      list.add(Divider());
    } else {
      dateTask.children.forEach((e) {
        list.add(Text("${e.getDegreeString()}  ${e.content}",
            style: TextStyle(fontSize: screenWidth / 25)));
        list.add(Divider());
      });
    }

    return AlertDialog(
        title: Center(
            child: Text("删除任务", style: TextStyle(fontSize: screenWidth / 25))),
        content: SingleChildScrollView(child: ListBody(children: list)),
        actions: [
          FlatButton(
              child: Container(
                  alignment: Alignment.center,
                  child:
                      Text("取消", style: TextStyle(fontSize: screenWidth / 25))),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          FlatButton(
              child: Container(
                  alignment: Alignment.center,
                  child:
                      Text("删除", style: TextStyle(fontSize: screenWidth / 25))),
              onPressed: () {
                if (null != task) {
                  // 删除选择任务自己，不需要通知别的选择任务修改选中状态
                  task.deleteSelfAndRefreshFatherState();
                  onDeleteFn();
                } else {
                  dateTask.children.clear();
                }
                globalData.saveTaskDataAndRefreshView();
                Navigator.of(context).pop();
              }),
        ]);
  }
}
