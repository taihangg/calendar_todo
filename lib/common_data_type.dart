/// Sample time series data type.
class DataPair {
  final DateTime timeStamp;
  final int temp;
  DataPair(this.timeStamp, this.temp);
}

class TaskEntry {
  bool state = false;
  String content = "";
  List<TaskEntry> children = [];

  // 运行时数据
  var finishedChildCount = 0;
  var expanded = false;
  TaskEntry _father;
  int _index = -1;
  bool selected = false;

  TaskEntry(this.content /*, [newChildren]*/) {
/*    if (null != newChildren) {
      children = newChildren;
    }*/
  }
  _addChild(TaskEntry child) {
    child._father = this;
    child._index = children.length;
    children.add(child);
  }

  addChildAndRefreshFatherState(TaskEntry child) {
    _addChild(child);

    assert(false == child.state);
    if (true == state) {
      updateTreeLineState_new(false);
    }
  }

  deleteSelfAndRefreshFatherState() {
    if (null == _father) {
      // 在全部任务视图可以选择日级任务，没有父节点
      return;
    }

    if (false == state) {
      updateTreeLineState_new(true);
    } else {
      _father.finishedChildCount--;
    }

    _father.children.removeAt(_index);

    //更新兄弟节点的索引号
    for (var i = _index + 1; i < _father.children.length; i++) {
      _father.children[i]._index--;
    }

    _father = null;
  }

  Map<String, dynamic> toJson() {
    var jsonMap = Map<String, Object>();

    jsonMap["content"] = content;

    if (null == state) {
      jsonMap["state"] = "DISABLED";
    } else if (true == state) {
      jsonMap["state"] = "DONE";
    }

    if ((null != children) && (children.isNotEmpty)) {
      jsonMap["children"] = children;

      //var childrenStr = ""
    }

    return jsonMap;
  }

  TaskEntry.fromJson(Map<String, dynamic> m) {
    content = m["content"];

    var s = m["state"];
    if (null != s) {
      if ("DONE" == s) {
        state = true;
      } else if ("DISABLED" == s) {
        state = null;
      }
    } else {
      state = false;
    }

    List childrenList = m["children"];
    if (null != childrenList) {
      childrenList.forEach((e) {
        var entry = TaskEntry.fromJson(e);
        _addChild(entry);
      });
    }
    return;
  }

  initStatus() {
    // 不能修改状态，也不能递归触发状态变化，每个节点只更新其直接子节点的完成数量
    assert(null != children);

    var i = 0;
    children.forEach((e) {
      e._index = i;
      i++;
      if ((null == e.state) || (true == e.state)) {
        finishedChildCount++;
      }
      e.initStatus();
    });
  }

  static updateTreeLineState(List<TaskEntry> treeLine, bool newState) {
    // 从倒数第二层开始往上回溯，一层一层更新，直到该层状态没有被连带影响

    // 通过dataTreePosition得到tree中的线路
//    List<MyTaskEntry> treeLine = [_treeRoot];
//    var posLevel = 0;
//    // 0.1.2.3.4，其中dataTreePosition[0]没有父节点
//    dataTreePosition.forEach((i) {
//      if (0 != posLevel) {
//        var child = treeLine[posLevel - 1].children[i];
//        treeLine.add(child);
//      }
//      posLevel++;
//    });

    // 沿着tree中的线路一层一层逆向更新，如果那一层状态没有变化，就直接停止，更上层不会被联动出发状态变化
    //
    // 被动更新的父节点的子项完成计数变化，只有在原状态不是null的情况下重新计算状态，
    // 如果完成状态有变化，继续向上层传递状态变化；
    //
    // 三态情况下，子节点状态变化对父节点的影响
    // 子节点状态变化：false -> true, 父节点子项完成计数增加；
    // 子节点状态变化：true -> null, 父节点子项完成计数不变；
    // 子节点状态变化：null -> false, 父节点子项完成计数减少；
    //
    // 节点finishedChildCount，从children.length -> (children.length-1)，如果以前是true
    //
    // 通过末节点的状态变化，确定需要传递的初状态，
    // 触发更新父节点的属性，父级节点的状态传递只有true和false两种以及更新finishedCount，
    // 如果遇到null状态停止传递，并且该节点只更新finishedCount；
    //

    showLog() {
      treeLine.forEach((e) {
        print(
            "xxx ${e.content} ${e.finishedChildCount}/${e.children.length} ${e.state}");
      });
    }

    //showLog();

    //var needContine = false;
    {
      // 先处理当前节点，
      var leaf = treeLine.last;
      if (null == leaf.state) {
        assert(false == newState);
        //needContine = true;
      } else if (false == leaf.state) {
        assert(true == newState);
        //needContine = true;
      } else {
        // true == leaf.state
        assert((null == newState) || (false == newState));
      }

      leaf.state = newState;
    }

    if (null == newState) {
      return;
    }

    assert(null != newState);
    var childNewState = newState;
    for (var level = treeLine.length - 2; 0 <= level; level--) {
      var entry = treeLine[level];
      var needContinue = false;

      if (null == entry.state) {
        // 当前状态为null，只更新计数，不更新状态，不向上层传递状态变化
        if (true == childNewState) {
          entry.finishedChildCount++;
        } else {
          entry.finishedChildCount--;
        }
      } else {
        // null != entry.state
        if (true == childNewState) {
          entry.finishedChildCount++;
          if (entry.finishedChildCount == entry.children.length) {
            //如果之前本身是false状态则继续才上报，
            // 如果之前是null或者true状态，是不需要继续上报的
            if ((null != entry.state) && (false == entry.state)) {
              entry.state = true;
              childNewState = true;
              needContinue = true;
            }
          }
        } else {
          // (false == childNewState)
          if (entry.finishedChildCount == entry.children.length) {
            //如果之前本身是true状态则继续才上报，
            // 如果之前是null或者false状态，是不需要继续上报的
            if ((null != entry.state) && (true == entry.state)) {
              entry.state = false;
              childNewState = false;
              needContinue = true;
            }
          }
          entry.finishedChildCount--;
        }
      }

      if (false == needContinue) {
        break;
      }
    }

    //showLog();

    return;
  }

