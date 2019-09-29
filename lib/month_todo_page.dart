import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'month_view.dart';
import 'global_data.dart';
import 'todo_view.dart';
import 'package:rubber/rubber.dart';

class MonthTaskPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  MonthTaskPage(this.screenWidth, this.screenHeight);

  @override
  State<StatefulWidget> createState() {
    return MonthTaskPageState(screenWidth, screenHeight);
  }
}

class MonthTaskPageState extends State<MonthTaskPage>
    with SingleTickerProviderStateMixin {
  final double screenWidth;
  final double screenHeight;
  MonthView _monthView;
  TodoView _todoView;
  MonthTaskPageState(this.screenWidth, this.screenHeight) {
    _monthView = MonthView(
      onDateSelectedFn: (DateTime selectedDate) {
        _todoView.setSelectedDate(selectedDate);
      },
      onMonthChangeFn: (DateTime showMonth) {},
      initDate: null,
      noteIconTypeFn: _noteIconTypeFn,
    );

    _todoView = TodoView(
        width: screenWidth,
        onStatusChangeFn: () {
          _monthView.Refresh();
        });
  }

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

  RubberAnimationController _controller;

  @override
  initState() {
    super.initState();

    _controller = RubberAnimationController(
      vsync: this,
      halfBoundValue: AnimationControllerValue(percentage: 0.5),
      duration: Duration(milliseconds: 200),
    );

    globalData.onLoadDataFinishedFn = () {
      _monthView.Refresh();
      _todoView.Refresh();
    };
  }

  @override
  build(BuildContext context) {
//    return _monthView;

//    return Scaffold(
////      appBar: AppBar(title: Text("Scrolling", style: TextStyle(color: Colors.cyan[900]))),
//      body: Container(
//        child: RubberBottomSheet(
////          scrollController: _scrollController,
//          lowerLayer: _monthView,
////          header: Container(
////            color: Colors.lightBlueAccent,
////            alignment: Alignment.center,
////            child: Text(
////              "历史报数",
////              style: TextStyle(fontSize: screenWidth / 15),
////            ),
////          ),
//          headerHeight: screenWidth / 10,
////          upperLayer: _taskView,
//          animationController: _controller,
//        ),
//      ),
//    );

    List<Widget> _headerSliverBuilder(
        BuildContext context, bool innerBoxIsScrolled) {
      return [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          child: SliverAppBar(
//            floating: true,
//            snap: true,
            pinned: true, // bottom内容是否保留不滑出屏幕
            forceElevated: innerBoxIsScrolled,
            expandedHeight: screenWidth / 7 * 8, // 这个高度必须比flexibleSpace高度大
            flexibleSpace: FlexibleSpaceBar(background: _monthView),
//            bottom: PreferredSize(
//// 46.0为TabBar的高度，也就是tabs.dart中的_kTabHeight值，因为flutter不支持反射所以暂时没法通过代码获取
////                preferredSize: Size(double.infinity, 46.0),
//              preferredSize: Size(double.infinity, screenWidth / 8),
//              child: TaskActionBar(screenWidth, screenHeight),
//            ),
          ),
        ),
      ];
    }

    var tabBarView = TabBarView(children: [
      SafeArea(
          top: false,
          bottom: false,
          child: Builder(builder: (BuildContext context) {
            return CustomScrollView(
                /*key: PageStorageKey<_Page>(page), */ slivers: [
                  SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context)),
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.0),
                          child: _todoView,
                        );
                      },
                      childCount: 1,
                    )),
                  ),
                ]);
          })),
    ]);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: _headerSliverBuilder,
          body: tabBarView,
        ),
      ),
    );
  }
}
