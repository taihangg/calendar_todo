import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  MyBottomNavigationBar(this._updateFn);

  final Function(int) _updateFn;

  @override
  State<StatefulWidget> createState() => MyBottomNavigationBarState(_updateFn);
}

class MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  MyBottomNavigationBarState(this.onSelectCallback);
  final Function(int) onSelectCallback;
  final _unselectedColor = Colors.grey[700];
  final _selectedColor = Colors.yellowAccent;
  int _currentIndex = 0;
  Color _selectColor(int index) {
    if (index == _currentIndex) {
      return _selectedColor;
    } else {
      return _unselectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      //fixedColor: Colors.red,
      backgroundColor: Colors.lightBlueAccent,
      //selectedItemColor: Colors.yellow,
      //unselectedItemColor: Colors.red,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.border_all, color: _selectColor(0)),
          title: Text('日历', style: TextStyle(color: _selectColor(0))),
          //activeIcon: Icon(Icons.star),
          //backgroundColor: Colors.deepOrange,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.brightness_high, color: _selectColor(1)),
          title: Text('天气', style: TextStyle(color: _selectColor(1))),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_location, color: _selectColor(2)),
          title: Text('地图', style: TextStyle(color: _selectColor(2))),
        ),
      ],
      currentIndex: _currentIndex,
      onTap: (int index) {
        _currentIndex = index;
        onSelectCallback(index);
      },
      selectedFontSize: 24.0,
      unselectedFontSize: 16.0,
    );
  }
}