  updateTreeLineState_new(bool newState) {
    // 往上回溯一层一层更新状态，直到该层状态没有被连带影响

    // 沿着tree中的线路一层一层逆向更新，如果那一层状态没有变化，就直接停止，更上层不会被联动出发状态变化
    //
    // 被动更新的父节点的子项完成计数变化，只有在原状态不是null的情况下重新计算状态，
    // 如果完成状态有变化，继续向上层传递状态变化；
    //
    // 三态情况下，子节点状态变化对父节点的影响
    // 子节点状态变化：false -> true, 父节点子项完成计数增加；
    // 子节点状态变化：true -> null, 父节点子项完成计数不变；
    // 子节点状态变化：null -> false, 父节点子项完成计数减少；
    //
    // 节点finishedChildCount，从children.length -> (children.length-1)，如果以前是true
    //
    // 通过末节点的状态变化，确定需要传递的初状态，
    // 触发更新父节点的属性，父级节点的状态传递只有true和false两种以及更新finishedCount，
    // 如果遇到null状态停止传递，并且该节点只更新finishedCount；
    //

    //var needContine = false;

    // 先处理当前节点，
    {
      //状态变化规律
      if (null == this.state) {
        assert(false == newState);
        //needContine = true;
      } else if (false == this.state) {
        assert(true == newState);
        //needContine = true;
      } else {
        // true == leaf.state
        assert((null == newState) || (false == newState));
      }
    }
    this.state = newState;

    if (null == newState) {
      return;
    }

    assert(null != newState);
    var childNewState = newState;
    for (var f = this._father; null != f; f = f._father) {
      var needContinue = false;

      if (null == f.state) {
        // 当前状态为null，只更新计数，不更新状态，不向上层传递状态变化
        f.finishedChildCount--;
      } else {
        if (true == childNewState) {
          f.finishedChildCount++;
          if (f.finishedChildCount == f.children.length) {
            //如果之前本身是false状态则继续才上报，
            // 如果之前是null或者true状态，是不需要继续上报的
            if ((null != f.state) && (false == f.state)) {
              f.state = true;
              childNewState = true;
              needContinue = true;
            }
          }
        } else {
          if (f.finishedChildCount == f.children.length) {
            //如果之前本身是true状态则继续才上报，
            // 如果之前是null或者false状态，是不需要继续上报的
            if ((null != f.state) && (true == f.state)) {
              f.state = false;
              childNewState = false;
              needContinue = true;
            }
          }
          f.finishedChildCount--;
        }
      }

      if (false == needContinue) {
        break;
      }
    }

    return;
  }

  getDegreeString() {
    //return (this._index + 1).toString();
    String degreeString = (this._index + 1).toString();
    for (var e = this._father;
        (null != e) && (null != e._father);
        e = e._father) {
      degreeString = (e._index + 1).toString() + "." + degreeString;
    }
    return degreeString;
  }

  static TaskEntry getAllDateTask(Map<String, TaskEntry> dateTaskDataMap) {
    var allDateTask = TaskEntry("所有任务");
    var done = <TaskEntry>[];

    dateTaskDataMap.forEach((k, v) {
      allDateTask.children.add(v);
      if (false != v.state) {
        allDateTask.finishedChildCount++;
      } else {
//        done.add(v);
      }
    });
//    allDateTask.children += done;

    // 按日期排序
    allDateTask.children.sort((l, r) {
      return l.content.compareTo(r.content);
    });

    // 更新一下索引号
    var i = 0;
    allDateTask.children.forEach((e) {
      e._index = i;
      i++;
    });

    return allDateTask;
  }
}

bool isSameMonth(final DateTime l, final DateTime r) {
  if ((null != l) &&
      (null != r) &&
      (l.year == r.year) &&
      (l.month == r.month)) {
    return true;
  }
  return false;
}
